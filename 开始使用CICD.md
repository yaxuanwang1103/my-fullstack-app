# 🚀 开始使用 CI/CD - 操作清单

## ✅ 你已经拥有的文件

我已经为你创建了以下文件：

### GitHub Actions 工作流
```
.github/workflows/
├── ci.yml              ✅ 持续集成
├── docker-build.yml    ✅ Docker 镜像构建
├── deploy.yml          ✅ 自动部署
└── release.yml         ✅ 自动发布
```

### 测试文件
```
backend-a/test.js       ✅ 后端A测试
backend-b/test.js       ✅ 后端B测试
```

### 文档
```
CICD完全学习指南.md     ✅ 详细教程
CICD快速配置指南.md     ✅ 快速上手
CICD学习总结.md         ✅ 学习总结
开始使用CICD.md         ✅ 本文档
```

---

## 📋 接下来要做的事（按顺序）

### 第一步：推送代码到 GitHub（必需）

```powershell
# 1. 查看新增的文件
git status

# 2. 添加所有文件
git add .

# 3. 提交
git commit -m "feat: 添加 CI/CD 配置

- 添加 GitHub Actions 工作流（CI、Docker构建、部署、发布）
- 添加后端测试文件
- 添加 CI/CD 学习文档
- 更新 README 添加 CI/CD 说明"

# 4. 推送到 GitHub
git push origin main
```

**推送后会发生什么？**
- GitHub Actions 会自动运行 CI 工作流
- 你可以在 GitHub → Actions 标签中看到运行状态

---

### 第二步：查看 CI 运行结果（必需）

1. 打开你的 GitHub 仓库
2. 点击顶部的 **Actions** 标签
3. 你会看到 "CI - 持续集成" 工作流正在运行
4. 点击进去查看详细日志

**预期结果：**
- ✅ 代码检查通过
- ✅ 前端构建成功
- ✅ 后端检查通过
- ✅ Docker 构建测试通过

如果失败了，查看错误日志并修复问题。

---

### 第三步：配置 Docker Hub（可选，推荐）

如果你想自动构建和推送 Docker 镜像：

#### 3.1 获取 Docker Hub Token

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → **Account Settings**
3. 左侧菜单 → **Security**
4. 点击 **New Access Token**
5. 输入描述（如 "GitHub Actions"）
6. 点击 **Generate**
7. **立即复制 Token**（只显示一次！）

#### 3.2 添加 GitHub Secrets

1. 打开你的 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加两个 Secret：

| 名称 | 值 |
|------|-----|
| `DOCKER_USERNAME` | 你的 Docker Hub 用户名 |
| `DOCKER_PASSWORD` | 刚才复制的 Token |

#### 3.3 测试 Docker 构建

```powershell
# 推送到 main 分支会自动触发
git push origin main

# 或者在 GitHub Actions 页面手动触发
# Actions → Docker - 构建并推送镜像 → Run workflow
```

---

### 第四步：配置服务器部署（可选）

如果你有服务器并想自动部署：

#### 4.1 生成 SSH 密钥（如果还没有）

```powershell
# 生成密钥对
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 查看私钥
cat ~/.ssh/id_rsa

# 将公钥添加到服务器
ssh-copy-id user@server-ip
```

#### 4.2 添加服务器 Secrets

在 GitHub Secrets 中添加：

| 名称 | 值 | 示例 |
|------|-----|------|
| `SERVER_HOST` | 服务器 IP | `123.45.67.89` |
| `SERVER_USER` | SSH 用户名 | `ubuntu` |
| `SERVER_SSH_KEY` | SSH 私钥内容 | 完整的私钥 |

#### 4.3 修改部署脚本

编辑 `.github/workflows/deploy.yml`，将路径改为你的实际路径：
```yaml
cd /path/to/your/app  # 改为你的项目路径
```

---

## 🎯 快速测试指南

### 测试 CI 工作流

```powershell
# 修改一个文件
echo "# CI Test" >> README.md

# 提交并推送
git add README.md
git commit -m "test: 测试 CI"
git push origin main
```

