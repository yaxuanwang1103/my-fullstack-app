# 🚀 方案3: AWS EC2 + Docker 完整部署步骤

**难度**: ⭐⭐⭐⭐⭐ 复杂  
**时间**: 2-4 小时  
**成本**: $25-60/月（长期最便宜）

---

## 📋 前置准备

### 1. 安装 AWS CLI 并配置

```powershell
# 下载并安装 AWS CLI
# https://awscli.amazonaws.com/AWSCLIV2.msi

# 配置
aws configure
# AWS Access Key ID: 输入您的 Access Key
# AWS Secret Access Key: 输入您的 Secret Key
# Default region name: us-east-1
# Default output format: json
```

---

## 🗄️ 步骤1: 创建 RDS PostgreSQL 数据库

（与方案1相同，参考 `AWS部署-方案1-AppRunner.md` 的步骤1）

**关键信息**：
- 数据库标识符: `todoapp-db`
- 用户名: `todouser`
- 数据库名: `todoapp`
- 端点: `todoapp-db.xxx.us-east-1.rds.amazonaws.com`
- 密码: 您设置的密码

---

## 🖥️ 步骤2: 创建 EC2 实例

### 2.1 创建密钥对（用于 SSH 登录）

```powershell
# 创建密钥对
aws ec2 create-key-pair `
  --key-name todoapp-key `
  --query 'KeyMaterial' `
  --output text `
  --region us-east-1 > todoapp-key.pem

# 保存密钥文件到安全位置
# Windows 不需要修改权限，但要妥善保管
```

### 2.2 创建安全组

```powershell
# 获取默认 VPC ID
$VPC_ID = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text
echo "VPC ID: $VPC_ID"

# 创建安全组
$SG_ID = aws ec2 create-security-group `
  --group-name todoapp-ec2-sg `
  --description "Security group for TodoApp EC2" `
  --vpc-id $VPC_ID `
  --query "GroupId" `
  --output text

echo "Security Group ID: $SG_ID"

# 允许 SSH（端口 22）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 22 `
  --cidr 0.0.0.0/0

# 允许 HTTP（端口 80）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 80 `
  --cidr 0.0.0.0/0

# 允许 HTTPS（端口 443）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 443 `
  --cidr 0.0.0.0/0

# 允许后端A（端口 3000）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 3000 `
  --cidr 0.0.0.0/0

# 允许后端B（端口 4000）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 4000 `
  --cidr 0.0.0.0/0

# 允许前端（端口 5173）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 5173 `
  --cidr 0.0.0.0/0
```

### 2.3 启动 EC2 实例

```powershell
# 获取最新的 Amazon Linux 2023 AMI ID
$AMI_ID = aws ec2 describe-images `
  --owners amazon `
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" "Name=state,Values=available" `
  --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" `
  --output text

echo "AMI ID: $AMI_ID"

# 启动实例
$INSTANCE_ID = aws ec2 run-instances `
  --image-id $AMI_ID `
  --instance-type t3.small `
  --key-name todoapp-key `
  --security-group-ids $SG_ID `
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=todoapp-server}]" `
  --query "Instances[0].InstanceId" `
  --output text

echo "Instance ID: $INSTANCE_ID"

# 等待实例启动
echo "等待实例启动..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# 获取公网 IP
$PUBLIC_IP = aws ec2 describe-instances `
  --instance-ids $INSTANCE_ID `
  --query "Reservations[0].Instances[0].PublicIpAddress" `
  --output text

echo "公网 IP: $PUBLIC_IP"
echo "保存这个 IP 地址！"
```

---

## 🔧 步骤3: 配置 EC2 实例

### 3.1 连接到 EC2 实例

```powershell
# 使用 SSH 连接（Windows 10+ 内置 SSH）
ssh -i todoapp-key.pem ec2-user@$PUBLIC_IP

# 如果提示 "Are you sure you want to continue connecting"，输入 yes
```

### 3.2 安装 Docker 和 Docker Compose

在 EC2 实例上执行以下命令：

```bash
# 更新系统
sudo yum update -y

# 安装 Docker
sudo yum install -y docker

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将 ec2-user 添加到 docker 组
sudo usermod -a -G docker ec2-user

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version

# 退出并重新登录以应用组权限
exit
```

重新连接：
```powershell
ssh -i todoapp-key.pem ec2-user@$PUBLIC_IP
```

### 3.3 安装 Git

```bash
sudo yum install -y git
git --version
```

---

## 📦 步骤4: 部署应用

### 4.1 克隆项目

```bash
# 克隆您的 GitHub 仓库
git clone https://github.com/你的用户名/my-fullstack-app.git
cd my-fullstack-app
```

### 4.2 创建环境变量文件

```bash
# 创建 .env 文件
cat > .env << 'EOF'
# PostgreSQL 配置
POSTGRES_HOST=todoapp-db.xxx.us-east-1.rds.amazonaws.com
POSTGRES_PORT=5432
POSTGRES_DB=todoapp
POSTGRES_USER=todouser
POSTGRES_PASSWORD=你的数据库密码

