@echo off
chcp 65001 >nul
title 安装 Dozzle

echo ========================================
echo    安装 Dozzle - 实时日志查看器
echo ========================================
echo.

echo 📦 正在安装 Dozzle...
docker run -d ^
  --name dozzle ^
  --restart=always ^
  -p 8888:8080 ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  amir20/dozzle:latest

echo.
echo ✅ Dozzle 安装完成！
echo.
echo 🌐 访问地址：http://localhost:8888
echo.
echo 🎯 功能：
echo    - 实时查看所有容器日志
echo    - 搜索日志内容
echo    - 多容器同时查看
echo    - 自动刷新
echo.
pause
