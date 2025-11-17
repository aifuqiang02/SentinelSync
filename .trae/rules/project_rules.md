
项目代码库结构如下：

```
/SentinelSync-AI-OpsPlatform
├── docs/                     # 所有技术文档,vitepress 国际化
│   └── docs/
│       ├── en/               # 英文文档
│       │   └── architecture/ # 英文架构文档
│       │       └── business-modules.md
│       └── zh/               # 中文文档
│           └── architecture/ # 中文架构文档
│               └── business-modules.md
│
├── scripts/                  # 部署脚本和环境配置
│   ├── development/          # 开发环境配置和脚本
│   │   ├── docker-compose.yml
│   │   ├── sql/              # 数据库初始化脚本
│   │   └── scripts/          # 开发环境操作脚本
│   └── production/           # 生产环境配置和脚本
│       ├── docker-compose.yml
│       ├── sql/              # 数据库初始化脚本
│       └── deploy.ps1        # 部署脚本
│
├── services/                 # 集中式 Go 后台服务 (RabbitMQ 任务处理器)
│   ├── hasher/               # 备份哈希计算 Worker (consumes metadata.change)
│   │   └── hasher.go
│   ├── transporter/          # 备份数据传输 Worker (consumes transfer.needed)
│   │   └── transporter.go
│   └── log_processor/        # 日志消费并写入 PostgreSQL
│       └── processor.go
│
├── agent/                    # 客户端 Go Agent 源代码 (部署在所有目标机器)
│   ├── cmd/
│   │   └── main.go           # Agent 主程序入口
│   ├── fsmonitor/            # 基于 fsnotify 的实时文件系统监控模块
│   │   └── monitor.go
│   ├── remote_executor/      # 接收和处理来自 RabbitMQ 的远程控制指令
│   │   └── executor.go
│   └── backup_logic/         # 核心备份 I/O 逻辑和状态管理
│       └── backup.go
│
├── control_plane/            # 管理控制平面 (Python FastAPI + Vue 3)
│   ├── management_server/    # Python Backend (FastAPI)
│   │   ├── src/
│   │   │   ├── api/          # REST 和 WebSocket 接口
│   │   │   │   └── __init__.py
│   │   │   ├── ml_engine/    # AI/ML 核心模块 (分析日志、预测性能、优化资源配置)
│   │   │   │   └── __init__.py
│   │   │   └── db/           # PostgreSQL 数据库交互层
│   │   │       └── __init__.py
│   │   └── main.py           # FastAPI 应用入口点
│   │
│   └── web_ui/               # Vue 3 前端界面 (dashboards, asset management, AI insights)
│       └── index.html
│
├── README.md                 # 项目总览与快速入门
└── go.work                   # Go 模块管理文件 (多模块管理)
```