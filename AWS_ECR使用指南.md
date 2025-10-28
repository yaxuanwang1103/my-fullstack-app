# 🚀 AWS ECR 使用指南

本指南说明如何使用 AWS ECR 替代 Docker Hub 来存储 Docker 镜像。

---

## 📋 前提条件

### 1. AWS 账号和权限

确保你有：
- ✅ AWS 账号
- ✅ IAM 用户（具有 ECR 权限）
- ✅ Access Key ID 和 Secret Access Key

### 2. 所需权限

IAM 用户需要以下权限：
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:CreateRepository",
                "ecr:PutLifecyclePolicy"
            ],
            "Resource": "*"
        }
    ]
}
```

---

## 🔧 步骤 1：创建 ECR 仓库

### 方法 1：使用脚本（推荐）

```bash
# 设置 AWS 区域
export AWS_REGION=us-east-2

# 运行创建脚本
chmod +x create-ecr-repos.sh
./create-ecr-repos.sh
```

### 方法 2：手动创建

```bash
# 创建三个仓库
aws ecr create-repository --repository-name todoapp-frontend --region us-east-2
aws ecr create-repository --repository-name todoapp-backend-a --region us-east-2
aws ecr create-repository --repository-name todoapp-backend-b --region us-east-2
```

### 方法 3：在 AWS Console 中创建

1. 访问 [ECR 控制台](https://console.aws.amazon.com/ecr/)
2. 点击 **"Create repository"**
3. 创建三个仓库：
   - `todoapp-frontend`
   - `todoapp-backend-a`
   - `todoapp-backend-b`

---

## 🔐 步骤 2：配置 GitHub Secrets

在 GitHub 仓库中设置以下 Secrets：

1. 进入 GitHub 仓库
2. **Settings** → **Secrets and variables** → **Actions**
3. 点击 **"New repository secret"**
4. 添加以下 Secrets：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | `xxx...` | AWS Secret Access Key |
| `AWS_REGION` | `us-east-2` | AWS 区域 |
| `AWS_ACCOUNT_ID` | `123456789012` | AWS 账号 ID（12 位数字）|

### 如何获取 AWS Account ID

```bash
# 方法 1：使用 AWS CLI
aws sts get-caller-identity --query Account --output text

# 方法 2：在 AWS Console 右上角查看
# 点击你的用户名，Account ID 会显示在下拉菜单中
```

---

## ✅ 步骤 3：验证配置

### 检查 ECR 仓库

```bash
# 列出所有仓库
aws ecr describe-repositories --region us-east-2

# 查看仓库 URI
aws ecr describe-repositories --region us-east-2 --query 'repositories[].repositoryUri' --output table
```

### 测试本地推送（可选）

```bash
# 登录 ECR
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com

# 构建镜像
docker build -t todoapp-frontend ./frontend

# 标记镜像
docker tag todoapp-frontend:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/todoapp-frontend:latest

# 推送镜像
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/todoapp-frontend:latest
```

---

## 🚀 步骤 4：触发 GitHub Actions

### 自动触发

推送代码到 `main` 分支或创建标签：

```bash
git add .
git commit -m "feat: 切换到 AWS ECR"
git push origin main

# 或创建版本标签
git tag -a v2.3.1 -m "切换到 AWS ECR"
git push origin v2.3.1
```

### 手动触发

1. 进入 GitHub 仓库
2. **Actions** → **Docker - 构建并推送镜像**
3. 点击 **"Run workflow"**
4. 选择分支，点击 **"Run workflow"**

---

## 📊 步骤 5：查看构建结果

### 在 GitHub Actions 中查看

1. **Actions** 标签
2. 点击最新的 workflow run
3. 查看构建日志

### 在 AWS ECR 中查看

1. 访问 [ECR 控制台](https://console.aws.amazon.com/ecr/)
2. 点击仓库名称
3. 查看镜像列表和标签

```bash
# 使用 CLI 查看镜像
aws ecr list-images --repository-name todoapp-frontend --region us-east-2
```

---

## 🔄 更新 ECS 任务定义（如果使用 ECS）

如果你使用 ECS 部署，需要更新任务定义中的镜像 URI：

### 旧的 Docker Hub URI
```
yaxuanwang1103/todoapp-frontend:latest
```

### 新的 ECR URI
```
<AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/todoapp-frontend:latest
```

### 更新方法

```bash
# 1. 获取当前任务定义
aws ecs describe-task-definition --task-definition todoapp-task --region us-east-2 > task-def.json

# 2. 编辑 task-def.json，更新镜像 URI

# 3. 注册新的任务定义
aws ecs register-task-definition --cli-input-json file://task-def.json --region us-east-2

# 4. 更新服务
aws ecs update-service --cluster your-cluster --service todoapp-service --task-definition todoapp-task --region us-east-2
```

---

## 💰 成本优化

### ECR 定价（us-east-2）

- **存储**：$0.10 per GB/月
- **数据传输**：
  - 传入：免费
  - 传出到 Internet：前 100 GB 免费，之后 $0.09 per GB
  - 传出到同区域 EC2/ECS：免费

### 节省成本的建议

1. **设置生命周期策略**（已在脚本中配置）
   - 只保留最近 10 个镜像
   - 自动删除旧镜像

2. **使用镜像扫描**
   - 在推送时自动扫描漏洞
   - 已在脚本中启用

3. **压缩镜像大小**
   - 使用多阶段构建
   - 使用 alpine 基础镜像

---

## 🔍 故障排查

### 问题 1：权限被拒绝

**错误**：`AccessDeniedException`

**解决**：
- 检查 IAM 用户权限
- 确认 Access Key 正确
- 检查 AWS Region 是否匹配

### 问题 2：仓库不存在

**错误**：`RepositoryNotFoundException`

**解决**：
```bash
# 创建仓库
aws ecr create-repository --repository-name todoapp-frontend --region us-east-2
```

### 问题 3：GitHub Actions 失败

**检查**：
1. GitHub Secrets 是否正确设置
2. AWS 凭证是否有效
3. ECR 仓库是否已创建
4. 查看 Actions 日志中的详细错误

---

## 📚 相关文档

- [AWS ECR 官方文档](https://docs.aws.amazon.com/ecr/)
- [GitHub Actions - AWS ECR](https://github.com/aws-actions/amazon-ecr-login)
- [Docker 镜像最佳实践](https://docs.docker.com/develop/dev-best-practices/)

---

## ✅ 检查清单

完成以下步骤后，你的 ECR 集成就完成了：

- [ ] 创建了 3 个 ECR 仓库
- [ ] 在 GitHub 中设置了 4 个 Secrets
- [ ] 更新了 `docker-build.yml` 工作流
- [ ] 推送代码触发了构建
- [ ] 在 ECR 中看到了镜像
- [ ] （可选）更新了 ECS 任务定义

---

## 🎉 完成！

现在你的 Docker 镜像会自动推送到 AWS ECR，而不是 Docker Hub！
