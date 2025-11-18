# 开发环境搭建指南 (Windows)

本指南面向开发者，介绍了在 Windows 环境下如何编译和启动 SentinelSync 项目的各个组件。

## 快速开始 🚀

**推荐使用统一管理脚本**：我们提供了完整的 Docker 容器化方案，可以一键启动和管理所有服务。

```powershell
# 1. 初始化环境配置（首次运行）
cp .env.template .env.local

# 2. 启动所有服务（包含开发增强功能）
cd docker
.\start.ps1
```

这将自动：
- 检查前置条件
- 初始化环境配置和数据库
- 启动所有服务（postgres, rabbitmq, management-server, hasher, transporter, log-processor, web-ui）
- 启动开发增强工具（Redis缓存、pgAdmin管理界面）
- 启用热重载和调试模式
- 等待服务就绪并显示访问地址

**📖 详细配置说明**：请参阅 [环境配置指南](../../../CONFIGURATION.md) 了解如何自定义开发环境。

## 前提条件

必须安装：
- 已安装 Docker 和 Docker Compose
- 已安装 Git

可选（用于本地开发）：
- Go 语言环境 (版本 1.20+)
- Python 语言环境 (版本 3.9+)
- Node.js 和 npm/yarn

## 环境配置 ⚙️

SentinelSync 使用统一的环境配置管理系统，有效解决多服务配置重复和管理复杂的问题。

### 1. 快速配置初始化

```powershell
# 复制配置模板（首次运行）
cp .env.template .env.local

# 查看配置选项
cat .env.template  # 包含所有可配置项和详细说明
```

### 2. 配置文件说明

| 文件 | 用途 | 是否提交到Git |
|------|------|---------------|
| `.env.template` | 配置模板（包含说明） | ✅ 是 |
| `.env.local` | 本地开发实际配置 | ❌ 否 |
| `.env.development` | 开发环境参考配置 | ✅ 是 |

### 3. 常见配置调整

```bash
# 修改端口避免冲突（编辑 .env.local）
MANAGEMENT_SERVER_PORT=8001
WEB_UI_PORT=5174
POSTGRES_EXTERNAL_PORT=5433

# 自定义密码（生产环境必须修改）
POSTGRES_PASSWORD=your-secure-password
RABBITMQ_PASSWORD=your-secure-password
SECRET_KEY=your-super-secret-jwt-key
```

### 4. 开发环境增强功能

使用 `.env.local` 配置时，自动启用以下开发功能：
- 🔄 热重载：代码修改自动重启服务
- 🐛 调试模式：详细日志和错误信息
- 🛠️ 开发工具：Redis缓存、pgAdmin数据库管理界面
- 📊 监控界面：RabbitMQ管理界面

**📖 详细配置说明**：完整的环境配置使用指南请参阅 [CONFIGURATION.md](../../../CONFIGURATION.md)。

## 1. 克隆代码库

```bash
git clone <your-repository-url>
cd SentinelSync
```

## 2. 统一服务管理（推荐）

### 2.1 启动所有服务

```powershell
cd docker
.\start.ps1
```

**可选参数**：
- `-SkipDatabaseInit`: 跳过数据库初始化
- `-ForceRebuild`: 强制重新构建所有Docker镜像

```powershell
# 示例：重新构建并启动
.\start.ps1 -ForceRebuild
```

### 2.2 管理服务

**查看运行状态**：
```powershell
docker-compose ps
```

**重启服务**：
```powershell
# 重启所有服务
.\restart.ps1 -All

# 重启特定服务
.\restart.ps1 -ServiceName management-server

# 查看可用服务列表
.\restart.ps1
```

**停止服务**：
```powershell
# 停止所有服务
.\stop.ps1

# 停止特定服务
.\stop.ps1 -ServiceName web-ui

# 完全清理（包括数据）
.\stop.ps1 -ForceRemove
```

### 2.3 访问地址

启动完成后可以通过以下地址访问（端口号可在 `.env.local` 中自定义）：

- **Vue 前端界面**: http://localhost:5173 （可通过 `WEB_UI_PORT` 修改）
- **FastAPI 管理界面**: http://localhost:8000 （可通过 `MANAGEMENT_SERVER_PORT` 修改）
- **API 文档**: http://localhost:8000/docs
- **数据库管理界面**（开发环境增强）: http://localhost:5050
  - 用户名: admin@sentinel.local
  - 密码: admin123