# 后端配置
PORT=3000
PORT_B=4000
BACKEND_B_URL=http://localhost:4000

# 前端配置
VITE_API_URL=http://你的EC2公网IP:3000
EOF

# 编辑文件，替换实际值
nano .env
# 按 Ctrl+X, Y, Enter 保存
```

**⚠️ 重要**：替换以下内容：
- `todoapp-db.xxx.us-east-1.rds.amazonaws.com`：您的 RDS 端点
- `你的数据库密码`：您的数据库密码
- `你的EC2公网IP`：您的 EC2 公网 IP

### 4.3 修改 docker-compose.yml

```bash
# 编辑 docker-compose.yml
nano docker-compose.yml
```

修改 PostgreSQL 部分，注释掉本地数据库，因为我们使用 RDS：

```yaml
version: '3.8'

services:
  # 注释掉本地 PostgreSQL，使用 RDS
  # postgres:
  #   image: postgres:15-alpine
  #   ...

  # 后端B - 数据存储服务
  backend-b:
    build:
      context: ./backend-b
      dockerfile: Dockerfile
    container_name: todoapp-backend-b
    environment:
      PORT_B: ${PORT_B}
      POSTGRES_HOST: ${POSTGRES_HOST}
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "4000:4000"
    restart: unless-stopped

  # 后端A - 智能分类服务
  backend-a:
    build:
      context: ./backend-a
      dockerfile: Dockerfile
    container_name: todoapp-backend-a
    environment:
      PORT: ${PORT}
      BACKEND_B_URL: ${BACKEND_B_URL}
    ports:
      - "3000:3000"
    depends_on:
      - backend-b
    restart: unless-stopped

  # 前端
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: todoapp-frontend
    environment:
      VITE_API_URL: ${VITE_API_URL}
    ports:
      - "5173:5173"
    depends_on:
      - backend-a
    restart: unless-stopped
    stdin_open: true
    tty: true
```

保存文件（Ctrl+X, Y, Enter）

### 4.4 启动应用

```bash
# 构建并启动所有服务
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 按 Ctrl+C 退出日志查看

# 查看运行状态
docker-compose ps
```

---

## ✅ 步骤5: 测试部署

### 5.1 测试后端B

```bash
curl http://localhost:4000/api/messages
# 应该返回: []
```

### 5.2 测试后端A

```bash
curl -X POST http://localhost:3000/api/messages \
  -H "Content-Type: application/json" \
  -d '{"author":"测试","text":"紧急工作会议"}'
# 应该返回带有分类信息的任务
```

### 5.3 访问前端

在本地浏览器中打开：`http://你的EC2公网IP:5173`

您应该看到您的智能待办清单应用！

---

## 🔍 步骤6: 配置本地数据库观察

### 6.1 使用 DBeaver 连接 RDS

（与方案1相同）

1. 打开 DBeaver
2. 创建新连接：
   - Host: `todoapp-db.xxx.us-east-1.rds.amazonaws.com`
   - Port: `5432`
   - Database: `todoapp`
   - Username: `todouser`
   - Password: 您的密码

### 6.2 使用 SSH 隧道连接（可选）

如果 RDS 没有公网访问，可以通过 EC2 建立 SSH 隧道：

```powershell
# 在本地 PowerShell 中运行
ssh -i todoapp-key.pem -L 5432:todoapp-db.xxx.us-east-1.rds.amazonaws.com:5432 ec2-user@$PUBLIC_IP -N

# 然后在 DBeaver 中连接到 localhost:5432
```

---

## 🔧 步骤7: 配置自动启动

### 7.1 创建 systemd 服务

```bash
# 创建服务文件
sudo nano /etc/systemd/system/todoapp.service
```

添加以下内容：

```ini
[Unit]
Description=TodoApp Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/my-fullstack-app
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ec2-user

[Install]
WantedBy=multi-user.target
```

保存并启用服务：

```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启用服务（开机自动启动）
sudo systemctl enable todoapp.service

# 启动服务
sudo systemctl start todoapp.service

# 查看状态
sudo systemctl status todoapp.service
```

---

## 📊 步骤8: 监控和日志

### 8.1 查看 Docker 日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend-a
docker-compose logs -f backend-b
docker-compose logs -f frontend

# 查看最后100行日志
docker-compose logs --tail=100
```

### 8.2 查看系统资源使用

```bash
# 查看 Docker 容器资源使用
docker stats

# 查看系统资源
top
# 按 q 退出

# 查看磁盘使用
df -h

# 查看内存使用
free -h
```

---

## 🔄 步骤9: 更新应用

### 9.1 拉取最新代码

```bash
cd /home/ec2-user/my-fullstack-app

# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build

