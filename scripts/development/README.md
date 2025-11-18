# SentinelSync 开发环境配置

本目录包含 SentinelSync 项目的完整开发环境配置，实现开发和生产环境的完全隔离。

## 🚀 快速开始

### 1. 环境准备

确保已安装：
- Docker Desktop
- PowerShell 5.1+

### 2. 初始化配置

```powershell
# 复制配置模板
cp .env.template .env.local

# 根据需要修改配置（可选）
# nano .env.local  # 或使用其他编辑器
```

### 3. 启动开发环境

```powershell
# 一键启动所有开发服务
.\scripts\start.ps1
```

这将启动：
- PostgreSQL 数据库 (端口 5432)
- RabbitMQ 消息队列 (端口 5672/15672)
- FastAPI 后端 (端口 8000)
- Vue 前端 (端口 5173)
- **开发增强工具**：
  - Redis 缓存 (端口 6379)
  - pgAdmin 数据库管理 (端口 5050)

## 📁 目录结构

```
development/
├── docker-compose.yml          # 完整配置文件（包含开发增强功能）
├── .env.template              # 配置模板
├── .env.local                 # 本地实际配置 (不提交到Git)
├── scripts/                   # 管理脚本
│   ├── start.ps1             # 启动脚本
│   ├── restart.ps1           # 重启脚本
│   └── stop.ps1              # 停止脚本
├── sql/                       # 数据库初始化脚本
│   └── schema.sql            # 数据库结构
└── README.md                  # 本文档
```

## 🛠️ 开发环境特色

### 热重载功能

- **Vue 前端**: 代码修改后自动重新编译和刷新页面
- **Python 后端**: FastAPI 自动重启服务器
- **Go 服务**: 通过 volume 挂载实时同步代码

### 开发管理工具

| 工具 | 访问地址 | 用户名 | 密码 |
|------|----------|--------|------|
| pgAdmin | http://localhost:5050 | admin@sentinel.localdev | admin123 |
| RabbitMQ 管理 | http://localhost:15672 | sentinel | changeme |
| API 文档 | http://localhost:8000/docs | - | - |

### 端口配置

如遇到端口冲突，可以修改 `.env.local` 中的端口配置：
```bash
MANAGEMENT_SERVER_PORT=8001
WEB_UI_PORT=5174
POSTGRES_EXTERNAL_PORT=5433
RABBITMQ_EXTERNAL_PORT=5673
PGADMIN_PORT=5051
```

## 📋 常用命令

### 服务管理

```powershell
# 启动所有服务
.\scripts\start.ps1

# 重启特定服务
.\scripts\restart.ps1 -ServiceName management-server

# 查看可用服务
.\scripts\restart.ps1

# 停止特定服务
.\scripts\stop.ps1 -ServiceName web-ui

# 停止所有服务
.\scripts\stop.ps1

# 完全清理（包括数据）
.\scripts\stop.ps1 -ForceRemove
```

### 调试和监控

```powershell
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f management-server

# 查看服务状态
docker-compose ps

# 进入容器调试
docker-compose exec management-server bash
docker-compose exec postgres psql -U sentinel -d sentinelsync
```

### 强制重建

```powershell
# 重新构建并启动所有服务
.\scripts\start.ps1 -ForceRebuild

# 重新构建特定服务
docker-compose up -d --build management-server
```

## 🔧 配置说明

### 开发环境变量

主要配置项在 `.env.local` 中：

```bash
# 开发专用设置
DEBUG=true                    # 启用调试模式
LOG_LEVEL=debug              # 详细日志输出
AUTO_RELOAD=true             # 热重载开关

# 服务端口（可自定义）
MANAGEMENT_SERVER_PORT=8000  # 后端API端口
WEB_UI_PORT=5173            # 前端端口
POSTGRES_EXTERNAL_PORT=5432 # 数据库端口
```

### 数据库连接

开发环境数据库连接信息：
- 主机: localhost:5432
- 用户名: sentinel
- 密码: changeme
- 数据库: sentinelsync

可以使用 pgAdmin (http://localhost:5050) 或直接用 psql 连接。

## 🐛 故障排除

### 常见问题

1. **端口冲突**
   ```powershell
   # 修改 .env.local 中的端口配置
   # 然后重启服务
   .\scripts\stop.ps1
   .\scripts\start.ps1
   ```

2. **热重载不工作**
   ```powershell
   # 检查文件权限和 volume 挂载
   docker-compose exec management-server ls -la /app
   ```

3. **服务启动失败**
   ```powershell
   # 查看详细错误日志
   docker-compose logs -f [服务名]
   ```

4. **内存不足**
   ```powershell
   # 停用不必要的开发工具
   # 编辑 docker-compose.yml 并注释掉相关服务（如 redis、pgadmin）
   # 然后重启服务: .\scripts\stop.ps1; .\scripts\start.ps1
   ```

### 重置开发环境

```powershell
# 完全清理并重启
.\scripts\stop.ps1 -ForceRemove
# 等待几秒
.\scripts\start.ps1 -ForceRebuild
```

## 💡 开发建议

1. **代码组织**: 在开发过程中，代码修改会自动同步到容器中
2. **调试技巧**: 设置 `LOG_LEVEL=debug` 获取详细日志
3. **性能优化**: 开发时关闭不必要的服务以节省资源
4. **数据管理**: 开发数据会持久化在 Docker volumes 中
5. **环境隔离**: 始终使用开发环境配置，避免影响生产环境

## 📚 相关文档

- [生产环境配置](../production/README.md)
- [项目架构文档](../../docs/)
- [API 文档](http://localhost:8000/docs) (服务启动后)

## 🤝 贡献指南

开发环境配置更改时：
1. 更新 `.env.template` 模板文件
2. 更新本文档
3. 测试新配置的兼容性
4. 提交前确保不影响生产环境配置

---

**⚠️ 重要**: 本配置仅用于开发环境，包含开发工具和调试功能，请勿在生产环境使用。