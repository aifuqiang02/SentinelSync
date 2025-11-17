#!/usr/bin/env pwsh

<#
.SYNOPSIS
    SentinelSync 服务停止脚本

.DESCRIPTION
    停止 SentinelSync 项目的服务，支持停止所有服务或指定的单个服务。

.PARAMETER ServiceName
    要停止的服务名称。如果未指定，将停止所有服务。

.PARAMETER ForceRemove
    强制删除容器和网络（完全清理）。

.EXAMPLE
    .\stop.ps1
    停止所有服务

.EXAMPLE
    .\stop.ps1 -ServiceName "management-server"
    停止管理服务器

.EXAMPLE
    .\stop.ps1 -ForceRemove
    停止并删除所有容器和网络
#>

param(
    [string]$ServiceName,
    [switch]$ForceRemove
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

# 获取所有可用的服务
function Get-AvailableServices {
    $services = @(
        @{ name = "postgres"; description = "PostgreSQL 数据库"; essential = $true },
        @{ name = "rabbitmq"; description = "RabbitMQ 消息队列"; essential = $true },
        @{ name = "management-server"; description = "FastAPI 管理服务器"; essential = $false },
        @{ name = "hasher"; description = "Go Hasher 服务"; essential = $false },
        @{ name = "transporter"; description = "Go Transporter 服务"; essential = $false },
        @{ name = "log-processor"; description = "Go 日志处理器"; essential = $false },
        @{ name = "web-ui"; description = "Vue 前端界面"; essential = $false }
    )
    return $services
}

# 显示当前运行的服务
function Show-RunningServices {
    Write-ColorOutput "当前运行的服务:" "Info"
    try {
        $runningServices = docker-compose ps --filter "status=running"
        if ([string]::IsNullOrWhiteSpace($runningServices)) {
            Write-ColorOutput "没有运行中的服务" "Warning"
        } else {
            Write-Host $runningServices
        }
    }
    catch {
        Write-ColorOutput "无法获取服务状态" "Error"
    }
    Write-ColorOutput ""
}

# 验证服务名称
function Test-ServiceName {
    param([string]$Name)

    $services = Get-AvailableServices
    $service = $services | Where-Object { $_.name -eq $Name }

    if (-not $service) {
        Write-ColorOutput "服务 '$Name' 不存在" "Error"
        Write-ColorOutput "可用服务: $($services.name -join ', ')" "Info"
        return $false
    }

    return $true
}

# 停止所有服务
function Stop-AllServices {
    if ($ForceRemove) {
        Write-ColorOutput "停止并删除所有服务和网络..." "Warning"
        Write-ColorOutput "⚠️  这将删除所有数据卷（数据库数据也会删除）" "Error"

        $confirm = Read-Host "确认停止并删除所有服务? (yes/NO)"
        if ($confirm -ne "yes") {
            Write-ColorOutput "操作已取消" "Info"
            return
        }

        try {
            Write-ColorOutput "停止并删除所有容器..." "Info"
            docker-compose down -v

            Write-ColorOutput "清理未使用的资源..." "Info"
            docker system prune -f

            Write-ColorOutput "所有服务已停止并删除" "Success"
        }
        catch {
            Write-ColorOutput "删除服务失败: $($_.Exception.Message)" "Error"
            exit 1
        }
    }
    else {
        Write-ColorOutput "停止所有服务..." "Info"

        try {
            Write-ColorOutput "停止服务中..." "Info"
            docker-compose down

            Write-ColorOutput "检查服务状态..." "Info"
            $remaining = docker-compose ps --filter "status=running"
            if ([string]::IsNullOrWhiteSpace($remaining)) {
                Write-ColorOutput "所有服务已停止" "Success"
            } else {
                Write-ColorOutput "部分服务仍在运行:" "Warning"
                Write-Host $remaining
            }
        }
        catch {
            Write-ColorOutput "停止服务失败: $($_.Exception.Message)" "Error"
            exit 1
        }
    }
}

# 停止指定服务
function Stop-SingleService {
    param([string]$Name)

    Write-ColorOutput "停止服务: $Name" "Info"

    try {
        # 检查服务是否运行
        $status = docker-compose ps --format "table {{.Name}}\t{{.Status}}"
        if ($status -notmatch $Name -or $status -match "exited") {
            Write-ColorOutput "服务 '$Name' 当前未运行" "Warning"
            return
        }

        # 停止服务
        Write-ColorOutput "停止服务 $Name..." "Info"
        docker-compose stop $Name

        # 检查是否成功停止
        Start-Sleep 2
        $newStatus = docker-compose ps $Name
        Write-ColorOutput "服务状态:" "Info"
        Write-Host $newStatus

        if ($newStatus -match "exited") {
            Write-ColorOutput "服务 '$Name' 已成功停止" "Success"
        } else {
            Write-ColorOutput "服务 '$Name' 可能仍在运行" "Warning"
        }
    }
    catch {
        Write-ColorOutput "停止服务失败: $($_.Exception.Message)" "Error"
        exit 1
    }
}

# 检查前置条件
function Test-Prerequisites {
    try {
        $null = docker --version
        $null = docker-compose --version
        # 检查docker-compose.yml是否存在
        if (-not (Test-Path "docker-compose.yml")) {
            Write-ColorOutput "未找到 docker-compose.yml 文件" "Error"
            exit 1
        }
    }
    catch {
        Write-ColorOutput "Docker 或 Docker Compose 未安装" "Error"
        exit 1
    }
}

# 显示服务使用情况
function Show-Usage {
    $services = Get-AvailableServices
    Write-ColorOutput "可用服务:" "Info"
    ($services | ForEach-Object { $_.name }) -join ", "
    Write-ColorOutput ""
    Write-ColorOutput "使用方法:" "Info"
    Write-ColorOutput "• 停止所有服务: .\stop.ps1" "Info"
    Write-ColorOutput "• 停止单个服务: .\stop.ps1 -ServiceName <服务名>" "Info"
    Write-ColorOutput "• 完全清理: .\stop.ps1 -ForceRemove" "Info"
}

# 主函数
function Main {
    Write-ColorOutput "🛑 SentinelSync 服务停止脚本" "Success"
    Write-ColorOutput ""

    # 切换到docker目录
    Set-Location $PSScriptRoot

    # 检查前置条件
    Test-Prerequisites

    # 显示当前运行的服務
    Show-RunningServices

    # 停止所有服务
    if ([string]::IsNullOrEmpty($ServiceName)) {
        Stop-AllServices
        return
    }

    # 验证服务名称
    if (-not (Test-ServiceName $ServiceName)) {
        Show-Usage
        exit 1
    }

    # 停止指定服务
    Stop-SingleService $ServiceName
}

# 执行主函数
Main