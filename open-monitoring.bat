@echo off
chcp 65001 >nul
title 打开所有监控界面

echo ========================================
echo    打开所有监控界面
echo ========================================
echo.

echo 🚀 正在打开监控工具...
echo.

REM 打开监控仪表板
echo 📊 打开监控仪表板...
start "" "%~dp0监控仪表板.html"
timeout /t 2 /nobreak >nul

REM 打开 Portainer
echo 🐳 打开 Portainer...
start "" "http://localhost:9000"
timeout /t 2 /nobreak >nul

REM 打开 Dozzle
echo 📝 打开 Dozzle...
start "" "http://localhost:8888"
timeout /t 2 /nobreak >nul

echo.
echo ✅ 所有监控界面已打开！
echo.
echo 📋 监控工具列表：
echo    1. 监控仪表板 - 统计概览
echo    2. Portainer (http://localhost:9000) - 容器管理
echo    3. Dozzle (http://localhost:8888) - 实时日志
echo.
echo 💡 提示：
echo    - 首次使用 Portainer 需要创建管理员账号
echo    - Dozzle 无需登录，直接使用
echo    - 监控仪表板每 10 秒自动刷新
echo.
pause
