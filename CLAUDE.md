# CLAUDE.md

你正在运行在一个支持 200k token 上下文 的环境中。这意味着你可以同时“看到”整个模块甚至小型项目的全部代码。

请：

认真分析我接下来提供的所有文件和说明；
基于整体架构而非孤立片段生成或修改代码；
保持命名、风格、依赖与现有代码一致；
如有疑问，优先从上下文中寻找线索，而不是假设。
本文件为 Claude Code（claude.ai/code）在处理本代码仓库时提供指导。

## 项目概览

**SentinelSync（磐石运维）—— AI 驱动的集中式运维平台**

SentinelSync 是一个 AI 驱动的集中式运维平台，集成了数据备份、资产监控、集中日志和预测性运维能力。

平台采用客户端-服务端（Agent-Control Plane）架构：
- **高性能 I/O 操作**：Go（Golang）—— 用于 Agent 客户端、日志处理器和后台工作进程  
- **AI/ML 分析与 API 服务**：Python（FastAPI）—— 用于管理服务器 API 和 AI 引擎  
- **消息总线**：RabbitMQ —— 用于事件流、任务调度和远程命令分发  
- **核心状态存储**：PostgreSQL —— 存储资产信息、配置、备份状态、日志和 AI 洞察结果  
- **前端界面**：Vue 3 + Vite —— 提供现代化 Web UI，包含仪表盘和配置界面  

## 架构与目录结构

代码库采用微服务架构：

- `/agent/` —— 基于 Go 的客户端 Agent，部署在所有目标机器上  
  - `cmd/` —— Agent 主程序入口  
  - `fsmonitor/` —— 基于 fsnotify 的实时文件系统监控  
  - `remote_executor/` —— 接收并处理来自 RabbitMQ 的远程控制命令  
  - `backup_logic/` —— 核心备份 I/O 逻辑与状态管理  

- `/services/` —— 集中式 Go 后台服务（MQ 任务消费者）  
  - `hasher/` —— 备份哈希计算工作进程（消费 `metadata.change` 事件）  
  - `transporter/` —— 备份数据传输工作进程（消费 `transfer.needed` 事件）  
  - `log_processor/` —— 日志事件消费者，将日志写入 PostgreSQL  

- `/control_plane/` —— 管理控制平面  
  - `management_server/` —— Python 后端（FastAPI）  
    - `src/api/` —— 面向 Vue 前端的 REST 和 WebSocket 接口  
    - `src/ml_engine/` —— AI/ML 核心模块，用于日志分析与性能预测  
    - `src/db/` —— PostgreSQL 数据库交互层  
    - `main.py` —— 应用入口点  
  - `web_ui/` —— Vue 3 前端界面，提供仪表盘、资产管理及 AI 洞察视图  

- `/docker/` —— Docker 部署定义  
  - `docker-compose.yml` —— 集中式服务编排（数据库、消息队列、Go 服务、Python API）  
  - `agent/` —— 用于构建可分发 Agent 镜像的 Dockerfile  

- `/scripts/` —— SQL 模式初始化脚本和构建脚本  

- `/docs/` —— 技术文档  

## 核心基础设施流程

### RabbitMQ 消息流
- `metadata_in`（路由键：`metadata.change`）—— Go Agent → Go Hasher 服务  
- `transfer_out`（路由键：`transfer.needed`）—— Go Hasher 服务 → Go Transporter 服务  
- `log_events`（路由键：`log.event`）—— Go Agent → Go 日志处理器  
- `control_commands`（路由键：`command.remote`）—— Python API → Go Agent（远程执行器）  

### PostgreSQL 核心表
- `file_metadata` —— 备份状态追踪  
- `agent_assets` —— 资产信息与元数据  
- `agent_config` —— 远程配置管理  
- `system_logs` —— 聚合的系统事件日志  
- `ai_insights` —— AI 分析结果与预测数据  

## 开发规范

### 新功能开发
在实现新功能时，请考虑本系统的多语言、分布式特性：

1. **先定义消息契约** —— 在 Go 和 Python 代码中同步更新 RabbitMQ 路由键和消息结构  
2. **数据库变更** —— 修改 `/scripts/` 中的 SQL 模式，并同步更新 Python（SQLAlchemy/Pydantic）和 Go 的数据模型  
3. **API 变更** —— 优先扩展 Python FastAPI 接口，再更新 Vue 前端组件  
4. **Agent 变更** —— 在本地充分测试 Go Agent 后，再构建并部署到 Docker Agent 镜像  

### 跨服务依赖
- Go 服务与 Python 服务**不得直接相互调用**—— 必须通过 RabbitMQ 解耦  
- 数据库操作按服务职责划分：Python 服务负责配置与 AI 数据，Go 服务负责 I/O 操作  
- Agent 配置流向为：Python API → RabbitMQ → Go Agent，**不可反向**  

### 性能考量
- 所有大文件操作必须使用流式处理（分块读写）  
- 哈希计算应与文件检测异步执行  
- Agent 的心跳上报和日志上传应使用连接池  
- AI/ML 模型推理应尽可能批处理，以减少对 PostgreSQL 的查询开销