# Business Modules Planning

Based on the AI-Driven Centralized Operations Platform positioning, SentinelSync is planned with the following five core business modules:

## Module 1: Intelligent Data Backup Management

**Core Features:**

- **Real-time Monitoring & Capture**: File system change detection based on fsnotify
- **Intelligent Hash Computation**: Asynchronous queue processing, stream computing avoids memory peaks
- **Breakpoint Resume**: Transfer task persistence, supports network interruption recovery
- **Backup Policy Management**: Full/incremental/differential backup configuration
- **Backup Verification**: Integrity verification and consistency checks

**Technical Implementation:**
- Agent Side: Go fsmonitor + backup_logic
- Server Side: Go Hasher + Transporter services
- Storage: PostgreSQL (file_metadata)

**Business Value:** Ensure zero data loss, backup process transparent to business

---

## Module 2: Full Lifecycle Asset Management

**Core Features:**

- **Auto Discovery & Registration**: Automatic registration to asset library when Agent comes online
- **Real-time Monitoring**: CPU, memory, disk, network and other basic metrics
- **Version Tracking**: Operating system, Agent version, key component version management
- **Status Management**: Online/offline, health status, last heartbeat time
- **Asset Configuration**: Dynamic configuration delivery and synchronization

**Technical Implementation:**
- Agent Side: Regular heartbeat reporting
- Server Side: Python API + PostgreSQL (agent_assets, agent_config)
- Frontend: Vue 3 asset list and detail pages

**Business Value:** Global asset visualization, quickly locate problem nodes

---

## Module 3: Remote Operations Command Center

**Core Features:**

- **Command Delivery**: Trigger remote operations through Web UI (immediate backup, service restart, etc.)
- **Batch Operations**: Execute the same command on multiple nodes
- **Execution Records**: Audit logs for all operations
- **Real-time Feedback**: Real-time push of command execution status (WebSocket)

**Technical Implementation:**
- Frontend: Vue UI components
- API: Python FastAPI
- Message Flow: RabbitMQ control_commands → Go Agent Remote Executor
- Real-time Communication: WebSocket bidirectional communication

**Business Value:** Improve operational efficiency, reduce manual login costs

---

## Module 4: Centralized Log Intelligent Analysis

**Core Features:**

- **Real-time Collection**: Agent-side system logs, application logs, error logs
- **Unified Storage**: Structured storage to PostgreSQL
- **Log Search**: Multi-condition combination search (time range, level, source)
- **Intelligent Alerting**: Rule-based anomaly detection

**Technical Implementation:**
- Agent Side: Log event generation → RabbitMQ(log_events)
- Server Side: Go Log Processor → PostgreSQL(system_logs)
- Query: Python API provides search interface
- Visualization: Vue log viewer

**Business Value:** Full system observability, rapid fault localization

---

## Module 5: AI-Driven Predictive Operations

**Core Features:**

- **Anomaly Detection**: Identify abnormal patterns based on historical data (backup failure, performance degradation, etc.)
- **Performance Prediction**: Trend prediction of disk usage, backup duration
- **Capacity Planning**: Intelligent resource expansion recommendations
- **Root Cause Analysis**: Automatic analysis of fault correlations
- **Optimization Suggestions**: Backup window, concurrency, resource allocation recommendations

**Technical Implementation:**
- Python ML Module: Pandas/Scikit-learn/TensorFlow/PyTorch
- Data Sources: PostgreSQL(ai_insights, file_metadata, system_logs)
- Training Engine: Periodic training and model updates
- Inference Services: FastAPI endpoints for real-time inference

**Business Value:** Shift from reactive response to proactive prevention, reduce failure rates

---

## Business Module Interaction Diagram

```
┌──────────────────────────────────────────────────┐
│          Web UI Dashboard (Vue 3)                │
└──────────────┬─────────────────┬─────────────────┘
               │                 │
        ───────┴───────           │
        │★ Asset Mgmt  │           │
        └───────┬──────┘           │
                │                  │
        ────────┴──────            │
        │★ Smart Backup│           │
        └───────┬──────┘           │
                │                  │
        ────────┴──────            │
        │★ Remote Ops   ←─────────┼──────── Web UI
        └───────┬──────┘           │
                │                  │
        ────────┴──────            │
        │★ Central Logs│           │
        └───────┬──────┘           │
                │                  │
        ────────┴──────            │
        │★ AI Analytics│           │
        └──────────────┘           │
                                   │
        ────────────────────────────────
        │ Python FastAPI + ML Engine        │
        │ PostgreSQL + RabbitMQ             │
        ────────────────────────────────
                                   │
                       ┌───────────┼───────────┐
                       ▼           ▼           ▼
                ┌──────────┐ ┌──────────┐ ┌──────────┐
                │Go Agent 1│ │Go Agent 2│ │Go Agent n│
                └──────────┘ └──────────┘ └──────────┘
```

Each module has a clear:
- **Core functions**: Solves specific business problems
- **Technical implementation**: Corresponding technology stack and components
- **Business value**: Specific benefits for the operations team

This modular design enables the system to simultaneously meet:
✅ **Real-time**: File changes respond in seconds
✅ **Reliability**: Asynchronous queue + persistent storage
✅ **Intelligence**: AI-driven predictive analysis
✅ **Scalability**: Microservices architecture, horizontal scaling

---

## Implementation Priority Suggestions

1. **Phase 1**: Asset Management + Basic Backup Functionality
   - Establish communication between Agent and Control Plane
   - Implement asset auto-discovery and heartbeat monitoring
   - Complete file monitoring and basic backup workflow

2. **Phase 2**: Centralized Logs + Remote Operations
   - Log collection and querying
   - Remote command delivery and execution
   - Basic Web UI functionality

3. **Phase 3**: AI Intelligent Analysis
   - Log anomaly detection
   - Backup performance prediction
   - Capacity planning recommendations

4. **Phase 4**: Advanced Features
   - Backup verification and recovery testing
   - Intelligent alerting and automated response
   - Multi-tenancy and permission management
