#!/usr/bin/env pwsh

<#
.SYNOPSIS
    SentinelSync 生产环境部署脚本

.DESCRIPTION
    专为生产环境设计的安全部署脚本，不包含开发调试功能。

.PARAMETER ConfigFile
    配置文件路径，默认为 .env.production

.PARAMETER ForceRebuild
    强制重新构建所有镜像

.PARAMETER HealthCheck
    部署完成后执行健康检查

.EXAMPLE
    .\deploy.ps1 -ConfigFile .env.production -HealthCheck

.EXAMPLE
    .\deploy.ps1 -ForceRebuild -ConfigFile .env.custom
#>

param(
    [string]$ConfigFile = ".env.production",
    [switch]$ForceRebuild,
    [switch]$HealthCheck,
    [switch]$EnableMonitoring
)

# 设置错误时停止
$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ProductionOutput {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )

    $color = switch ($Level) {
        "Info" { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Security" { "Magenta" }
        default { "White" }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[PRODUCTION $timestamp] $Message" -ForegroundColor $color
}

# 安全检查
function Test-SecurityPrerequisites {
    Write-ProductionOutput "执行安全检查..." "Security"

    # 检查配置文件
    if (-not (Test-Path $ConfigFile)) {
        Write-ProductionOutput "配置文件 '$ConfigFile' 不存在" "Error"
        exit 1
    }

    # 检查是否包含默认密码
    $content = Get-Content $ConfigFile
    if ($content -match "changeme|default|password.*changeme") {
        Write-ProductionOutput "⚠️  检测到默认密码，请修改为安全密码" "Security"
        $continue = Read-Host "是否继续部署? (no/YES)"
        if ($continue -ne "YES") {
            exit 1
        }
    }

    # 检查Docker权限
    try {
        docker version >$null 2>&1
        Write-ProductionOutput "✓ Docker权限验证通过" "Success"
    }
    catch {
        Write-ProductionOutput "✗ Docker权限验证失败" "Error"
        exit 1
    }

    Write-ProductionOutput "安全检查完成" "Success"
}

# 验证生产环境配置
function Test-ProductionConfig {
    Write-ProductionOutput "验证生产环境配置..." "Info"

    # 加载环境变量
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }

    # 验证必要变量
    $requiredVars = @(
        "POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD",
        "RABBITMQ_USER", "RABBITMQ_PASSWORD",
        "SECRET_KEY", "APP_HOST", "APP_PORT"
    )

    foreach ($var in $requiredVars) {
        if (-not [Environment]::GetEnvironmentVariable($var)) {
            Write-ProductionOutput "✗ 缺少必要的环境变量: $var" "Error"
            exit 1
        }
    }

    Write-ProductionOutput "✓ 生产环境配置验证通过" "Success"
}

# 生产环境部署
function Deploy-Production {
    Write-ProductionOutput "开始生产环境部署..." "Info"

    # 设置环境变量
    $env:COMPOSE_PROJECT_NAME = "sentinelsync-prod"
    $env:COMPOSE_FILE = "docker-compose.yml"

    # 构建参数
    $buildArgs = @()
    if ($ForceRebuild) {
        $buildArgs += "--build"
    }

    # 停止旧服务（如果存在）
    Write-ProductionOutput "停止现有服务..." "Info"
    docker-compose --env-file $ConfigFile down

    # 启动生产服务
    if ($buildArgs.Count -gt 0) {
        Write-ProductionOutput "重新构建并启动服务..." "Info"
        docker-compose --env-file $ConfigFile up -d --build
    }
    else {
        Write-ProductionOutput "启动生产服务..." "Info"
        docker-compose --env-file $ConfigFile up -d
    }

    # 等待服务启动
    Write-ProductionOutput "等待服务启动..." "Info"
    Start-Sleep 30

    # 验证服务状态
    $services = docker-compose --env-file $ConfigFile ps
    if ($services -match "Up") {
        Write-ProductionOutput "✓ 生产服务启动成功" "Success"
        Write-ProductionOutput $services
    }
    else {
        Write-ProductionOutput "✗ 部分服务启动失败" "Error"
        Write-ProductionOutput $services
        exit 1
    }
}

# 健康检查
function Invoke-HealthCheck {
    if (-not $HealthCheck) {
        return
    }

    Write-ProductionOutput "执行健康检查..." "Info"

    # 检查关键服务
    $checks = @(
        @{ name = "Database"; cmd = "docker-compose exec -T postgres pg_isready -U $env:POSTGRES_USER" },
        @{ name = "RabbitMQ"; cmd = "docker-compose exec -T rabbitmq rabbitmq-diagnostics ping" },
        @{ name = "API"; cmd = "curl -f http://localhost:$env:APP_PORT/health" }
    )

    foreach ($check in $checks) {
        try {
            $result = Invoke-Expression $check.cmd 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-ProductionOutput "✓ $($check.name) 运行正常" "Success"
            }
            else {
                Write-ProductionOutput "✗ $($check.name) 健康检查失败" "Warning"
            }
        }
        catch {
            Write-ProductionOutput "✗ $($check.name) 无法访问" "Warning"
        }
    }
}

# 清理开发痕迹
function Remove-DevelopmentTraces {
    Write-ProductionOutput "清理开发痕迹..." "Security"

    # 移除开发容器（如果存在）
    $devContainers = docker ps -a --filter "name=dev" --format "{{.Names}}"
    if ($devContainers) {
        $devContainers | ForEach-Object {
            docker rm -f $_
            Write-ProductionOutput "移除开发容器: $_" "Security"
        }
    }

    # 清理开发镜像
    $devImages = docker images --filter "reference=*dev*" --format "{{.Repository}}:{{.Tag}}"
    if ($devImages) {
        $devImages | ForEach-Object {
            docker rmi $_ 2>$null
            Write-ProductionOutput "清理开发镜像: $_" "Security"
        }
    }

    Write-ProductionOutput "开发痕迹清理完成" "Success"
}

# 显示部署信息
function Show-DeploymentInfo {
    Write-ProductionOutput ""
    Write-ProductionOutput "🎉 SentinelSync 生产环境部署完成！" "Success"
    Write-ProductionOutput ""
    Write-ProductionOutput "生产环境访问地址:" "Info"
    Write-ProductionOutput "• FastAPI 服务: http://localhost:$env:APP_PORT" "Info"
    Write-ProductionOutput "• API 文档: http://localhost:$env:APP_PORT/docs" "Info"
    Write-ProductionOutput ""
    Write-ProductionOutput "管理命令:" "Info"
    Write-ProductionOutput "• 查看日志: docker-compose --env-file $ConfigFile logs -f" "Info"
    Write-ProductionOutput "• 服务状态: docker-compose --env-file $ConfigFile ps" "Info"
    Write-ProductionOutput "• 停止服务: docker-compose --env-file $ConfigFile down" "Info"
    Write-ProductionOutput ""
    Write-ProductionOutput "安全提醒:" "Security"
    Write-ProductionOutput "• 定期检查日志文件" "Security"
    Write-ProductionOutput "• 监控系统资源使用" "Security"
    Write-ProductionOutput "• 定期备份 postgres_data 数据卷" "Security"
}

# 主函数
function Main {
    Write-ProductionOutput "🚀 SentinelSync 生产环境部署" "Success"
    Write-ProductionOutput ""

    # 切换到production目录
    Set-Location $PSScriptRoot

    # 执行部署流程
    Test-SecurityPrerequisites
    Test-ProductionConfig
    Remove-DevelopmentTraces
    Deploy-Production
    Invoke-HealthCheck
    Show-DeploymentInfo
}

# 执行主函数
Main