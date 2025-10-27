@echo off
chcp 65001 >nul
title 安装 Portainer

echo ========================================
echo    安装 Portainer - Docker 可视化管理
echo ========================================
echo.

echo 📦 正在安装 Portainer...
docker volume create portainer_data

docker run -d ^
  -p 9000:9000 ^
  -p 9443:9443 ^
  --name portainer ^
  --restart=always ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  -v portainer_data:/data ^
  portainer/portainer-ce:latest

echo.
echo ✅ Portainer 安装完成！
echo.
echo 🌐 访问地址：
echo    HTTP:  http://localhost:9000
echo    HTTPS: https://localhost:9443
echo.
echo 📝 首次访问需要：
echo    1. 创建管理员账号
echo    2. 选择 "Docker" 环境
echo    3. 开始使用
echo.
echo 🎯 功能：
echo    - 查看所有容器状态
echo    - 实时查看日志
echo    - 监控资源使用
echo    - 查看容器统计
echo.
pause
