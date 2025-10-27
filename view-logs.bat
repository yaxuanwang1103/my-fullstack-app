@echo off
chcp 65001 >nul
title 查看日志

echo ========================================
echo    日志查看工具
echo ========================================
echo.
echo 选择要查看的日志：
echo.
echo 1. 所有服务日志
echo 2. Frontend 日志
echo 3. Backend-A 日志
echo 4. Backend-B 日志
echo 5. PostgreSQL 日志
echo 6. 保存日志到文件
echo 7. 查看错误日志
echo 0. 退出
echo.

set /p choice=请输入选项 (0-7): 

if "%choice%"=="1" (
    echo.
    echo 📝 查看所有服务日志（按 Ctrl+C 停止）...
    docker-compose logs -f
)

if "%choice%"=="2" (
    echo.
    echo 📝 查看 Frontend 日志（按 Ctrl+C 停止）...
    docker-compose logs -f frontend
)

if "%choice%"=="3" (
    echo.
    echo 📝 查看 Backend-A 日志（按 Ctrl+C 停止）...
    docker-compose logs -f backend-a
)

if "%choice%"=="4" (
    echo.
    echo 📝 查看 Backend-B 日志（按 Ctrl+C 停止）...
    docker-compose logs -f backend-b
)

if "%choice%"=="5" (
    echo.
    echo 📝 查看 PostgreSQL 日志（按 Ctrl+C 停止）...
    docker-compose logs -f postgres
)

if "%choice%"=="6" (
    echo.
    echo 💾 保存日志到文件...
    if not exist logs mkdir logs
    docker-compose logs > logs\all-logs-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt
    echo ✅ 日志已保存到 logs 目录
    pause
)

if "%choice%"=="7" (
    echo.
    echo 🔍 查看错误日志...
    docker-compose logs | findstr /i "error exception failed"
    echo.
    pause
)

if "%choice%"=="0" (
    exit
)
