@echo off
chcp 65001 >nul
title 启动完整监控系统

echo ========================================
echo    启动完整监控系统
echo ========================================
echo.

echo 📋 步骤 1: 检查 Docker 是否运行...
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)
echo ✅ Docker 正在运行
echo.

echo 📋 步骤 2: 启动应用容器...
docker-compose up -d
echo ✅ 应用容器已启动
echo.

echo 📋 步骤 3: 检查 Portainer...
docker ps | findstr portainer >nul 2>&1
if errorlevel 1 (
    echo 📦 安装 Portainer...
    call install-portainer.bat
) else (
    echo ✅ Portainer 已安装
)
echo.

echo 📋 步骤 4: 检查 Dozzle...
docker ps | findstr dozzle >nul 2>&1
if errorlevel 1 (
    echo 📦 安装 Dozzle...
    call install-dozzle.bat
) else (
    echo ✅ Dozzle 已安装
)
echo.

echo 📋 步骤 5: 等待服务启动...
timeout /t 5 /nobreak >nul
echo.

echo 📋 步骤 6: 打开所有监控界面...
call open-monitoring.bat

echo.
echo ========================================
echo    🎉 完整监控系统已启动！
echo ========================================
echo.
echo 📊 监控工具：
echo    1. 监控仪表板 - 已在浏览器打开
echo    2. Portainer - http://localhost:9000
echo    3. Dozzle - http://localhost:8888
echo.
echo 🌐 应用访问：
echo    前端: http://localhost:5173
echo    后端A: http://localhost:3000
echo    后端B: http://localhost:4000
echo.
echo 💡 提示：
echo    - 使用 Ctrl+C 可以停止此脚本
echo    - 容器会继续在后台运行
echo    - 使用 docker-compose down 停止所有容器
echo.
pause
