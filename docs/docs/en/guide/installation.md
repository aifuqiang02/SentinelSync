# Installation Guide

This guide will help you install and set up SentinelSync.

## Prerequisites

- Docker and Docker Compose (v2.0+)
- Go 1.21+ (for building agents)
- Python 3.11+ (for control plane)
- Node.js 18+ (for web UI)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/SentinelSync.git
cd SentinelSync
```

### 2. Start Core Services

```bash
docker-compose -f docker/docker-compose.yml up -d
```

This will start:
- PostgreSQL database
- RabbitMQ message broker
- Go background services (hasher, transporter, log_processor)
- Python management server

### 3. Verify Installation

Check that all services are running:

```bash
docker-compose ps
```

### 4. Access Web UI

Open your browser and navigate to `http://localhost:8080`

### 5. Deploy Agent

See [Agent Deployment](./agent-deployment.md) for instructions on deploying agents to target machines.

## Next Steps

- [Configure Backup Policies](./configuration/backup-policies.md)
- [Add Assets](./configuration/adding-assets.md)
- [Set up Monitoring](./monitoring/setup.md)
