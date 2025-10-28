# CD 部署配置说明

## 📋 当前配置

### ECS 集群信息
- **Cluster**: `todoapp-cluster`

### 服务配置
| 服务名称 | Task Definition | 版本 |
|---------|----------------|------|
| todoapp-backend-a | todoapp-backend-a | 6 |
| todoapp-backend-b | todoapp-backend-b | 4 |
| todoapp-frontend | todoapp-frontend | 5 |

## 🔐 需要配置的 GitHub Secrets

在你的 GitHub 仓库中，需要添加以下 Secrets：

1. 进入 GitHub 仓库
2. 点击 `Settings` → `Secrets and variables` → `Actions`
3. 点击 `New repository secret` 添加以下密钥：

### 必需的 Secrets

| Secret 名称 | 说明 | 如何获取 |
|------------|------|---------|
| `AWS_ACCESS_KEY_ID` | AWS 访问密钥 ID | 在 AWS IAM 中创建访问密钥 |
| `AWS_SECRET_ACCESS_KEY` | AWS 访问密钥 Secret | 在 AWS IAM 中创建访问密钥 |

### 获取 AWS 访问密钥步骤

1. 登录 AWS 控制台
2. 进入 IAM 服务
3. 点击左侧 "用户" → 选择你的用户
4. 点击 "安全凭证" 标签
5. 点击 "创建访问密钥"
6. 选择 "命令行界面 (CLI)"
7. 下载或复制密钥信息

**⚠️ 重要**: 访问密钥只显示一次，请妥善保管！

## 🚀 如何触发部署

### 方式 1: 推送标签（推荐）

```bash
# 创建新版本标签
git tag v1.0.0

# 推送标签到 GitHub
git push origin v1.0.0
```

### 方式 2: 手动触发

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `CD - 持续部署到 AWS ECS` workflow
4. 点击 `Run workflow`
5. 选择环境（development/staging/production）
6. 点击 `Run workflow` 按钮

## 📊 部署流程

1. **检出代码** - 获取最新代码
2. **获取版本信息** - 确定部署版本
3. **配置 AWS 凭证** - 使用 GitHub Secrets 配置 AWS
4. **登录 ECR** - 登录到 Amazon ECR
5. **部署服务** - 依次部署三个服务：
   - Backend A (task definition 版本 6)
   - Backend B (task definition 版本 4)
   - Frontend (task definition 版本 5)
6. **等待稳定** - 等待每个服务部署完成
7. **检查状态** - 验证所有服务运行正常
8. **部署通知** - 显示部署结果

## 🔧 修改配置

如果需要修改配置，编辑 `.github/workflows/deploy.yml` 文件：

### 修改 AWS 区域

```yaml
env:
  AWS_REGION: us-east-1  # 修改为你的区域，如 ap-northeast-1
```

### 更新 Task Definition 版本

当你创建新的 task definition 版本时，更新对应的版本号：

```yaml
# 例如，Backend A 更新到版本 7
- name: 🚀 部署 Backend A 到 ECS
  run: |
    aws ecs update-service \
      --task-definition ${{ env.ECS_TASK_DEFINITION_BACKEND_A }}:7 \
      --force-new-deployment
```

## 📝 部署检查清单

部署前确认：

- [ ] AWS Secrets 已配置
- [ ] Task Definition 版本正确
- [ ] AWS 区域设置正确
- [ ] ECS 集群和服务名称正确
- [ ] 代码已推送到 GitHub

## 🔍 故障排查

### 部署失败

1. 检查 GitHub Actions 日志
2. 确认 AWS Secrets 配置正确
3. 验证 ECS 服务和 Task Definition 存在
4. 检查 AWS IAM 权限

### 所需的 IAM 权限

你的 AWS 用户需要以下权限：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📚 相关文档

- [AWS ECS 部署指南](./AWS部署-ECS-完全零基础指南.md)
- [CI/CD 学习总结](./CICD学习总结.md)
- [版本管理指南](./版本管理指南.md)

## 🎯 下一步

1. 配置 GitHub Secrets
2. 测试手动触发部署
3. 创建版本标签测试自动部署
4. 监控部署日志确保成功

---

**提示**: 首次部署建议使用手动触发方式，确认配置正确后再使用标签自动触发。
