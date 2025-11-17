# SentinelSync 环境配置指南

## 概述

SentinelSync 采用统一的环境配置管理系统，解决了多服务配置重复和管理复杂的问题。系统支持开发环境、测试环境和生产环境的灵活配置，同时确保敏感信息的安全。

## 配置文件结构

```
SentinelSync/
├── .env.template              # 配置模板（包含说明）
├── .env.local                 # 本地开发配置（不提交）
├── .env.development           # 开发环境配置模板
├── docker-compose.yml         # 完整 Docker 配置（包含开发增强功能）
└── control_plane/management_server/.env.example # 服务特定配置示例
```

## 快速开始

### 1. 本地开发环境

```bash
# 复制配置模板
cp .env.template .env.local

# 编辑本地配置（如果需要）
nano .env.local

# 启动开发环境
docker-compose up -d
```

### 2. 不同环境切换

```bash
# 开发环境
cp .env.development .env.local
docker-compose up -d

# 生产环境（需要在配置中禁用开发专用服务）
# 编辑 docker-compose.yml，注释掉 redis、pgadmin 等开发服务
docker-compose up -d
```

## 配置层级说明

### 1. 根目录配置（推荐）

- **`.env.template`**: 包含所有可配置项和详细说明
- **`.env.local`**: 实际的本地配置，不会被 Git 追踪
- **`.env.development`**: 开发环境的参考配置

### 2. Docker 配置

- **`docker-compose.yml`**: 完整服务定义，包含基础服务和开发增强功能，使用环境变量引用

### 3. 服务特定配置

- **`.env.example`**: 各服务的特定配置，继承根目录配置

## 环境变量说明

### 基础设施配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `POSTGRES_HOST` | localhost | PostgreSQL 主机 |
| `POSTGRES_PORT` | 5432 | PostgreSQL 端口 |
| `POSTGRES_DB` | sentinelsync | 数据库名称 |
| `POSTGRES_USER` | sentinel | 数据库用户 |
| `POSTGRES_PASSWORD` | changeme | 数据库密码 |
| `RABBITMQ_HOST` | localhost | RabbitMQ 主机 |
| `RABBITMQ_PORT` | 5672 | RabbitMQ 端口 |
| `RABBITMQ_USER` | sentinel | RabbitMQ 用户 |
| `RABBITMQ_PASSWORD` | changeme | RabbitMQ 密码 |

### 应用配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `APP_HOST` | 0.0.0.0 | 应用监听地址 |
| `APP_PORT` | 8000 | 应用端口 |
| `DEBUG` | true | 调试模式 |
| `SECRET_KEY` | - | JWT 密钥（必须设置） |
| `ALLOWED_ORIGINS` | [...] | CORS 允许的源 |

### 端口映射配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `POSTGRES_EXTERNAL_PORT` | 5432 | PostgreSQL 外部端口 |
| `RABBITMQ_EXTERNAL_PORT` | 5672 | RabbitMQ 外部端口 |
| `RABBITMQ_MANAGEMENT_PORT` | 15672 | RabbitMQ 管理界面端口 |
| `MANAGEMENT_SERVER_PORT` | 8000 | 管理服务器外部端口 |
| `WEB_UI_PORT` | 5173 | Web UI 外部端口 |

## 开发环境特性

### 1. 自动热重载

- **Python (Management Server)**: 使用 `uvicorn --reload`
- **Vue (Web UI)**: 使用 `npm run dev`
- **Go 服务**: 源码卷映射，支持二进制重编译

### 2. 开发工具

- **Redis**: 缓存服务用于开发测试
- **pgAdmin**: 数据库管理界面 (http://localhost:5050)
- **RabbitMQ Management**: 消息队列管理 (http://localhost:15672)

### 3. 调试配置

- 详细的日志输出 (`LOG_LEVEL=debug`)
- 开源卷映射便于代码编辑
- 开发特定的环境变量

## 生产环境部署

### 1. 环境准备

```bash
# 创建生产环境配置
cp .env.template .env.production

# 编辑生产配置（必须更改密码和密钥）
nano .env.production

# 使用生产配置
docker-compose -f docker-compose.yml up -d
```

### 2. 安全配置

```bash
# 必须更改的安全配置项
POSTGRES_PASSWORD=your-secure-password
RABBITMQ_PASSWORD=your-secure-password
SECRET_KEY=your-super-secret-jwt-key
```

### 3. 生产环境优化

- 移除开发工具（Redis、pgAdmin）
- 关闭调试模式 (`DEBUG=false`)
- 使用强密码和密钥
- 配置适当的资源限制

## 最佳实践

### 1. 配置管理

- ✅ 使用 `.env.local` 进行本地开发
- ✅ 敏感信息不提交到版本控制
- ✅ 不同环境使用不同的配置文件
- ✅ 定期更新默认密码和密钥

### 2. 开发工作流

```bash
# 新环境初始化
cp .env.template .env.local
docker-compose up -d

# 服务开发时（仅启动需要的服务）
docker-compose up -d management-server web-ui

# 查看服务日志
docker-compose logs -f management-server
```

### 3. 故障排除

```bash
# 检查配置加载情况
docker-compose config

# 验证环境变量
docker-compose exec management-server env | grep -E "(DATABASE|RABBITMQ)"

# 重启特定服务
docker-compose restart management-server
```

## 常见问题

### Q: 如何修改端口避免冲突？

A: 在 `.env.local` 中修改端口变量：

```bash
MANAGEMENT_SERVER_PORT=8001
WEB_UI_PORT=5174
POSTGRES_EXTERNAL_PORT=5433
```

### Q: 如何在不重建镜像的情况下修改配置？

A: 修改 `.env.local` 后重启服务：

```bash
docker-compose down && docker-compose up -d
```

### Q: 如何临时禁用开发工具？

A: 编辑 `docker-compose.yml` 文件，注释掉开发专用服务：

```bash
# 使用文本编辑器注释掉 redis、pgadmin 等服务
# 然后重启服务
docker-compose down && docker-compose up -d
```

### Q: 如何添加新的环境变量？

A: 1. 在 `.env.template` 中添加变量和说明
   2. 在 `docker-compose.yml` 服务中引用变量
   3. 在相关服务代码中读取环境变量
   4. 重启服务使配置生效

## 配置验证

使用以下命令验证配置正确性：

```bash
# 验证 Docker Compose 配置
docker-compose config

# 检查环境变量
docker run --rm -v $(pwd)/.env.local:/.env alpine cat /.env

# 测试数据库连接
docker-compose exec management-server python -c "
from sqlalchemy import create_engine
engine = create_engine('postgresql://sentinel:changeme@postgres:5432/sentinelsync')
engine.connect()
print('Database connection successful')
"
```

## 总结

新的配置系统通过统一的环境变量管理实现了：

- 🔧 **简化配置管理**: 所有配置集中管理，减少重复
- 🛡️ **增强安全性**: 敏感信息不被提交到版本控制
- 🚀 **开发便利性**: 热重载、开发工具、调试支持
- 🔄 **环境隔离**: 开发、测试、生产环境配置分离
- 📦 **部署灵活性**: 支持不同的部署场景和需求

通过遵循本指南，您可以高效地管理 SentinelSync 项目的环境配置，确保开发效率和生产安全性。