- **RabbitMQ 管理界面**: http://localhost:15672 （可通过 `RABBITMQ_MANAGEMENT_PORT` 修改）
  - 用户名: 从环境变量 `RABBITMQ_USER` 读取（默认：sentinel）
  - 密码: 从环境变量 `RABBITMQ_PASSWORD` 读取

**💡 开发环境提示**：
- 访问凭据都在 `.env.local` 中配置，可以根据需要修改
- 新增的 pgAdmin（数据库管理）界面仅开发环境可用
- Redis 缓存服务在端口 6379 运行，用于开发测试

### 2.4 查看服务日志

```powershell
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f management-server
```

## 3. 本地开发环境（可选）

如果你需要在本地修改和调试代码，可以使用以下方式逐个启动服务。

### 3.1 启动核心基础设施

```bash
cd docker
# 启动数据库和消息队列（使用环境配置）
docker-compose up -d postgres rabbitmq
```

### 3.2 初始化数据库

数据库连接信息从环境变量读取（`.env.local` 文件）：
- 主机：`${POSTGRES_HOST:-localhost}`
- 端口：`${POSTGRES_EXTERNAL_PORT:-5432}`
- 用户名：`${POSTGRES_USER:-sentinel}`
- 密码：`${POSTGRES_PASSWORD:-changeme}`
- 数据库：`${POSTGRES_DB:-sentinelsync}`

```bash
# 创建数据库（首次运行，使用环境配置）
docker exec -it $(docker-compose ps -q postgres) psql -U ${POSTGRES_USER:-postgres}
CREATE DATABASE ${POSTGRES_DB:-sentinelsync};
\q
```

执行初始化脚本：
```bash
cd ..\scripts\sql
Get-ChildItem -Path . -Filter "*.sql" | ForEach-Object {
    docker exec $(docker-compose ps -q postgres) psql -U ${POSTGRES_USER:-sentinel} -d ${POSTGRES_DB:-sentinelsync} -f "sql/$($_.Name)"
}
```

### 3.3 编译和启动 Go 服务

### Go Agent

如果你需要开发Agent（部署在目标机器上的客户端）：

```bash
cd agent
go install github.com/air-verse/air@latest  # 安装热重载工具

# 确保环境配置已加载（使用环境变量）
# 本地开发时，会自动从 .env.local 读取配置
air  # 启动开发模式
```

**环境变量配置**：
从 `.env.local` 读取必要的环境变量：
- `RABBITMQ_URL`: `amqp://sentinel:changeme@localhost:5672/`
- `LOG_LEVEL`: `debug`（开发环境）

### Go Services (Hasher, Transporter, Log Processor)

每个Go服务都可以独立开发：

```bash
cd services\hasher
# 会从根目录的 .env.local 读取配置
air  # 使用热重载
```

**Air配置示例 (air.toml)**：
```toml
# hasher/air.toml
root = "."
tmp_dir = "tmp"

[build]
  working_dir = "."
  cmd = "go build -o tmp/hasher.exe ."
  bin = "tmp/hasher.exe"
  # 从环境变量读取配置，不硬编码
  env = [
    "RABBITMQ_URL=${RABBITMQ_URL}",
    "DATABASE_URL=${DATABASE_URL}",
    "LOG_LEVEL=${LOG_LEVEL:-info}"
  ]
  stop_on_error = true

[run]
  cmd = "tmp/hasher.exe"

[misc]
  clean_on_exit = true
```

**💡 环境变量加载**：
Go 服务启动时建议在终端先加载环境变量：
```bash
# PowerShell 方式
$env:RABBITMQ_URL = "amqp://sentinel:changeme@localhost:5672/"
$env:DATABASE_URL = "host=localhost port=5432 user=sentinel password=changeme dbname=sentinelsync sslmode=disable"
$env:LOG_LEVEL = "debug"
air

# 或使用 dotenv 工具自动加载 .env.local
go install github.com/joho/godotenv/cmd/godotenv@latest
godotenv air
```

### 3.4 启动 Python FastAPI 后端