# 查看日志确认更新成功
docker-compose logs -f
```

### 9.2 自动化更新脚本

```bash
# 创建更新脚本
cat > update.sh << 'EOF'
#!/bin/bash
cd /home/ec2-user/my-fullstack-app
git pull
docker-compose down
docker-compose up -d --build
docker-compose logs --tail=50
EOF

# 添加执行权限
chmod +x update.sh

# 使用脚本更新
./update.sh
```

---

## 🔒 步骤10: 安全加固

### 10.1 配置防火墙

```bash
# 安装 firewalld
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# 允许必要的端口
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --permanent --add-port=5173/tcp

# 重新加载防火墙
sudo firewall-cmd --reload

# 查看规则
sudo firewall-cmd --list-all
```

### 10.2 配置自动更新

```bash
# 安装自动更新
sudo yum install -y yum-cron

# 启用自动更新
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

### 10.3 限制 SSH 访问（可选）

```bash
# 编辑 SSH 配置
sudo nano /etc/ssh/sshd_config

# 修改以下配置：
# PermitRootLogin no
# PasswordAuthentication no
# Port 2222  # 更改 SSH 端口（可选）

# 重启 SSH 服务
sudo systemctl restart sshd
```

---

## 🌐 步骤11: 配置域名（可选）

### 11.1 购买域名

在域名注册商（如 GoDaddy、Namecheap、阿里云）购买域名

### 11.2 配置 DNS

在域名管理面板添加 A 记录：

```
类型: A
主机: @
值: 你的EC2公网IP
TTL: 3600
```

### 11.3 安装 Nginx 反向代理

```bash
# 安装 Nginx
sudo yum install -y nginx

# 启动 Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 创建配置文件
sudo nano /etc/nginx/conf.d/todoapp.conf
```

添加以下内容：

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# 测试配置
sudo nginx -t

# 重新加载 Nginx
sudo systemctl reload nginx
```

### 11.4 安装 SSL 证书（HTTPS）

```bash
# 安装 Certbot
sudo yum install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 自动续期
sudo systemctl enable certbot-renew.timer
```

---

## 💾 步骤12: 备份策略

### 12.1 备份数据库

```bash
# 创建备份脚本
cat > /home/ec2-user/backup-db.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/ec2-user/backups"
mkdir -p $BACKUP_DIR

# 备份 RDS 数据库
PGPASSWORD='你的数据库密码' pg_dump \
  -h todoapp-db.xxx.us-east-1.rds.amazonaws.com \
  -U todouser \
  -d todoapp \
  > $BACKUP_DIR/todoapp_$DATE.sql

# 压缩备份
gzip $BACKUP_DIR/todoapp_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "备份完成: todoapp_$DATE.sql.gz"
EOF

# 添加执行权限
chmod +x /home/ec2-user/backup-db.sh

# 安装 PostgreSQL 客户端
sudo yum install -y postgresql15

# 测试备份
./backup-db.sh
```

### 12.2 配置定时备份

```bash
# 编辑 crontab
crontab -e

# 添加每天凌晨2点备份
0 2 * * * /home/ec2-user/backup-db.sh >> /home/ec2-user/backup.log 2>&1
```

---

## 🧹 清理资源（可选）

如果需要删除所有资源：

```powershell
# 终止 EC2 实例
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# 删除安全组（等待实例终止后）
aws ec2 delete-security-group --group-id $SG_ID

# 删除密钥对
aws ec2 delete-key-pair --key-name todoapp-key

# 删除 RDS 数据库
aws rds delete-db-instance --db-instance-identifier todoapp-db --skip-final-snapshot
```

---

## 📊 成本优化

### 1. 使用预留实例

```powershell
# 购买1年期预留实例可节省30-40%
# 在 EC2 控制台 → 预留实例 → 购买预留实例
```

### 2. 使用 Spot 实例

```powershell
# Spot 实例可节省70-90%，但可能被中断
# 适合开发/测试环境
```

### 3. 定时启停

```bash
# 创建停止脚本（非工作时间停止）
cat > /home/ec2-user/stop-services.sh << 'EOF'
#!/bin/bash
docker-compose down
EOF

chmod +x /home/ec2-user/stop-services.sh

# 配置 crontab（晚上11点停止）
# 0 23 * * * /home/ec2-user/stop-services.sh

# 配置 crontab（早上8点启动）
# 0 8 * * * /home/ec2-user/my-fullstack-app && docker-compose up -d
```

---

## 🎉 完成！

您已成功使用 EC2 + Docker 部署应用！

**优势**：
- 完全控制服务器
- 成本最低（长期）
- 灵活性最高

**维护任务**：
- 定期更新系统和 Docker
- 监控资源使用
- 定期备份数据
- 检查安全日志

**访问地址**：
- 前端：`http://你的EC2公网IP:5173`
- 后端A：`http://你的EC2公网IP:3000`
- 后端B：`http://你的EC2公网IP:4000`

**下一步**：
- 配置域名和 HTTPS
- 设置监控告警
- 配置自动备份
- 优化性能