然后在 GitHub Actions 中查看运行结果。

---

### 测试 Docker 构建（需要配置 Secrets）

```powershell
# 推送到 main 会自动触发
git push origin main
```

---

### 测试发布流程

```powershell
# 创建版本标签
git tag -a v2.2.0 -m "测试版本 2.2.0"
git push origin v2.2.0
```

这会触发：
1. ✅ Docker 镜像构建
2. ✅ 创建 GitHub Release
3. ✅ 自动部署（如果配置了）

---

## 📊 工作流状态徽章

在 README.md 中添加状态徽章，显示 CI 状态：

```markdown
![CI](https://github.com/你的用户名/my-fullstack-app/workflows/CI%20-%20持续集成/badge.svg)
![Docker Build](https://github.com/你的用户名/my-fullstack-app/workflows/Docker%20-%20构建并推送镜像/badge.svg)
```

替换 `你的用户名` 为你的 GitHub 用户名。

---

## 🔍 检查清单

完成配置后，确认以下内容：

### 基础配置（必需）
- [ ] 代码已推送到 GitHub
- [ ] CI 工作流运行成功
- [ ] 能在 Actions 标签中看到工作流

### Docker 配置（可选）
- [ ] Docker Hub Token 已创建
- [ ] GitHub Secrets 已配置
- [ ] Docker 构建工作流运行成功
- [ ] 镜像已推送到 Docker Hub

### 部署配置（可选）
- [ ] SSH 密钥已生成
- [ ] 服务器 Secrets 已配置
- [ ] 部署脚本路径已修改
- [ ] 部署工作流测试成功

---

## ⚠️ 常见问题

### Q1: CI 工作流失败了？

**检查步骤：**
1. 查看详细错误日志
2. 确认 Node.js 版本兼容
3. 确认依赖安装成功
4. 本地测试 `npm install` 和 `npm run build`

---

### Q2: Docker 构建失败？

**可能原因：**
- 没有配置 `DOCKER_USERNAME` 和 `DOCKER_PASSWORD`
- Docker Hub 登录失败
- Dockerfile 有错误

**解决方法：**
1. 检查 Secrets 配置是否正确
2. 本地测试 Docker 构建
3. 查看详细错误日志

---

### Q3: 如何跳过 CI？

在提交信息中添加 `[skip ci]`：
```powershell
git commit -m "docs: 更新文档 [skip ci]"
```

---

### Q4: 如何手动触发工作流？

1. GitHub → Actions
2. 选择要运行的工作流
3. 点击 "Run workflow" 按钮
4. 选择分支
5. 点击绿色的 "Run workflow"

---

## 📚 学习资源

### 推荐阅读顺序

1. **CICD完全学习指南.md** - 理解 CI/CD 概念
2. **CICD快速配置指南.md** - 快速上手配置
3. **CICD学习总结.md** - 回顾和总结
4. **本文档** - 实际操作步骤

### 官方文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [工作流语法](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Docker Hub 文档](https://docs.docker.com/docker-hub/)

---

## 🎉 完成后你将拥有

✅ **自动化构建** - 每次推送代码自动构建和测试  
✅ **自动化测试** - 自动运行测试，确保代码质量  
✅ **Docker 镜像** - 自动构建和推送 Docker 镜像  
✅ **自动部署** - 创建标签自动部署到服务器  
✅ **自动发布** - 自动创建 GitHub Release  

---

## 🚀 现在就开始！

```powershell
# 第一步：推送代码
git add .
git commit -m "feat: 添加 CI/CD 配置"
git push origin main

# 第二步：打开 GitHub Actions
# 在浏览器中访问：https://github.com/你的用户名/my-fullstack-app/actions

# 第三步：观察工作流运行
# 点击 "CI - 持续集成" 查看详细日志
```

---

## 💡 提示

- 从简单开始，先让 CI 工作流运行起来
- 逐步添加 Docker 构建和部署
- 遇到问题查看详细日志
- 不要害怕失败，CI/CD 就是为了快速发现问题

---

祝你学习顺利！🎓

有问题随时查看文档或在 GitHub Issues 中提问。