```bash
cd control_plane\management_server

# 安装依赖（首次运行）
pip install -r requirements.txt

# 确保环境变量已加载（从根目录的 .env.local 读取）
# 开发环境会自动启用调试模式和热重载
uvicorn main:app --host ${APP_HOST:-0.0.0.0} --port ${APP_PORT:-8000} --reload --log-level debug
```

**环境变量加载方式**：
```bash
# 方式1: 手动设置（开发调试用）
$env:DATABASE_URL = "postgresql://sentinel:changeme@localhost:5432/sentinelsync"
$env:RABBITMQ_URL = "amqp://sentinel:changeme@localhost:5672"
$env:DEBUG = "true"
uvicorn main:app --reload

# 方式2: 使用 python-dotenv 自动加载
pip install python-dotenv
# FastAPI 启动时会自动读取 .env 文件
uvicorn main:app --reload
```

### 3.5 启动 Vue 前端

```bash
cd control_plane\web_ui

# 安装依赖（首次运行）
corepack enable pnpm
pnpm install

# 启动开发服务器（会读取环境变量）
pnpm run dev

# 或手动指定配置
pnpm run dev -- --host 0.0.0.0 --port ${VITE_PORT:-5173}
```

**前端环境变量**：
Vue 前端通过 `.env.local` 或环境变量读取配置：
```bash
# 从根目录环境变量继承
VITE_API_URL=http://localhost:${MANAGEMENT_SERVER_PORT:-8000}
VITE_DEV_MODE=true
VITE_LOG_LEVEL=debug
```

## 4. 服务架构说明

### 4.1 Docker 容器服务

| 服务名称 | 描述 | 默认端口 | 说明 |
|---------|------|----------|------|
| postgres | PostgreSQL 数据库 | 5432 | 核心数据存储，端口可通过 `POSTGRES_EXTERNAL_PORT` 修改 |
| rabbitmq | RabbitMQ 消息队列 | 5672/15672 | 消息传递和任务调度，可通过 `RABBITMQ_EXTERNAL_PORT`/`RABBITMQ_MANAGEMENT_PORT` 修改 |
| management-server | FastAPI 后端 | 8000 | REST API 和管理界面，可通过 `MANAGEMENT_SERVER_PORT` 修改 |
| hasher | Go 文件哈希服务 | - | 处理备份文件哈希计算，从环境变量读取连接配置 |
| transporter | Go 数据传输服务 | - | 处理备份文件传输，从环境变量读取连接配置 |
| log-processor | Go 日志处理器 | - | 收集和处理系统日志，从环境变量读取连接配置 |
| web-ui | Vue 前端 | 5173 | Web 用户界面，可通过 `WEB_UI_PORT` 修改 |

### 4.2 开发环境增强服务

| 服务名称 | 描述 | 端口 | 说明 |
|---------|------|------|------|
| redis | Redis 缓存服务 | 6379 | 开发环境缓存测试，可通过 `REDIS_EXTERNAL_PORT` 修改 |
| pgadmin | 数据库管理界面 | 5050 | PostgreSQL 网页管理工具，仅开发环境可用 |

**💡 配置提示**：
- 所有端口配置都可以在 `.env.local` 文件中修改
- 连接信息（用户名、密码、数据库名）都通过环境变量管理
- 开发增强服务仅在使用 `docker-compose up -d` 启动时可用（通过 override.yml）

### 4.3 Agent 服务

Agent 是独立部署在目标机器上的客户端，用于监控本地文件系统和执行远程命令。它不在 Docker 容器中运行，需要单独部署。

## 5. 故障排除

### 5.1 配置相关问题

**环境配置未加载**：
```powershell
# 检查环境配置文件
cat .env.local

# 验证 Docker Compose 解析的配置
docker-compose config

# 查看容器内部的环境变量
docker-compose exec management-server env | grep -E "(DATABASE|RABBITMQ|DEBUG)"
```

**端口冲突**：
```powershell
# 修改 .env.local 中的端口配置
MANAGEMENT_SERVER_PORT=8001
WEB_UI_PORT=5174
POSTGRES_EXTERNAL_PORT=5433

# 重启服务使配置生效
docker-compose down && docker-compose up -d
```

