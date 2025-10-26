# 🚀 方案2: AWS ECS Fargate 完整部署步骤

**难度**: ⭐⭐⭐ 中等  
**时间**: 1-2 小时  
**成本**: $60-90/月（小型部署）  
**更新日期**: 2024年10月

## 📖 快速导航

- [架构说明](#架构说明)
- [前置准备](#前置准备)
- [详细步骤](#详细步骤)
- [故障排查](#故障排查)
- [成本优化](#成本优化)

## 🏗️ 架构说明

### 部署架构

```
用户浏览器
    ↓
ECS 前端服务 (Fargate)
    ↓
ECS 后端A服务 (Fargate)
    ↓
ECS 后端B服务 (Fargate)
    ↓
RDS PostgreSQL
```

### 核心组件

- **ECS**: 容器编排服务
- **Fargate**: 无服务器容器引擎（无需管理EC2）
- **ECR**: Docker 镜像仓库
- **RDS**: 托管PostgreSQL数据库
- **VPC**: 虚拟私有网络
- **CloudWatch**: 日志和监控

---

## 📋 前置准备

### 1. 安装必要工具

#### 安装 AWS CLI

```powershell
# 下载 AWS CLI 安装器
# 访问: https://awscli.amazonaws.com/AWSCLIV2.msi
# 下载并运行安装器

# 验证安装
aws --version
# 应显示: aws-cli/2.x.x ...
```

#### 配置 AWS CLI

**获取 Access Key**:
1. 登录 AWS Console
2. 点击右上角用户名 → Security credentials
3. 创建 Access Key
4. 下载并保存（只显示一次！）

```powershell
aws configure
# AWS Access Key ID: 输入您的 Access Key
# AWS Secret Access Key: 输入您的 Secret Key
# Default region name: us-east-1
# Default output format: json

# 验证配置
aws sts get-caller-identity
# 应显示您的账户信息
```

#### 安装 Docker Desktop

1. 下载：https://www.docker.com/products/docker-desktop
2. 安装并启动 Docker Desktop
3. 验证：
   ```powershell
   docker --version
   docker-compose --version
   ```

---

## 🗄️ 步骤1: 创建 RDS PostgreSQL 数据库

### 通过 AWS Console 创建（推荐）

1. **登录 AWS Console** → 搜索 "RDS" → "Create database"

2. **配置数据库**:
   ```
   引擎: PostgreSQL 15.x
   模板: Free tier（如果可用）
   DB instance identifier: todoapp-db
   Master username: todouser
   Master password: [设置强密码并记住]
   DB instance class: db.t3.micro
   Storage: 20 GB
   Public access: Yes
   Initial database name: todoapp
   ```

3. **创建后获取端点**:
   - 等待5-10分钟创建完成
   - 记录端点: `todoapp-db.xxxxxxxxx.us-east-1.rds.amazonaws.com`

4. **配置安全组**:
   - 允许端口 5432 从 0.0.0.0/0 访问

**关键信息（保存好）**：
- 端点: `todoapp-db.xxx.us-east-1.rds.amazonaws.com`
- 端口: `5432`
- 数据库: `todoapp`
- 用户名: `todouser`
- 密码: `[您设置的密码]`

---

## 📦 步骤2: 创建 ECR 仓库（存储 Docker 镜像）

### 2.1 创建三个 ECR 仓库

```powershell
# 创建后端B仓库
aws ecr create-repository `
  --repository-name todoapp-backend-b `
  --region us-east-1

# 创建后端A仓库
aws ecr create-repository `
  --repository-name todoapp-backend-a `
  --region us-east-1

# 创建前端仓库
aws ecr create-repository `
  --repository-name todoapp-frontend `
  --region us-east-1
```

### 2.2 获取仓库 URI

```powershell
# 列出所有仓库
aws ecr describe-repositories --region us-east-1

# 记录每个仓库的 repositoryUri，格式类似：
# 123456789012.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-b
```

---

## 🐳 步骤3: 构建并推送 Docker 镜像

### 3.1 获取 AWS 账户 ID

```powershell
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
echo $ACCOUNT_ID
# 应显示12位数字，例如：123456789012
```

### 3.2 登录 ECR

```powershell
# 获取登录密码并登录 Docker
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

**预期输出**: `Login Succeeded`

**如果登录失败**:
- 检查 Docker 是否运行: `docker ps`
- 检查 AWS CLI 配置: `aws configure list`
- 确保有 ECR 访问权限

### 3.3 构建并推送后端B镜像

```powershell
cd c:\Users\95150\OneDrive\桌面\my-fullstack-app\backend-b

# 构建镜像
docker build -t todoapp-backend-b .

# 打标签
docker tag todoapp-backend-b:latest $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-b:latest

# 推送到 ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-b:latest
```

### 3.4 构建并推送后端A镜像

```powershell
cd ..\backend-a

# 构建镜像
docker build -t todoapp-backend-a .

# 打标签
docker tag todoapp-backend-a:latest $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-a:latest

# 推送到 ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-a:latest
```

### 3.5 构建并推送前端镜像

```powershell
cd ..\frontend

# 构建镜像
docker build -t todoapp-frontend .

# 打标签
docker tag todoapp-frontend:latest $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-frontend:latest

# 推送到 ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-frontend:latest
```

---

## 🌐 步骤4: 创建 VPC 和网络资源

### 4.1 使用默认 VPC（简单方式）

```powershell
# 获取默认 VPC ID
$VPC_ID = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text
echo "VPC ID: $VPC_ID"

# 获取子网 ID
$SUBNET_IDS = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text
echo "Subnet IDs: $SUBNET_IDS"
```

### 4.2 创建安全组

```powershell
# 创建 ECS 安全组
$SG_ID = aws ec2 create-security-group `
  --group-name todoapp-ecs-sg `
  --description "Security group for TodoApp ECS tasks" `
  --vpc-id $VPC_ID `
  --query "GroupId" `
  --output text

echo "Security Group ID: $SG_ID"

# 允许 HTTP 流量（端口 80）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 80 `
  --cidr 0.0.0.0/0

# 允许后端A流量（端口 3000）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 3000 `
  --cidr 0.0.0.0/0

# 允许后端B流量（端口 4000）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 4000 `
  --cidr 0.0.0.0/0

# 允许前端流量（端口 5173）
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 5173 `
  --cidr 0.0.0.0/0

# 允许安全组内部通信
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol -1 `
  --source-group $SG_ID
```

---

## 📝 步骤5: 创建 ECS 集群

### 5.1 创建集群

```powershell
aws ecs create-cluster --cluster-name todoapp-cluster --region us-east-1
```

### 5.2 验证集群创建

```powershell
aws ecs describe-clusters --clusters todoapp-cluster --region us-east-1
```

---

## 📋 步骤6: 创建 IAM 角色

### 6.1 创建任务执行角色

创建文件 `ecs-task-execution-role-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```powershell
# 创建角色
aws iam create-role `
  --role-name ecsTaskExecutionRole `
  --assume-role-policy-document file://ecs-task-execution-role-trust-policy.json

# 附加策略
aws iam attach-role-policy `
  --role-name ecsTaskExecutionRole `
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

## 📄 步骤7: 创建 ECS 任务定义

### 7.1 创建后端B任务定义

**任务定义说明**:
- CPU: 512 单位 (0.5 vCPU)
- 内存: 1024 MB (1 GB)
- 网络模式: awsvpc（Fargate 必需）

创建文件 `task-definition-backend-b.json`:

```json
{
  "family": "todoapp-backend-b",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend-b",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-b:latest",
      "portMappings": [
        {
          "containerPort": 4000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "PORT_B", "value": "4000"},
        {"name": "POSTGRES_HOST", "value": "todoapp-db.xxx.us-east-1.rds.amazonaws.com"},
        {"name": "POSTGRES_PORT", "value": "5432"},
        {"name": "POSTGRES_DB", "value": "todoapp"},
        {"name": "POSTGRES_USER", "value": "todouser"},
        {"name": "POSTGRES_PASSWORD", "value": "YOUR_DB_PASSWORD"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/todoapp-backend-b",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**⚠️ 重要**：替换以下内容：
- `YOUR_ACCOUNT_ID`：您的 AWS 账户 ID（运行 `echo $ACCOUNT_ID` 查看）
- `todoapp-db.xxx.us-east-1.rds.amazonaws.com`：您的 RDS 端点
- `YOUR_DB_PASSWORD`：您的数据库密码

**快速替换方法**:
```powershell
# 获取 RDS 端点
$RDS_ENDPOINT = aws rds describe-db-instances --db-instance-identifier todoapp-db --query "DBInstances[0].Endpoint.Address" --output text
echo "RDS Endpoint: $RDS_ENDPOINT"

# 然后手动编辑 JSON 文件
notepad task-definition-backend-b.json
```

### 7.2 创建 CloudWatch 日志组

```powershell
aws logs create-log-group --log-group-name /ecs/todoapp-backend-b --region us-east-1
aws logs create-log-group --log-group-name /ecs/todoapp-backend-a --region us-east-1
aws logs create-log-group --log-group-name /ecs/todoapp-frontend --region us-east-1
```

### 7.3 注册任务定义

```powershell
aws ecs register-task-definition --cli-input-json file://task-definition-backend-b.json --region us-east-1
```

### 7.4 创建后端A任务定义

创建文件 `task-definition-backend-a.json`:

```json
{
  "family": "todoapp-backend-a",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend-a",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend-a:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "PORT", "value": "3000"},
        {"name": "BACKEND_B_URL", "value": "http://BACKEND_B_PRIVATE_IP:4000"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/todoapp-backend-a",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**注意**：`BACKEND_B_URL` 需要在后端B服务创建后更新

```powershell
aws ecs register-task-definition --cli-input-json file://task-definition-backend-a.json --region us-east-1
```

### 7.5 创建前端任务定义

创建文件 `task-definition-frontend.json`:

```json
{
  "family": "todoapp-frontend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "frontend",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/todoapp-frontend:latest",
      "portMappings": [
        {
          "containerPort": 5173,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "VITE_API_URL", "value": "http://BACKEND_A_PUBLIC_IP:3000"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/todoapp-frontend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

```powershell
aws ecs register-task-definition --cli-input-json file://task-definition-frontend.json --region us-east-1
```

---

## 🚀 步骤8: 创建 ECS 服务

### 8.1 创建后端B服务

```powershell
# 获取子网 ID（使用第一个子网）
$SUBNET_ID = ($SUBNET_IDS -split '\s+')[0]

# 创建服务
aws ecs create-service `
  --cluster todoapp-cluster `
  --service-name todoapp-backend-b `
  --task-definition todoapp-backend-b `
  --desired-count 1 `
  --launch-type FARGATE `
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" `
  --region us-east-1
```

### 8.2 获取后端B的公网 IP

**重要**: 等待任务完全启动后再获取 IP

```powershell
# 等待任务启动（约1-2分钟）
echo "等待后端B任务启动..."
Start-Sleep -Seconds 90

# 获取任务 ARN
$TASK_ARN = aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-b --query "taskArns[0]" --output text --region us-east-1

# 获取任务详情
$TASK_DETAILS = aws ecs describe-tasks --cluster todoapp-cluster --tasks $TASK_ARN --query "tasks[0].attachments[0].details" --region us-east-1 | ConvertFrom-Json

# 获取网络接口 ID
$ENI_ID = ($TASK_DETAILS | Where-Object {$_.name -eq "networkInterfaceId"}).value

# 获取公网 IP
$BACKEND_B_IP = aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].Association.PublicIp" --output text

echo "后端B公网IP: $BACKEND_B_IP"
```

### 8.3 更新后端A任务定义

编辑 `task-definition-backend-a.json`，将 `BACKEND_B_URL` 更新为：
```json
{"name": "BACKEND_B_URL", "value": "http://BACKEND_B_IP:4000"}
```

重新注册：
```powershell
aws ecs register-task-definition --cli-input-json file://task-definition-backend-a.json --region us-east-1
```

### 8.4 创建后端A服务

```powershell
aws ecs create-service `
  --cluster todoapp-cluster `
  --service-name todoapp-backend-a `
  --task-definition todoapp-backend-a `
  --desired-count 1 `
  --launch-type FARGATE `
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" `
  --region us-east-1
```

### 8.5 获取后端A的公网 IP

```powershell
Start-Sleep -Seconds 60

$TASK_ARN_A = aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-a --query "taskArns[0]" --output text --region us-east-1
$TASK_DETAILS_A = aws ecs describe-tasks --cluster todoapp-cluster --tasks $TASK_ARN_A --query "tasks[0].attachments[0].details" --region us-east-1 | ConvertFrom-Json
$ENI_ID_A = ($TASK_DETAILS_A | Where-Object {$_.name -eq "networkInterfaceId"}).value
$BACKEND_A_IP = aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID_A --query "NetworkInterfaces[0].Association.PublicIp" --output text

echo "后端A公网IP: $BACKEND_A_IP"
```

### 8.6 更新前端任务定义并创建服务

编辑 `task-definition-frontend.json`，更新 `VITE_API_URL`：
```json
{"name": "VITE_API_URL", "value": "http://BACKEND_A_IP:3000"}
```

```powershell
# 重新注册
aws ecs register-task-definition --cli-input-json file://task-definition-frontend.json --region us-east-1

# 创建服务
aws ecs create-service `
  --cluster todoapp-cluster `
  --service-name todoapp-frontend `
  --task-definition todoapp-frontend `
  --desired-count 1 `
  --launch-type FARGATE `
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" `
  --region us-east-1
```

### 8.7 获取前端的公网 IP

```powershell
Start-Sleep -Seconds 60

$TASK_ARN_F = aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-frontend --query "taskArns[0]" --output text --region us-east-1
$TASK_DETAILS_F = aws ecs describe-tasks --cluster todoapp-cluster --tasks $TASK_ARN_F --query "tasks[0].attachments[0].details" --region us-east-1 | ConvertFrom-Json
$ENI_ID_F = ($TASK_DETAILS_F | Where-Object {$_.name -eq "networkInterfaceId"}).value
$FRONTEND_IP = aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID_F --query "NetworkInterfaces[0].Association.PublicIp" --output text

echo "前端公网IP: $FRONTEND_IP"
echo "应用访问地址: http://${FRONTEND_IP}:5173"
```

---

## ✅ 测试部署

### 测试后端B
```powershell
curl http://${BACKEND_B_IP}:4000/api/messages
```

### 测试后端A
```powershell
curl -X POST http://${BACKEND_A_IP}:3000/api/messages `
  -H "Content-Type: application/json" `
  -d '{\"author\":\"测试\",\"text\":\"紧急工作会议\"}'
```

### 访问前端
在浏览器中打开：`http://FRONTEND_IP:5173`

---

## 🔍 配置本地数据库观察

（与方案1相同，使用 DBeaver 连接 RDS）

---

## 📊 监控和日志

### 查看 CloudWatch 日志

```powershell
# 查看后端B日志
aws logs tail /ecs/todoapp-backend-b --follow --region us-east-1

# 查看后端A日志
aws logs tail /ecs/todoapp-backend-a --follow --region us-east-1

# 查看前端日志
aws logs tail /ecs/todoapp-frontend --follow --region us-east-1
```

---

## 🧹 清理资源（可选）

**⚠️ 警告**: 删除操作不可逆！确保已备份重要数据。

### 删除顺序（重要）

如果需要删除所有资源：

```powershell
# 删除服务
aws ecs delete-service --cluster todoapp-cluster --service todoapp-frontend --force --region us-east-1
aws ecs delete-service --cluster todoapp-cluster --service todoapp-backend-a --force --region us-east-1
aws ecs delete-service --cluster todoapp-cluster --service todoapp-backend-b --force --region us-east-1

# 删除集群
aws ecs delete-cluster --cluster todoapp-cluster --region us-east-1

# 删除 ECR 仓库
aws ecr delete-repository --repository-name todoapp-frontend --force --region us-east-1
aws ecr delete-repository --repository-name todoapp-backend-a --force --region us-east-1
aws ecr delete-repository --repository-name todoapp-backend-b --force --region us-east-1

# 删除 RDS 数据库
aws rds delete-db-instance --db-instance-identifier todoapp-db --skip-final-snapshot --region us-east-1
```

---

## 💡 优化建议

1. **使用 Application Load Balancer (ALB)**：提供统一入口和 HTTPS
2. **使用 Service Discovery**：自动服务发现，无需硬编码 IP
3. **配置自动扩展**：根据 CPU/内存使用率自动扩展
4. **使用 Secrets Manager**：安全存储数据库密码
5. **配置健康检查**：自动重启不健康的任务

---

## 🎉 完成！

您已成功使用 ECS Fargate 部署应用！

**优势**：
- 完整的容器编排
- 灵活的网络配置
- 适合生产环境
- 无需管理服务器

**访问应用**:
```
前端: http://[FRONTEND_IP]:5173
后端A: http://[BACKEND_A_IP]:3000
后端B: http://[BACKEND_B_IP]:4000
```

---

## 🔍 故障排查

### 问题1: 任务无法启动

**症状**: 任务状态一直是 PENDING 或 STOPPED

**检查步骤**:
```powershell
# 查看任务状态
aws ecs describe-tasks --cluster todoapp-cluster --tasks [TASK_ARN] --region us-east-1

# 查看服务事件
aws ecs describe-services --cluster todoapp-cluster --services todoapp-backend-b --region us-east-1
```

**常见原因**:
1. **镜像拉取失败**
   - 检查 ECR 镜像是否存在
   - 检查 IAM 角色权限
   ```powershell
   aws ecr describe-images --repository-name todoapp-backend-b --region us-east-1
   ```

2. **资源不足**
   - CPU/内存配置过高
   - 降低任务定义中的 CPU 和内存

3. **网络配置错误**
   - 检查子网是否有公网访问
   - 检查安全组规则

### 问题2: 无法访问应用

**检查步骤**:
```powershell
# 1. 确认任务正在运行
aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-b --region us-east-1

# 2. 检查安全组规则
aws ec2 describe-security-groups --group-ids $SG_ID

# 3. 测试端口连接
Test-NetConnection -ComputerName [PUBLIC_IP] -Port 4000
```

**解决方法**:
- 确保安全组允许对应端口
- 确保任务有公网 IP (`assignPublicIp=ENABLED`)
- 检查应用日志

### 问题3: 数据库连接失败

**检查步骤**:
```powershell
# 查看容器日志
aws logs tail /ecs/todoapp-backend-b --follow --region us-east-1
```

**常见错误**:
```
Error: connect ETIMEDOUT
→ RDS 安全组未允许 ECS 安全组访问

Error: password authentication failed
→ 数据库密码错误

Error: database "todoapp" does not exist
→ 数据库名称错误
```

**解决方法**:
1. 检查 RDS 安全组，允许 ECS 安全组访问端口 5432
2. 验证环境变量中的数据库凭据
3. 确认 RDS 端点正确

### 问题4: 服务间无法通信

**症状**: 前端无法访问后端A，或后端A无法访问后端B

**检查**:
```powershell
# 确认安全组允许内部通信
aws ec2 describe-security-groups --group-ids $SG_ID --query "SecurityGroups[0].IpPermissions"
```

**解决**: 确保安全组有内部通信规则
```powershell
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol -1 `
  --source-group $SG_ID
```

---

## 💰 成本优化

### 当前成本估算

```
ECS Fargate:
- 3个任务 × 0.5 vCPU × $0.04048/小时 × 730小时 = $44.45/月
- 3个任务 × 1 GB × $0.004445/小时 × 730小时 = $9.73/月

RDS db.t3.micro:
- $0.017/小时 × 730小时 = $12.41/月
- 存储 20GB × $0.115/GB = $2.30/月

数据传输:
- 前15GB免费
- 超出部分 $0.09/GB

总计: 约 $70-90/月
```

### 优化建议

**1. 降低资源配置**
```json
// 任务定义中
"cpu": "256",      // 从 512 降到 256
"memory": "512"    // 从 1024 降到 512
```
**节省**: 约 50% Fargate 成本

**2. 使用 Spot 容量（高级）**
- Fargate Spot 可节省 70%
- 但任务可能被中断
- 适合非关键工作负载

**3. 使用 Savings Plans**
- 承诺使用1年或3年
- 可节省 20-50%

**4. 合并服务（不推荐生产环境）**
- 将多个服务合并到一个容器
- 减少任务数量
- 但失去微服务优势

---

## 📊 监控最佳实践

### 设置 CloudWatch 告警

```powershell
# CPU 使用率告警
aws cloudwatch put-metric-alarm `
  --alarm-name todoapp-backend-b-cpu-high `
  --alarm-description "Backend B CPU > 80%" `
  --metric-name CPUUtilization `
  --namespace AWS/ECS `
  --statistic Average `
  --period 300 `
  --threshold 80 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 2
```

### 查看关键指标

```powershell
# 服务 CPU 使用率
aws cloudwatch get-metric-statistics `
  --namespace AWS/ECS `
  --metric-name CPUUtilization `
  --dimensions Name=ServiceName,Value=todoapp-backend-b Name=ClusterName,Value=todoapp-cluster `
  --start-time 2024-01-01T00:00:00Z `
  --end-time 2024-01-01T23:59:59Z `
  --period 3600 `
  --statistics Average
```

---

## 🚀 下一步优化

### 1. 配置 Application Load Balancer

**优势**:
- 统一入口
- HTTPS 支持
- 健康检查
- 自动故障转移

**成本**: 约 $16/月

### 2. 配置自动扩展

```powershell
# 注册可扩展目标
aws application-autoscaling register-scalable-target `
  --service-namespace ecs `
  --resource-id service/todoapp-cluster/todoapp-backend-b `
  --scalable-dimension ecs:service:DesiredCount `
  --min-capacity 1 `
  --max-capacity 4

# 配置扩展策略（基于 CPU）
aws application-autoscaling put-scaling-policy `
  --service-namespace ecs `
  --resource-id service/todoapp-cluster/todoapp-backend-b `
  --scalable-dimension ecs:service:DesiredCount `
  --policy-name cpu-scaling-policy `
  --policy-type TargetTrackingScaling `
  --target-tracking-scaling-policy-configuration file://scaling-policy.json
```

### 3. 使用 Secrets Manager

**存储敏感信息**（数据库密码等）:
```powershell
# 创建密钥
aws secretsmanager create-secret `
  --name todoapp/db-password `
  --secret-string "your-db-password"

# 在任务定义中引用
"secrets": [
  {
    "name": "POSTGRES_PASSWORD",
    "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:todoapp/db-password"
  }
]
```

**成本**: $0.40/月/密钥

### 4. 配置 CI/CD

使用 GitHub Actions 自动部署:
```yaml
# .github/workflows/deploy.yml
name: Deploy to ECS
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
      - name: Build and push image
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      - name: Update ECS service
        run: |
          aws ecs update-service --cluster todoapp-cluster --service todoapp-backend-b --force-new-deployment
```

---

## 📝 总结

### 您已完成

✅ 创建 ECR 仓库并推送镜像  
✅ 配置 VPC 和安全组  
✅ 创建 ECS 集群和任务定义  
✅ 部署 3 个 Fargate 服务  
✅ 配置 RDS PostgreSQL  
✅ 设置日志和监控  

### ECS vs 其他方案

| 特性 | ECS Fargate | App Runner | EC2 |
|------|------------|-----------|-----|
| 复杂度 | ⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ |
| 灵活性 | 高 | 中 | 最高 |
| 成本 | 中 | 中高 | 低 |
| 运维 | 低 | 最低 | 高 |
| 适合 | 生产环境 | 快速原型 | 完全控制 |

### 推荐使用场景

**使用 ECS Fargate 当**:
- ✅ 需要容器编排
- ✅ 需要灵活的网络配置
- ✅ 团队熟悉 Docker
- ✅ 预算充足（$60-90/月）

**考虑其他方案当**:
- 想要最简单部署 → App Runner
- 想要完全免费（12个月）→ EC2
- 想要无需信用卡 → Railway

**需要帮助?** 查看故障排查部分或联系 AWS Support。
