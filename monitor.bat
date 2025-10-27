@echo off
chcp 65001 >nul
title 服务监控

:loop
cls
echo ========================================
echo    服务监控 - %date% %time%
echo ========================================
echo.

echo 📊 容器状态：
docker-compose ps
echo.

echo 🔍 服务健康检查：
curl -s http://localhost:5173 >nul 2>&1 && echo ✅ Frontend: 运行中 || echo ❌ Frontend: 停止
curl -s http://localhost:3000/health >nul 2>&1 && echo ✅ Backend-A: 运行中 || echo ❌ Backend-A: 停止
curl -s http://localhost:4000/health >nul 2>&1 && echo ✅ Backend-B: 运行中 || echo ❌ Backend-B: 停止
echo.

echo 💾 资源使用：
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo.

echo 按 Ctrl+C 停止监控...
timeout /t 30 /nobreak >nul
goto loop