**数据库连接失败**：
```powershell
# 检查数据库服务状态
docker-compose ps postgres

# 测试数据库连接
docker-compose exec management-server python -c "
from sqlalchemy import create_engine
import os
engine = create_engine(os.getenv('DATABASE_URL'))
engine.connect()
print('Database connection successful')
"
```

**RabbitMQ 连接问题**：
```powershell
# 检查 RabbitMQ 服务状态
docker-compose ps rabbitmq

# 测试消息队列连接
docker-compose exec management-server python -c "
import pika
import os
connection = pika.BlockingConnection(pika.URLParameters(os.getenv('RABBITMQ_URL')))
print('RabbitMQ connection successful')
"
```

### 5.2 常见问题

**权限问题**：
确保 Docker 有足够的权限访问文件系统。

**网络连接**：
确保服务之间的网络连接正常，检查防火墙设置。

**服务启动失败**：
```powershell
# 查看详细错误日志
docker-compose logs -f [服务名]

# 重建有问题的服务
docker-compose up -d --build [服务名]

# 完全清理并重新开始
docker-compose down -v
docker system prune -f
.\start.ps1 -ForceRebuild
```

### 5.3 调试命令

```powershell
# 查看容器日志
docker-compose logs -f [服务名]

# 进入容器调试
docker exec -it [容器名] /bin/bash

# 重新构建特定服务
docker-compose up -d --build [服务名]

# 查看环境变量解析结果（配置调试）
docker-compose config

# 验证环境变量加载
docker-compose exec management-server env | grep -E "(DATABASE|RABBITMQ|DEBUG|SECRET)"

# 测试服务间连接
docker-compose exec management-server python -c "
import requests
try:
    r = requests.get('http://postgres:5432', timeout=5)
    print('Postgres reachable via Docker network')
except:
    print('Postgres not reachable')
"

# 清理并重新开始
docker-compose down -v
docker system prune -f
.\start.ps1 -ForceRebuild
```

## 6. 开发建议

1. **配置管理优先**：始终使用 `.env.local` 管理开发配置，避免硬编码
2. **环境隔离**：开发、测试、生产环境配置彻底分离
3. **安全实践**：定期更新密码和密钥，不在代码中暴露敏感信息
4. **使用统一脚本**：日常开发推荐使用 `.start.ps1` 脚本
5. **微服务调试**：需要调试单个服务时，可以停止其他服务，只运行目标服务
6. **数据库管理**：使用 pgAdmin（开发环境）或 DBeaver 连接到数据库进行管理
7. **API 测试**：使用 FastAPI 自动生成的文档页面进行 API 测试
8. **增量开发**：修改代码后，对应的服务会自动重新编译和启动（热重载）
9. **配置验证**：部署前先验证配置变量：`docker-compose config`
10. **日志分析**：开发时使用 `LOG_LEVEL=debug` 获取详细信息

**📖 配置系统最佳实践**：
- 详细配置请参阅 [环境配置指南](../../../CONFIGURATION.md)
- 生产环境配置参考 `.env.development` 但必须更改所有密码和密钥
- 使用环境变量而非配置文件管理敏感信息

## 7. 生产环境部署

生产环境部署时，请：

### 7.1 配置安全
1. **修改默认密码**：更改数据库、RabbitMQ、JWT密钥
2. **配置独立环境变量**：创建生产专用配置文件
3. **使用强密码和随机密钥**：使用密码生成器创建安全的凭据

### 7.2 部署方式
1. **不使用开发配置**：部署时在 `docker-compose.yml` 中注释掉开发专用服务（redis、pgadmin、热重载等）
2. **使用外部基础设施**：外部数据库和消息队列
3. **配置日志收集**：统一日志管理和监控
4. **设置资源限制**：Docker 资源限制和健康检查

### 7.3 配置示例
```bash
# 生产环境部署（不包含开发工具）
docker-compose -f docker-compose.yml up -d

# 使用生产配置文件
ENV_FILE=.env.production docker-compose -f docker-compose.yml up -d

# 验证生产配置
docker-compose config
```

**📖 详细配置说明**：完整的生产环境配置指南请参阅 [环境配置指南](../../../CONFIGURATION.md#生产环境配置)。

---

**注意**：Agent 服务需要在目标机器上单独编译和部署，不属于 Docker Compose 管理范围。