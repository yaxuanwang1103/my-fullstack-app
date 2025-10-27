#!/bin/bash

echo "========================================="
echo "   安装监控工具"
echo "========================================="
echo ""

# 1. 启动应用容器
echo "步骤 1: 启动应用容器..."
docker-compose up -d
echo ""

# 2. 检查 Portainer 是否已安装
echo "步骤 2: 检查 Portainer..."
if docker ps -a | grep -q portainer; then
    echo "✅ Portainer 已安装"
else
    echo "📦 安装 Portainer..."
    docker volume create portainer_data
    docker run -d \
      -p 9000:9000 \
      -p 9443:9443 \
      --name portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest
    echo "✅ Portainer 安装完成！"
fi
echo ""

# 3. 检查 Dozzle 是否已安装
echo "步骤 3: 检查 Dozzle..."
if docker ps -a | grep -q dozzle; then
    echo "✅ Dozzle 已安装"
else
    echo "📦 安装 Dozzle..."
    docker run -d \
      --name dozzle \
      --restart=always \
      -p 8888:8080 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      amir20/dozzle:latest
    echo "✅ Dozzle 安装完成！"
fi
echo ""

# 4. 等待服务启动
echo "步骤 4: 等待服务启动..."
sleep 5
echo ""

# 5. 显示状态
echo "步骤 5: 检查容器状态..."
docker ps
echo ""

echo "========================================="
echo "   ✅ 安装完成！"
echo "========================================="
echo ""
echo "📊 监控工具访问地址："
echo "   1. 监控仪表板: 双击 监控仪表板.html"
echo "   2. Portainer: http://localhost:9000"
echo "   3. Dozzle: http://localhost:8888"
echo ""
echo "🌐 应用访问地址："
echo "   前端: http://localhost:5173"
echo "   后端A: http://localhost:3000"
echo "   后端B: http://localhost:4000"
echo ""
echo "💡 下一步："
echo "   1. 在浏览器中打开 http://localhost:9000 (Portainer)"
echo "   2. 在浏览器中打开 http://localhost:8888 (Dozzle)"
echo "   3. 双击 监控仪表板.html"
echo ""

# 打开浏览器
echo "🌐 正在打开监控界面..."
start http://localhost:9000 2>/dev/null || open http://localhost:9000 2>/dev/null || echo "请手动打开 http://localhost:9000"
sleep 2
start http://localhost:8888 2>/dev/null || open http://localhost:8888 2>/dev/null || echo "请手动打开 http://localhost:8888"
