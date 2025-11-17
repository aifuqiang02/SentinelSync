#!/usr/bin/env pwsh

<#
.SYNOPSIS
    SentinelSync 服务重启脚本

.DESCRIPTION
    重启 SentinelSync 项目的服务，支持重启所有服务或指定的单个服务。

.PARAMETER ServiceName
    要重启的服务名称。如果未指定，将显示可用服务列表。

.PARAMETER All
    重启所有服务。

.EXAMPLE
    .\restart.ps1
    显示可用服务列表

.EXAMPLE
    .\restart.ps1 -ServiceName "management-server"
    重启管理服务器

.EXAMPLE
    .\restart.ps1 -All
    重启所有服务
#>

param(
    [string]$ServiceName,
    [switch]$All
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

# 显示可用服务
function Show-AvailableServices {
    $services = Get-AvailableServices
    Write-ColorOutput "可用服务列表:" "Info"
    Write-ColorOutput ""

    for ($i = 0; $i -lt $services.Count; $i++) {
        $service = $services[$i]
        $type = if ($service.essential) { "核心" } else { "应用" }
        $marker = if ($service.essential) { "✓" } else { "◦" }
        Write-Host "  $marker $($service.name.PadRight(18)) $([$type].PadRight(6)) $($service.description)"
    }

    Write-ColorOutput ""
    Write-ColorOutput "使用方法:" "Info"
    Write-ColorOutput "• 重启所有服务: .\restart.ps1 -All" "Info"
    Write-ColorOutput "• 重启单个服务: .\restart.ps1 -ServiceName <服务名>" "Info"
    Write-ColorOutput "• 重启核心服务: .\restart.ps1 -ServiceName postgres" "Info"
    Write-ColorOutput "• 重启前端界面: .\restart.ps1 -ServiceName web-ui" "Info"
}

# 验证服务名称
function Test-ServiceName {
    param([string]$Name)

    $services = Get-AvailableServices
    $service = $services | Where-Object { $_.name -eq $Name }

    if (-not $service) {
        Write-ColorOutput "服务 '$Name' 不存在" "Error"
        Write-ColorOutput "使用 .\restart.ps1 查看可用服务" "Info"
        return $false
    }

    return $true
}

# 重启所有服务
function Restart-AllServices {
    Write-ColorOutput "重启所有服务..." "Info"
    Write-ColorOutput "警告: 这将重启所有 SentinelSync 服务" "Warning"

    $confirm = Read-Host "确认重启所有服务? (y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-ColorOutput "操作已取消" "Info"
        return
    }

    try {
        Write-ColorOutput "停止所有服务..." "Info"
        docker-compose down

        Write-ColorOutput "启动所有服务..." "Info"
        docker-compose up -d

        Write-ColorOutput "等待服务就绪..." "Info"
        Start-Sleep 10

        Write-ColorOutput "检查服务状态..." "Info"
        docker-compose ps

        Write-ColorOutput "所有服务重启完成" "Success"
    }
    catch {
        Write-ColorOutput "重启失败: $($_.Exception.Message)" "Error"
        exit 1
    }
}

# 重启指定服务
function Restart-SingleService {
    param([string]$Name)

    Write-ColorOutput "重启服务: $Name" "Info"

    try {
        # 检查服务是否运行
        $status = docker-compose ps --services --filter status=running
        if ($Name -notin $status) {
            Write-ColorOutput "服务 '$Name' 当前未运行，将尝试启动" "Warning"
        }

        # 重启服务
        Write-ColorOutput "停止服务 $Name..." "Info"
        docker-compose stop $Name

        Write-ColorOutput "启动服务 $Name..." "Info"
        docker-compose start $Name

        Write-ColorOutput "等待服务就绪..." "Info"
        Start-Sleep 5

        # 检查服务状态
        $serviceStatus = docker-compose ps $Name
        Write-ColorOutput "服务状态:" "Info"
        Write-Host $serviceStatus

        Write-ColorOutput "服务 '$Name' 重启完成" "Success"

        # 根据服务类型提供提示信息
        switch ($Name) {
            "management-server" {
                Write-ColorOutput "访问地址: http://localhost:8000" "Info"
            }
            "web-ui" {
                Write-ColorOutput "访问地址: http://localhost:5173" "Info"
            }
            "rabbitmq" {
                Write-ColorOutput "管理界面: http://localhost:15672" "Info"
            }
        }
    }
    catch {
        Write-ColorOutput "重启服务失败: $($_.Exception.Message)" "Error"
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

# 主函数
function Main {
    Write-ColorOutput "🔄 SentinelSync 服务重启脚本" "Success"
    Write-ColorOutput ""

    # 切换到docker目录
    Set-Location $PSScriptRoot

    # 检查前置条件
    Test-Prerequisites

    # 重启所有服务
    if ($All) {
        Restart-AllServices
        return
    }

    # 如果没有指定服务名称，显示可用服务
    if ([string]::IsNullOrEmpty($ServiceName)) {
        Show-AvailableServices
        return
    }

    # 验证服务名称
    if (-not (Test-ServiceName $ServiceName)) {
        Show-AvailableServices
        exit 1
    }

    # 重启指定服务
    Restart-SingleService $ServiceName
}

# 执行主函数
Main