#!/usr/bin/env pwsh

<#
.SYNOPSIS
    SentinelSync 项目统一启动脚本

.DESCRIPTION
    一键启动 SentinelSync 项目的所有服务，包括：
    - PostgreSQL 数据库
    - RabbitMQ 消息队列
    - FastAPI 管理服务器
    - Go 微服务 (Hasher, Transporter, Log Processor)
    - Vue 前端界面

.PARAMETER SkipDatabaseInit
    跳过数据库初始化步骤

.PARAMETER ForceRebuild
    强制重新构建所有Docker镜像

.EXAMPLE
    .\start.ps1
    启动所有服务

.EXAMPLE
    .\start.ps1 -SkipDatabaseInit
    启动服务但跳过数据库初始化

.EXAMPLE
    .\start.ps1 -ForceRebuild
    重新构建并启动所有服务
#>

param(
    [switch]$SkipDatabaseInit,
    [switch]$ForceRebuild
)

# 设置错误时停止
$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Level = "Info"  # Info, Success, Warning, Error
    )

    $color = switch ($Level) {
        "Info" { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }

    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $color
}

# 检查前置条件
function Test-Prerequisites {
    Write-ColorOutput "检查前置条件..." "Info"

    # 检查 Docker
    try {
        $dockerVersion = docker --version
        Write-ColorOutput "✓ Docker: $dockerVersion" "Success"
    }
    catch {
        Write-ColorOutput "✗ Docker 未安装或未启动" "Error"
        exit 1
    }

    # 检查 Docker Compose
    try {
        $composeVersion = docker-compose --version
        Write-ColorOutput "✓ Docker Compose: $composeVersion" "Success"
    }
    catch {
        Write-ColorOutput "✗ Docker Compose 未安装" "Error"
        exit 1
    }

    Write-ColorOutput "前置条件检查完成" "Success"
}

# 初始化数据库
function Initialize-Database {
    if ($SkipDatabaseInit) {
        Write-ColorOutput "跳过数据库初始化" "Warning"
        return
    }

    Write-ColorOutput "初始化数据库..." "Info"

    # 检查数据库是否已初始化
    try {
        $result = docker exec development-postgres-1 psql -U sentinel -d sentinelsync -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>$null
        if ($result -and $result.Trim() -gt 0) {
            Write-ColorOutput "数据库已初始化，跳过初始化步骤" "Info"
            return
        }
    }
    catch {
        Write-ColorOutput "数据库未初始化或无法连接，开始初始化..." "Warning"
    }

    # 启动数据库服务（如果未启动）
    Write-ColorOutput "启动 PostgreSQL 服务..." "Info"
    docker-compose up -d postgres

    # 等待数据库就绪
    $maxWait = 30
    $waited = 0
    while ($waited -lt $maxWait) {
        try {
            docker exec development-postgres-1 pg_isready -U sentinel -d sentinelsync >$null 2>&1
            break
        }
        catch {
            Start-Sleep 2
            $waited += 2
        }
    }

    if ($waited -ge $maxWait) {
        Write-ColorOutput "数据库启动超时" "Error"
        exit 1
    }

    Write-ColorOutput "数据库已就绪，执行初始化脚本..." "Info"

    # 执行SQL脚本
    $sqlScripts = Get-ChildItem -Path ".\sql" -Filter "*.sql" | Sort-Object Name
    foreach ($script in $sqlScripts) {
        Write-ColorOutput "执行: $($script.Name)" "Info"
        try {
            docker exec development-postgres-1 psql -U sentinel -d sentinelsync -f "/docker-entrypoint-initdb.d/$(($script | Split-Path -Leaf))"
        }
        catch {
            # 尝试从主机复制文件到容器并执行
            $containerPath = "/tmp/$(($script | Split-Path -Leaf))"
            docker cp $script.FullName "development-postgres-1:$containerPath"
            docker exec development-postgres-1 psql -U sentinel -d sentinelsync -f $containerPath
        }
    }

    Write-ColorOutput "数据库初始化完成" "Success"
}

# 启动所有服务
function Start-Services {
    Write-ColorOutput "启动所有服务..." "Info"

    # 构建参数
    $buildArgs = @()
    if ($ForceRebuild) {
        $buildArgs += "--build"
    }

    # 启动所有服务
    if ($buildArgs.Count -gt 0) {
        Write-ColorOutput "重新构建并启动服务..." "Info"
        docker-compose up -d --build
    }
    else {
        Write-ColorOutput "启动服务..." "Info"
        docker-compose up -d
    }

    Write-ColorOutput "服务启动命令已执行" "Success"
}

# 等待服务就绪
function Wait-ServicesReady {
    Write-ColorOutput "等待服务就绪..." "Info"

    $services = @(
        @{ name = "PostgreSQL"; port = 5432 },
        @{ name = "RabbitMQ Management"; port = 15672 },
        @{ name = "FastAPI Server"; port = 8000 },
        @{ name = "Vue Frontend"; port = 5173 }
    )

    $maxWait = 60
    $waited = 0

    foreach ($service in $services) {
        Write-ColorOutput "等待 $($service.name) 在端口 $($service.port)..." "Info"
        $serviceReady = $false

        while (-not $serviceReady -and $waited -lt $maxWait) {
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $tcpClient.Connect("localhost", $service.port)
                $tcpClient.Close()
                $serviceReady = $true
                Write-ColorOutput "✓ $($service.name) 已就绪" "Success"
            }
            catch {
                Start-Sleep 2
                $waited += 2
            }
        }

        if (-not $serviceReady) {
            Write-ColorOutput "⚠ $($service.name) 可能在端口 $($service.port) 上启动失败" "Warning"
        }
    }
}

# 显示状态
function Show-Status {
    Write-ColorOutput "服务状态:" "Info"
    Write-ColorOutput "$(docker-compose ps)" "Info"

    Write-ColorOutput ""
    Write-ColorOutput "🎉 SentinelStack 启动完成！" "Success"
    Write-ColorOutput ""
    Write-ColorOutput "访问地址:" "Info"
    Write-ColorOutput "• FastAPI 管理界面: http://localhost:8000" "Info"
    Write-ColorOutput "• FastAPI API 文档: http://localhost:8000/docs" "Info"
    Write-ColorOutput "• Vue 前端界面: http://localhost:5173" "Info"
    Write-ColorOutput "• RabbitMQ 管理界面: http://localhost:15672" "Info"
    Write-ColorOutput "  用户名: sentinel, 密码: changeme" "Warning"
    Write-ColorOutput ""
    Write-ColorOutput "管理命令:" "Info"
    Write-ColorOutput "• 查看日志: docker-compose logs -f [服务名]" "Info"
    Write-ColorOutput "• 重启服务: .\restart.ps1 [服务名]" "Info"
    Write-ColorOutput "• 停止所有: .\stop.ps1" "Info"
}

# 主函数
function Main {
    Write-ColorOutput "🚀 SentinelSync 统一启动脚本" "Success"
    Write-ColorOutput ""

    # 切换到docker目录
    Set-Location $PSScriptRoot

    # 执行启动流程
    Test-Prerequisites
    Initialize-Database
    Start-Services
    Wait-ServicesReady
    Show-Status
}

# 执行主函数
Main