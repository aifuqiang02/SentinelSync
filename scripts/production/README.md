# SentinelSync 生产环境配置

本目录包含 SentinelSync 项目的生产环境专用配置，与开发环境完全隔离，确保生产环境的安全性和稳定性。

## 🏗️ 生产环境架构

生产环境采用轻量级、安全优先的设计：

### 核心服务
- **PostgreSQL** - 主数据库服务
- **RabbitMQ** - 消息队列服务
- **Management Server** - FastAPI 后端服务
- **Go 微服务** - hasher, transporter, log-processor
- **Web UI** - Vue 前端服务

### 生产环境特点
- ❌ 不包含开发调试工具
- ❌ 不包含热重载功能
- ❌ 不暴露调试端口
- ✅ 启用安全配置
- ✅ 配置健康检查
- ✅ 启用日志轮转
- ✅ 资源限制优化

## 📁 目录结构

```
production/
├── docker-compose.yml     # 生产环境配置（纯净版）
├── deploy.ps1            # 生产环境部署脚本
├── .env.template         # 生产环境配置模板
├── .env.production      # 实际生产配置 (不提交到Git)
├── sql/                  # 数据库初始化脚本
│   └── schema.sql       # 数据库结构
└── README.md            # 本文档
```

## 🚀 部署指南

### 1. 环境准备

确保已安装：
- Docker Engine 20.10+
- Docker Compose v2.0+
- PowerShell 5.1+

### 2. 配置准备

```powershell
# 复制生产环境配置模板
cp .env.template .env.production

# 重要：编辑配置文件，修改所有默认值
nano .env.production
```

### 3. 安全配置

部署前必须完成以下安全检查：

```powershell
# 验证配置文件
.\deploy.ps1 -ConfigFile .env.production -HealthCheck

# 详细安全检查将从脚本自动执行
```

### 4. 执行部署

```powershell
# 标准部署
.\deploy.ps1 -ConfigFile .env.production

# 强制重新构建并部署
.\deploy.ps1 -ConfigFile .env.production -ForceRebuild

# 部署并执行完整健康检查
.\deploy.ps1 -ConfigFile .env.production -HealthCheck
```

## 🔧 安全配置

### 必须修改的安全参数

在 `.env.production` 中必须修改以下配置：

```bash
# 数据库安全配置
POSTGRES_PASSWORD=YOUR_STRONG_POSTGRES_PASSWORD

# RabbitMQ 安全配置
RABBITMQ_PASSWORD=YOUR_STRONG_RABBITMQ_PASSWORD

# 应用安全配置
SECRET_KEY=YOUR_RANDOM_32_CHAR_SECRET_KEY

# 生产域名
ALLOWED_ORIGINS=["https://yourdomain.com","https://admin.yourdomain.com"]
```

### 安全最佳实践

1. **密码要求**：
   - 至少16位长度
   - 包含大小写字母、数字、特殊字符
   - 定期轮换（建议90天）

2. **网络安全**：
   - 配置防火墙规则
   - 限制数据库端口访问
   - 启用SSL/TLS

3. **监控告警**：
   - 配置日志监控
   - 设置异常告警
   - 定期健康检查

## 📋 运维管理

### 服务管理命令

```powershell
# 查看服务状态
docker-compose --env-file .env.production ps

# 查看实时日志
docker-compose --env-file .env.production logs -f

# 查看特定服务日志
docker-compose --env-file .env.production logs -f management-server

# 重启特定服务
docker-compose --env-file .env.production restart management-server

# 停止所有服务
docker-compose --env-file .env.production down

# 完全清理（谨慎使用）
docker-compose --env-file .env.production down -v
```

### 健康检查

```powershell
# 执行健康检查
.\deploy.ps1 -ConfigFile .env.production -HealthCheck

# 手动检查服务状态
docker-compose --env-file .env.production exec postgres pg_isready -U sentinel
docker-compose --env-file .env.production exec management-server curl -f http://localhost:8000/health
```

### 数据备份

```powershell
# 备份数据库
docker-compose --env-file .env.production exec postgres pg_dump -U sentinel sentinelsync > backup_$(date +%Y%m%d).sql

# 备份数据卷
docker run --rm -v sentinelsync_postgres_data:/data -v $(pwd):/backup ubuntu tar czf /backup/postgres_backup_$(date +%Y%m%d).tar.gz /data
```

### 性能监控

生产环境配置包含以下监控功能：

- **健康检查间隔**: 30秒
- **日志轮转**: 最大10MB，保留3个文件
- **服务重启策略**: always
- **资源限制**: 根据服务配置

## 🔍 故障排除

### 常见问题诊断

1. **服务无法启动**
   ```powershell
   # 检查端口占用
   netstat -an | findstr :8000

   # 检查服务日志
   docker-compose --env-file .env.production logs service-name
   ```

2. **数据库连接失败**
   ```powershell
   # 检查数据库状态
   docker-compose --env-file .env.production exec postgres pg_isready

   # 测试连接
   docker-compose --env-file .env.production exec management-server python -c "import psycopg2; print('DB OK')"
   ```

3. **内存不足**
   ```powershell
   # 监控资源使用
   docker stats

   # 清理未使用的资源
   docker system prune -f
   ```

### 紧急恢复

```powershell
# 快速重启所有服务
docker-compose --env-file .env.production restart

# 从备份数据库恢复
docker-compose --env-file .env_production down
# 清理数据卷（谨慎操作）
docker volume rm sentinelsync_postgres_data
docker-compose --env-file .env_production up -d
# 恢复数据库
docker-compose --env-file .env_production exec -T postgres psql -U sentinel -d sentinelsync < backup_file.sql
```

## 📊 监控指标

生产环境应监控以下关键指标：

### 系统监控
- CPU 使用率
- 内存使用率
- 磁盘空间
- 网络流量

### 应用监控
- API 响应时间
- 错误率
- 活跃连接数
- 消息队列深度

### 业务监控
- 备份成功率
- 文件处理速度
- Agent 连接状态

## 🔄 升级指南

### 服务升级

```powershell
# 拉取最新镜像
docker-compose --env-file .env_production pull

# 重建并部署
.\deploy.ps1 -ConfigFile .env_production -ForceRebuild

# 逐步升级（推荐）
docker-compose --env-file .env_production up -d --no-deps management-server
```

### 配置更新

```powershell
# 备份当前配置
cp .env.production .env.production.backup

# 更新配置
nano .env.production

# 验证配置
.\deploy.ps1 -ConfigFile .env_production -HealthCheck
```

## 📚 相关文档

- [开发环境配置](../development/README.md)
- [安全配置指南](../../docs/security.md)
- [API 文档](http://yourdomain.com/docs) (部署后)

## 🚨 紧急联系

生产环境问题处理流程：

1. **立即响应**：检查服务状态和日志
2. **快速恢复**：如有必要执行紧急重启
3. **问题定位**：分析日志和监控数据
4. **根本解决**：修复问题并更新配置
5. **事后总结**：更新运维文档

---

**⚠️ 重要提醒**：生产环境配置必须经过安全审查，定期更新密码，监控系统状态，并保持备份数据的完整性。