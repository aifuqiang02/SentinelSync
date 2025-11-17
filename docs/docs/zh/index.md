# SentinelSync 文档

欢迎来到 **SentinelSync** (磐石运维) 官方文档。

## 概述

SentinelSync 是一个 AI 驱动的集中式运维平台，提供以下功能：

- **数据备份** - 自动化备份和恢复
- **资产监控** - 实时资产跟踪和健康监控
- **集中日志** - 统一日志聚合和分析
- **预测运维** - AI/ML 驱动的预测性维护

## 架构

平台采用微服务架构：
- **客户端 Agent** (Go) - 部署在目标机器上
- **集中式服务** (Go Workers) - 后台任务处理器
- **控制平面** (Python FastAPI + Vue 3) - 管理和 AI 分析
- **基础设施** - RabbitMQ + PostgreSQL

详细了解各业务模块，请查看[业务模块规划](./architecture/business-modules.md)。

## 快速开始

要开始使用 SentinelSync，请访问[安装指南](./guide/installation.md)或阅读[架构概述](./architecture/overview.md)。

## 功能特性

- 实时文件系统监控
- 远程命令执行
- 分布式备份系统
- AI 驱动的日志分析
- 预测性能分析

---

*如需英文版文档，请访问 [English Documentation](/en/)。*
