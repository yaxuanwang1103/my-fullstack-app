# 🚀 CI/CD 快速配置指南

## ✅ 已完成的工作

我已经为你创建了以下文件：

```
.github/workflows/
├── ci.yml              # 持续集成（代码检查、构建、测试）
├── docker-build.yml    # Docker 镜像构建和推送
├── deploy.yml          # 自动部署到服务器
└── release.yml         # 自动创建 GitHub Release
```

---

## 📋 配置步骤

### 步骤 1：配置 GitHub Secrets（必需）

1. 打开你的 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下密钥：

#### Docker Hub 配置（用于镜像推送）

| 名称 | 说明 | 如何获取 |
|------|------|----------|
| `DOCKER_USERNAME` | Docker Hub 用户名 | 你的 Docker Hub 用户名 |
| `DOCKER_PASSWORD` | Docker Hub 访问令牌 | 1. 登录 [Docker Hub](https://hub.docker.com/)<br>2. Account Settings → Security<br>3. New Access Token<br>4. 复制生成的 token |

#### 服务器配置（用于自动部署，可选）

| 名称 | 说明 | 示例 |
|------|------|------|
| `SERVER_HOST` | 服务器 IP 地址 | `123.45.67.89` |
| `SERVER_USER` | SSH 用户名 | `ubuntu` 或 `root` |
| `SERVER_SSH_KEY` | SSH 私钥 | 完整的私钥内容 |
| `SERVER_PORT` | SSH 端口（可选） | `22`（默认） |

#### 如何获取 SSH 私钥？

```powershell
# 在本地生成 SSH 密钥对（如果还没有）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 查看私钥内容
cat ~/.ssh/id_rsa

# 将公钥添加到服务器
ssh-copy-id user@server-ip
```

---

### 步骤 2：推送工作流文件到 GitHub

```powershell
# 进入项目目录
cd C:\Users\95150\OneDrive\桌面\my-fullstack-app

# 查看新增的文件
git status

# 添加工作流文件
git add .github/

# 提交
git commit -m "feat: 添加 CI/CD 工作流配置

- 添加持续集成工作流（代码检查、构建、测试）
- 添加 Docker 镜像构建和推送工作流
- 添加自动部署工作流
- 添加自动发布工作流"

# 推送到 GitHub
git push origin main
```

---

### 步骤 3：查看工作流运行

1. 打开你的 GitHub 仓库
2. 点击 **Actions** 标签
3. 你会看到工作流开始运行

![GitHub Actions](https://docs.github.com/assets/cb-27347/images/help/repository/actions-tab.png)

---

## 🎯 工作流说明

### 1. CI - 持续集成 (`ci.yml`)

**触发条件**：
- 推送代码到 `main` 或 `develop` 分支
- 创建 Pull Request

**执行内容**：
- ✅ 代码格式检查
- ✅ 前端构建测试
- ✅ 后端语法检查
- ✅ Docker 镜像构建测试

**预期时间**：3-5 分钟

**查看方式**：
```
GitHub → Actions → CI - 持续集成
```

---

### 2. Docker Build - 镜像构建 (`docker-build.yml`)

**触发条件**：
- 推送代码到 `main` 分支
- 创建版本标签（如 `v2.1.1`）
- 手动触发

**执行内容**：
- 🐳 构建 frontend、backend-a、backend-b 三个镜像
- 📤 推送到 Docker Hub
- 🏷️ 自动打标签（latest、版本号、分支名）

**预期时间**：5-10 分钟

**注意**：需要配置 `DOCKER_USERNAME` 和 `DOCKER_PASSWORD`

---

### 3. Deploy - 自动部署 (`deploy.yml`)

**触发条件**：
- 创建版本标签（如 `v2.1.1`）
- 手动触发

**执行内容**：
- 🚀 SSH 连接到服务器
- 📥 拉取最新代码
- 🐳 拉取最新镜像
- ▶️ 重启容器
- 🔍 健康检查

**预期时间**：2-3 分钟

**注意**：需要配置服务器相关的 Secrets

---

### 4. Release - 自动发布 (`release.yml`)

**触发条件**：
- 创建版本标签（如 `v2.1.1`）

**执行内容**：
- 📝 从 CHANGELOG.md 提取更新内容
- 🎉 创建 GitHub Release
- 📎 附加相关文件

**预期时间**：1 分钟

---

## 🧪 测试工作流

### 测试 CI 工作流

```powershell
# 修改一个文件
echo "# Test" >> README.md

# 提交并推送
git add README.md
git commit -m "test: 测试 CI 工作流"
git push origin main
```

然后在 GitHub Actions 中查看运行结果。

---

### 测试 Docker 构建（需要先配置 Secrets）

```powershell
# 推送到 main 分支会自动触发
git push origin main

# 或者手动触发
# GitHub → Actions → Docker - 构建并推送镜像 → Run workflow
```

---

### 测试发布流程

```powershell
# 创建版本标签
git tag -a v2.1.2 -m "测试版本 2.1.2"
git push origin v2.1.2
```

这会触发：
1. Docker 镜像构建
2. 自动部署（如果配置了）
3. 创建 GitHub Release

---

## 📊 工作流状态徽章

在 README.md 中添加状态徽章：

```markdown
![CI](https://github.com/你的用户名/my-fullstack-app/workflows/CI%20-%20持续集成/badge.svg)
![Docker](https://github.com/你的用户名/my-fullstack-app/workflows/Docker%20-%20构建并推送镜像/badge.svg)
```

---

## 🔧 自定义配置

### 修改触发条件

编辑 `.github/workflows/ci.yml`：

```yaml
on:
  push:
    branches: [main, develop, feature/*]  # 添加更多分支
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'  # 每天午夜运行
```

---

### 添加环境变量

```yaml
env:
  NODE_VERSION: '20'
  DOCKER_REGISTRY: docker.io
```

---

### 跳过 CI

在提交信息中添加：

```powershell
git commit -m "docs: 更新文档 [skip ci]"
```

---

## ⚠️ 常见问题

### Q1: 工作流没有运行？

**检查**：
1. `.github/workflows/` 目录是否存在
2. YAML 文件格式是否正确
3. 触发条件是否满足

---

### Q2: Docker 构建失败？

**原因**：
- 没有配置 `DOCKER_USERNAME` 和 `DOCKER_PASSWORD`
- Docker Hub 登录失败
- Dockerfile 有错误

**解决**：
1. 检查 Secrets 配置
2. 本地测试 Docker 构建
3. 查看详细错误日志

---

### Q3: 部署失败？

**原因**：
- 服务器 SSH 配置错误
- 服务器路径不存在
- 权限不足

**解决**：
1. 测试 SSH 连接
2. 检查服务器路径
3. 确认用户权限

---

### Q4: 如何查看详细日志？

1. GitHub → Actions
2. 点击具体的工作流运行
3. 点击失败的任务
4. 展开步骤查看详细日志

---

## 📚 下一步学习

### 初级
- ✅ 理解 CI/CD 基本概念
- ✅ 配置基础工作流
- ⏳ 添加自动化测试

### 中级
- ⏳ 多环境部署（dev/staging/prod）
- ⏳ 添加代码质量检查（ESLint、Prettier）
- ⏳ 配置缓存优化构建速度

### 高级
- ⏳ 自定义 GitHub Actions
- ⏳ 矩阵构建（多版本、多平台）
- ⏳ 集成第三方服务（Slack 通知、性能监控）

---

## 🎓 学习资源

### 官方文档
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [工作流语法](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

### 视频教程
- [GitHub Actions 快速入门](https://www.youtube.com/watch?v=R8_veQiYBjI)
- [CI/CD 最佳实践](https://www.youtube.com/watch?v=scEDHsr3APg)

### 示例项目
- [actions/starter-workflows](https://github.com/actions/starter-workflows)
- [awesome-actions](https://github.com/sdras/awesome-actions)

---

## ✅ 检查清单

配置完成后，确认以下内容：

- [ ] GitHub Secrets 已配置
- [ ] 工作流文件已推送到 GitHub
- [ ] CI 工作流运行成功
- [ ] Docker 镜像构建成功（如果配置了）
- [ ] 理解每个工作流的作用
- [ ] 知道如何查看日志和调试

---

## 🎉 恭喜！

你已经成功配置了 CI/CD！

现在每次推送代码，GitHub Actions 都会自动：
- ✅ 检查代码质量
- ✅ 构建和测试
- ✅ 构建 Docker 镜像
- ✅ 自动部署（如果配置了）

继续学习，不断优化你的 CI/CD 流程！🚀
