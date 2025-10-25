@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   🐳 Docker 快速启动脚本
echo ========================================
echo.

echo 🔍 检查端口占用...
echo.

REM 检查并停止占用 5433 端口的进程（PostgreSQL）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5433 ^| findstr LISTENING') do (
    echo ⚠️  端口 5433 被占用，正在停止进程...
    tasklist /FI "PID eq %%a" | findstr postgres >nul
    if not errorlevel 1 (
        echo    停止 PostgreSQL 服务...
        net stop postgresql-x64-15 >nul 2>&1
        net stop postgresql-x64-14 >nul 2>&1
        net stop postgresql-x64-13 >nul 2>&1
    ) else (
        taskkill /F /PID %%a >nul 2>&1
    )
    timeout /t 2 >nul
)

REM 检查其他端口
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING') do (
    echo ⚠️  端口 5173 被占用，正在停止进程...
    taskkill /F /PID %%a >nul 2>&1
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
    echo ⚠️  端口 3000 被占用，正在停止进程...
    taskkill /F /PID %%a >nul 2>&1
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do (
    echo ⚠️  端口 4000 被占用，正在停止进程...
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo 🚀 启动 Docker 容器...
echo.

docker-compose down >nul 2>&1
docker-compose up -d

if %errorlevel% equ 0 (
    echo.
    echo ✅ Docker 容器启动成功！
    echo.
    echo 📱 访问地址：
    echo    前端:      http://localhost:5173
    echo    后端A:     http://localhost:3000
    echo    后端B:     http://localhost:4000
    echo    PostgreSQL: localhost:5433
    echo.
    echo 📊 查看日志: docker-compose logs -f
    echo 🛑 停止服务: docker-compose down
) else (
    echo.
    echo ❌ Docker 容器启动失败
    echo 请查看错误信息
)

echo.
pause
