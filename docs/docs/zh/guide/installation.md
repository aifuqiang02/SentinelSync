# 安装指南

本指南将帮助您安装和设置 SentinelSync。

## 前置要求

- Docker 和 Docker Compose (v2.0+)
- Go 1.21+ (用于构建 Agent)
- Python 3.11+ (用于控制平面)
- Node.js 18+ (用于 Web UI)

## 安装步骤

### 1. 克隆仓库

```bash
git clone https://github.com/your-org/SentinelSync.git
cd SentinelSync
```

### 2. 启动核心服务

```bash
docker-compose -f docker/docker-compose.yml up -d
```

这将启动：
- PostgreSQL 数据库
- RabbitMQ 消息代理
- Go 后台服务 (hasher、transporter、log_processor)
- Python 管理服务器

### 3. 验证安装

检查所有服务是否正在运行：

```bash
docker-compose ps
```

### 4. 访问 Web UI

打开浏览器并访问 `http://localhost:8080`

### 5. 部署 Agent

有关将 Agent 部署到目标机器的说明，请参见 [Agent 部署](./agent-deployment.md)。

## 下一步

- [配置备份策略](./configuration/backup-policies.md)
- [添加资产](./configuration/adding-assets.md)
- [设置监控](./monitoring/setup.md)
