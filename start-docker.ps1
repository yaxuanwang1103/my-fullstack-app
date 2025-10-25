# Docker 智能启动脚本 - 自动检测端口冲突
# 作者: AI Assistant
# 日期: 2024-10-25

Write-Host "🐳 Docker 智能启动脚本" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 定义需要检查的端口
$ports = @{
    "前端" = 5173
    "后端A" = 3000
    "后端B" = 4000
    "PostgreSQL" = 5433
}

# 检查端口是否被占用
function Test-PortInUse {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

# 查找可用端口
function Find-AvailablePort {
    param([int]$StartPort)
    $port = $StartPort
    while (Test-PortInUse -Port $port) {
        $port++
        if ($port -gt ($StartPort + 100)) {
            throw "无法找到可用端口（从 $StartPort 开始尝试了 100 个端口）"
        }
    }
    return $port
}

# 获取占用端口的进程信息
function Get-PortProcess {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connection) {
        $processId = $connection.OwningProcess
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        return $process.ProcessName
    }
    return $null
}

Write-Host "🔍 检查端口占用情况..." -ForegroundColor Yellow
Write-Host ""

$hasConflict = $false
$conflictPorts = @()

foreach ($service in $ports.Keys) {
    $port = $ports[$service]
    if (Test-PortInUse -Port $port) {
        $hasConflict = $true
        $processName = Get-PortProcess -Port $port
        Write-Host "❌ $service 端口 $port 被占用" -ForegroundColor Red
        Write-Host "   占用进程: $processName" -ForegroundColor Gray
        $conflictPorts += @{Service = $service; Port = $port; Process = $processName}
    } else {
        Write-Host "✅ $service 端口 $port 可用" -ForegroundColor Green
    }
}

Write-Host ""

if ($hasConflict) {
    Write-Host "⚠️  发现端口冲突！" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "请选择解决方案：" -ForegroundColor Cyan
    Write-Host "1. 自动停止占用端口的进程（推荐）" -ForegroundColor White
    Write-Host "2. 使用其他可用端口" -ForegroundColor White
    Write-Host "3. 手动处理后重新运行" -ForegroundColor White
    Write-Host "4. 退出" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "请输入选项 (1-4)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "🛑 正在停止占用端口的进程..." -ForegroundColor Yellow
            foreach ($conflict in $conflictPorts) {
                $port = $conflict.Port
                $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
                if ($connection) {
                    $processId = $connection.OwningProcess
                    $processName = (Get-Process -Id $processId).ProcessName
                    
                    Write-Host "   停止进程: $processName (PID: $processId)" -ForegroundColor Gray
                    
                    # 特殊处理：如果是 PostgreSQL 服务
                    if ($processName -like "*postgres*") {
                        Stop-Service postgresql* -Force -ErrorAction SilentlyContinue
                        Write-Host "   已停止 PostgreSQL 服务" -ForegroundColor Green
                    } else {
                        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                        Write-Host "   已停止进程" -ForegroundColor Green
                    }
                }
            }
            Start-Sleep -Seconds 2
        }
        "2" {
            Write-Host ""
            Write-Host "🔄 寻找可用端口..." -ForegroundColor Yellow
            
            # 修改 docker-compose.yml 使用新端口
            $newPorts = @{}
            foreach ($service in $ports.Keys) {
                $originalPort = $ports[$service]
                if (Test-PortInUse -Port $originalPort) {
                    $newPort = Find-AvailablePort -StartPort ($originalPort + 1)
                    $newPorts[$service] = $newPort
                    Write-Host "   $service : $originalPort → $newPort" -ForegroundColor Cyan
                }
            }
            
            Write-Host ""
            Write-Host "⚠️  注意：需要手动修改 docker-compose.yml 中的端口映射" -ForegroundColor Yellow
            Write-Host "建议使用方案 1 或 3" -ForegroundColor Yellow
            exit
        }
        "3" {
            Write-Host ""
            Write-Host "📋 请手动处理以下端口冲突：" -ForegroundColor Yellow
            foreach ($conflict in $conflictPorts) {
                Write-Host "   $($conflict.Service) 端口 $($conflict.Port) - 进程: $($conflict.Process)" -ForegroundColor White
            }
            Write-Host ""
            Write-Host "处理方法：" -ForegroundColor Cyan
            Write-Host "1. 打开任务管理器，结束相关进程" -ForegroundColor White
            Write-Host "2. 或运行: taskkill /F /IM <进程名>.exe" -ForegroundColor White
            Write-Host "3. 或运行: Stop-Service <服务名>" -ForegroundColor White
            exit
        }
        "4" {
            Write-Host "已取消" -ForegroundColor Gray
            exit
        }
        default {
            Write-Host "无效选项" -ForegroundColor Red
            exit
        }
    }
}

Write-Host ""
Write-Host "🚀 启动 Docker 容器..." -ForegroundColor Green
Write-Host ""

# 停止现有容器
docker-compose down 2>$null

# 启动容器
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Docker 容器启动成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 访问地址：" -ForegroundColor Cyan
    Write-Host "   前端:      http://localhost:5173" -ForegroundColor White
    Write-Host "   后端A:     http://localhost:3000" -ForegroundColor White
    Write-Host "   后端B:     http://localhost:4000" -ForegroundColor White
    Write-Host "   PostgreSQL: localhost:5433" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 查看日志: docker-compose logs -f" -ForegroundColor Gray
    Write-Host "🛑 停止服务: docker-compose down" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Docker 容器启动失败" -ForegroundColor Red
    Write-Host "请查看错误信息并重试" -ForegroundColor Yellow
}

Write-Host ""
