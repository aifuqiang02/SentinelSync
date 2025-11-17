# Development Plan for Backup Feature

## Current Status
以下是根据 `README.md` 了解到的备份功能的开发情况：

- **Vue 前端组件调整**：原计划创建 `BackupDashboard.vue` 和 `BackupTable.vue`，但在发现 `control_plane/web_ui/src/views/BackupManagement.vue` 已有更全面的备份策略和任务管理界面后，决定废弃前两者，转而更新 `backupService.js` 以支持 `BackupManagement.vue` 所需的 API。
- **架构定义**: 客户端-服务器 (Agent-Control Plane) 架构已明确，Go 处理高性能 I/O，Python 处理 AI 分析和 API 服务，RabbitMQ 作为事件总线，PostgreSQL 作为核心状态存储。
- **核心功能矩阵**: 数据备份被列为核心功能，具备实时监控（`fsnotify`），流式哈希计算，异步队列传输。
- **Go Agent 组件**: 已规划 `/agent/backup_logic/backup.go` 用于核心备份 I/O 逻辑和状态管理。
- **Go Services 组件**: 已规划 `/services/hasher/hasher.go` 负责备份哈希计算工人，`/services/transporter/transporter.go` 负责备份数据传输工人。
- **消息队列集成**: RabbitMQ 的 `metadat-in` (routing: `metadata.change`) 从 Go Agent 到 Go Hasher Service，及 `transfer_out` (routing: `transfer.needed`) 从 Go Hasher Service 到 Go Transporter Service 的消息流已定义。
- **数据库表**: `file_metadata` 表已被指定用于备份状态跟踪。

目前来看，项目的整体架构和备份功能的核心模块在设计层面已经比较清晰。

## Next Steps

- [x] Integrate file system monitoring with backup logic.
- [x] Implement data transfer worker for backup.
- [x] Connect Go services to RabbitMQ for message exchange.
- [x] Develop PostgreSQL interactions for backup status tracking.
- [x] Extend FastAPI for backup management APIs.
- [x] Update Vue frontend for backup configurations and dashboards.
