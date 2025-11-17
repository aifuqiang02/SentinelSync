# Development Environment Setup Guide (Windows)

This guide is for developers and describes how to compile and launch each component of the SentinelSync project in a Windows environment.

## Prerequisites

- Go language environment installed (version 1.20+)
- Python language environment installed (version 3.9+)
- Node.js and npm/yarn installed (for Vue frontend)
- Docker and Docker Compose installed
- Git

## 1. Clone the Repository

```bash
git clone <your-repository-url>
cd SentinelSync
```

## 2. Start Core Infrastructure (using Docker Compose)

SentinelSync relies on PostgreSQL database and RabbitMQ message queue. Use Docker Compose to quickly start these services.

```bash
cd docker
docker-compose up -d postgres rabbitmq
```

Verify that the services are running:

```bash
docker-compose ps
```

## 3. Initialize the Database

Database initialization scripts are located in the `scripts/sql/` directory. You need to create the database first and then execute the initialization scripts.

1.  **Create Database**: You can use pgAdmin or directly connect to the PostgreSQL database in Docker via the `psql` command-line tool to create it.
    Default connection information: `localhost:`5432`, Username: `postgres`, Password: `postgres`

    ```bash
docker exec -it docker_postgres_1 psql -U postgres
CREATE DATABASE sentinelsync;
\q
    ```

2.  **Execute SQL Scripts**: Import all `.sql` files from the `scripts/sql/` directory into the `sentinelsync` database in order.

    ```bash
cd ..\scripts\sql
# Windows Command Prompt example (may need adjustments for specific shell)
FOR /f %i IN ('dir /b *.sql') DO ( psql -h localhost -p `5432` -U postgres -d sentinelsync -f %i )

# Or for PowerShell example (requires psql to be in PATH or provide full path)
# Get-ChildItem -Path . -Filter "*.sql" | ForEach-Object { psql -h localhost -p `5432` -U postgres -d sentinelsync -f $_.FullName }
    ```

## 4. Compile and Start Go Services

### Go Agent

1.  Navigate to the Agent directory:
    ```bash
    cd ..\agent
    ```

2.  Compile the Agent:
    ```bash
    go build -o sentinel-agent.exe ./cmd
    ```

3.  Run the Agent (requires RabbitMQ connection information, e.g., environment variables or config file)
    ```bash
    # Example: Set environment variables
    set RABBITMQ_SERVER_URL=amqp://guest:guest@localhost:5672/
    .\sentinel-agent.exe
    ```

4.  **Use Air for Hot Reload Development**:
    When developing the Agent, to improve efficiency, you can use the [Air](https://github.com/air-verse/air) tool to achieve automatic compilation and restart (hot reload) after code changes.

    a.  **Install Air**：
        ```bash
        go install github.com/air-verse/air@latest
        ```
        Please ensure that the `bin` directory within your `GOPATH` (e.g., `C:\Users\<your_username>\go\bin`) has been added to your system `PATH` environment variable, otherwise the `air` command will not be found. You can check your `GOPATH` by executing `go env GOPATH` in the command line.

    b.  **Run Air**：
        In the root directory of your `agent` service, run the `air` command:
        ```bash
        air
        ```
        `Air` will automatically monitor code file changes, recompile, and restart the Agent after files are saved. If you encounter a `no Go files` warning but the Agent actually starts, this warning can usually be ignored.

### Go Services (Hasher, Transporter, Log Processor)

1.  Navigate to the `services` directory:
    ```bash
    cd ..\services
    ```

2.  Compile and run relevant services (e.g., Hasher):
    ```bash
    cd hasher
    go build -o hasher.exe .
    set RABBITMQ_SERVER_URL=amqp://guest:guest@localhost:5672/
    set DATABASE_URL="host=localhost port=5432 user=postgres password=postgres dbname=sentinelsync sslmode=disable"
    .\hasher.exe
    ```
    Repeat similar steps for `transporter` and `log_processor`.

3.  **Use Air for Hot Reload Development**:
    Similar to the Go Agent, you can also configure `Air` for `Hasher`, `Transporter`, and `Log Processor` services to enable hot reloading.

    a.  **Configure Air (air.toml) - Example for Hasher**:
        In the root directory of the `hasher` service (e.g., `D:\git-projects\SentinelSync\services\hasher`), create an `air.toml` file with the following content:

        ```toml
        # air.toml for Hasher service
        root = "."
        tmp_dir = "tmp"

        [build]
          # Compile in the current service directory (e.g., hasher directory)
          working_dir = "."
          # Build command: compile the current directory, output to tmp/hasher.exe
          cmd = "go build -o tmp/hasher.exe ."
          # Path to the compiled executable (relative to Air's root directory)
          bin = "tmp/hasher.exe"
          env = [
            "RABBITMQ_SERVER_URL=amqp://guest:guest@localhost:5672/",
            "DATABASE_URL=\"host=localhost port=5432 user=postgres password=postgres dbname=sentinelsync sslmode=disable\""
          ]
          stop_on_error = true
          log = "air_build.log"

        [run]
          cmd = "tmp/hasher.exe"
          log = "air_run.log"

        [misc]
          clean_on_exit = true
        ```

    b.  **Run Air**：
        In the root directory of the `hasher` service, run the `air` command:
        ```bash
        air
        ```
        `Air` will automatically monitor code file changes, recompile, and restart the service. The configuration for other Go services (e.g., `transporter`, `log_processor`) is similar; just adjust the `cmd` and `bin` paths according to the service name.

## 5. Start Python FastAPI Backend

1.  Navigate to the management server directory:
    ```bash
    cd ..\control_plane\management_server
    ```

2.  Install Python dependencies:
    ```bash
    pip install -r requirements.txt
    ```

3.  Run the FastAPI application:
    ```bash
    uvicorn main:app --reload
    ```

    The backend will run on `http://localhost:8000`.

## 6. Start Vue Frontend

1.  Navigate to the Web UI directory:
    ```bash
    cd ..\control_plane\web_ui
    ```

2.  Install Node.js dependencies:
    ```bash
    npm install
    # Or yarn
    ```

3.  Start the development server:
    ```bash
    npm run dev
    # Or yarn dev
    ```

    The frontend will run on `http://localhost:5173` (specific port may vary depending on configuration).

## 7. Clean Up Environment

Stop services started with Docker Compose:

```bash
cd ..\..\docker
docker-compose down
```
