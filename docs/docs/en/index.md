# SentinelSync Documentation

Welcome to the official documentation for **SentinelSync** (磐石运维).

## Overview

SentinelSync is an AI-driven centralized operations platform that provides:

- **Data Backup** - Automated backup and recovery
- **Asset Monitoring** - Real-time asset tracking and health monitoring
- **Centralized Logging** - Unified log aggregation and analysis
- **Predictive Operations** - AI/ML-powered predictive maintenance

## Architecture

The platform follows a microservices architecture with:
- **Client Agent** (Go) - Deployed on target machines
- **Centralized Services** (Go Workers) - Background task processors
- **Control Plane** (Python FastAPI + Vue 3) - Management and AI analysis
- **Infrastructure** - RabbitMQ + PostgreSQL

For detailed information about the business modules, see [Business Modules Planning](./architecture/business-modules.md).

## Quick Start

To get started with SentinelSync, visit the [Installation Guide](./guide/installation.md) or read the [Architecture Overview](./architecture/overview.md).

## Features

- Real-time file system monitoring
- Remote command execution
- Distributed backup system
- AI-powered log analysis
- Predictive performance analytics

---

*For the Chinese version of this documentation, please visit [中文文档](/zh/).*
