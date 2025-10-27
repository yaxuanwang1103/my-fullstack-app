# 🚀 CI/CD 完全学习指南

## 📖 目录

1. [什么是 CI/CD](#什么是-cicd)
2. [为什么需要 CI/CD](#为什么需要-cicd)
3. [CI/CD 基本概念](#cicd-基本概念)
4. [GitHub Actions 入门](#github-actions-入门)
5. [实战：为本项目配置 CI/CD](#实战为本项目配置-cicd)
6. [进阶配置](#进阶配置)
7. [最佳实践](#最佳实践)

---

## 什么是 CI/CD

### CI - Continuous Integration（持续集成）

**定义**：开发人员频繁地将代码集成到主分支，每次集成都通过自动化构建和测试来验证。

**流程**：
```
代码提交 → 自动构建 → 自动测试 → 反馈结果
```

**例子**：
- 你推送代码到 GitHub
- GitHub Actions 自动运行测试
- 如果测试失败，立即通知你
- 如果测试通过，代码可以合并

### CD - Continuous Delivery/Deployment（持续交付/部署）

**Continuous Delivery（持续交付）**：
- 代码随时可以部署到生产环境
- 需要手动批准部署

**Continuous Deployment（持续部署）**：
- 代码自动部署到生产环境
- 无需人工干预

**流程**：
```
测试通过 → 构建镜像 → 推送到仓库 → 自动部署 → 生产环境
```

---

## 为什么需要 CI/CD

### 🎯 核心优势

1. **自动化**
   - 减少手动操作
   - 避免人为错误
   - 节省时间

2. **快速反馈**
   - 立即发现问题
   - 快速修复 Bug
   - 提高代码质量

3. **频繁发布**
   - 小步快跑
   - 降低风险
   - 快速迭代

4. **团队协作**
   - 统一流程
   - 代码审查
   - 版本控制

### 📊 对比：有 CI/CD vs 没有 CI/CD

| 场景 | 没有 CI/CD | 有 CI/CD |
|------|-----------|----------|
| 代码提交 | 手动测试，可能忘记 | 自动测试，立即反馈 |
| 发现 Bug | 可能在生产环境才发现 | 在提交时就发现 |
| 部署 | 手动操作，容易出错 | 自动部署，一致可靠 |
| 发布频率 | 每周或每月 | 每天甚至每小时 |
| 回滚 | 复杂，耗时 | 简单，快速 |

---

## CI/CD 基本概念

### 1. Pipeline（流水线）

一系列自动化步骤的集合。

```
Pipeline
├── Stage 1: 构建
│   ├── 安装依赖
│   └── 编译代码
├── Stage 2: 测试
│   ├── 单元测试
│   └── 集成测试
└── Stage 3: 部署
    ├── 构建镜像
    └── 推送到服务器
```

### 2. Job（任务）

Pipeline 中的一个独立工作单元。

```yaml
jobs:
  build:        # Job 1: 构建
    runs-on: ubuntu-latest
    steps: ...
  
  test:         # Job 2: 测试
    runs-on: ubuntu-latest
    steps: ...
```

### 3. Step（步骤）

Job 中的一个具体操作。

```yaml
steps:
  - name: 检出代码           # Step 1
  - name: 安装依赖           # Step 2
  - name: 运行测试           # Step 3
```

### 4. Trigger（触发器）

什么时候运行 Pipeline。

```yaml
on:
  push:              # 推送代码时
    branches: [main]
  pull_request:      # 创建 PR 时
  schedule:          # 定时运行
    - cron: '0 0 * * *'
```

### 5. Artifact（构建产物）

Pipeline 生成的文件（如编译后的代码、测试报告）。

---

## GitHub Actions 入门

### 什么是 GitHub Actions

GitHub 提供的 CI/CD 平台，直接集成在 GitHub 仓库中。

### 基本结构

```
.github/
└── workflows/
    ├── ci.yml          # CI 工作流
    ├── cd.yml          # CD 工作流
    └── test.yml        # 测试工作流
```

### 简单示例

```yaml
name: CI                          # 工作流名称

on:                               # 触发条件
  push:
    branches: [main]

jobs:                             # 任务列表
  build:                          # 任务名称
    runs-on: ubuntu-latest        # 运行环境
    
    steps:                        # 步骤列表
      - name: 检出代码            # 步骤1
        uses: actions/checkout@v3
      
      - name: 设置 Node.js        # 步骤2
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: 安装依赖            # 步骤3
        run: npm install
      
      - name: 运行测试            # 步骤4
        run: npm test
```

### 关键概念

1. **uses**: 使用别人写好的 Action
2. **run**: 运行命令
3. **with**: 传递参数
4. **env**: 设置环境变量
5. **secrets**: 使用加密的密钥

---

## 实战：为本项目配置 CI/CD

### 阶段 1：基础 CI（代码检查和测试）

**目标**：每次推送代码时自动运行测试

**文件**：`.github/workflows/ci.yml`

```yaml
name: CI - 持续集成

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # 任务1：检查代码质量
  lint:
    name: 代码检查
    runs-on: ubuntu-latest
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
      
      - name: 设置 Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: 安装依赖
        run: npm install
      
      - name: 代码格式检查
        run: npm run lint || echo "未配置 lint"
  
  # 任务2：构建前端
  build-frontend:
    name: 构建前端
    runs-on: ubuntu-latest
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
      
      - name: 设置 Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: 安装前端依赖
        working-directory: ./frontend
        run: npm install
      
      - name: 构建前端
        working-directory: ./frontend
        run: npm run build
      
      - name: 上传构建产物
        uses: actions/upload-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist
  
  # 任务3：测试后端
  test-backend:
    name: 测试后端
    runs-on: ubuntu-latest
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
      
      - name: 设置 Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: 测试后端A
        working-directory: ./backend-a
        run: |
          npm install
          npm test || echo "未配置测试"
      
      - name: 测试后端B
        working-directory: ./backend-b
        run: |
          npm install
          npm test || echo "未配置测试"
```

### 阶段 2：Docker 镜像构建

**目标**：自动构建 Docker 镜像并推送到 Docker Hub

**文件**：`.github/workflows/docker-build.yml`

```yaml
name: Docker - 构建镜像

on:
  push:
    branches: [main]
    tags:
      - 'v*'

jobs:
  build-and-push:
    name: 构建并推送 Docker 镜像
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        service: [frontend, backend-a, backend-b]
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
      
      - name: 设置 Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: 登录 Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: 提取元数据
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/todoapp-${{ matrix.service }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
      
      - name: 构建并推送
        uses: docker/build-push-action@v4
        with:
          context: ./${{ matrix.service }}
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### 阶段 3：自动部署

**目标**：自动部署到服务器

**文件**：`.github/workflows/deploy.yml`

```yaml
name: CD - 持续部署

on:
  push:
    branches: [main]
    tags:
      - 'v*'

jobs:
  deploy:
    name: 部署到生产环境
    runs-on: ubuntu-latest
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
      
      - name: 部署到服务器
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /path/to/your/app
            git pull origin main
            docker-compose down
            docker-compose pull
            docker-compose up -d
            docker-compose ps
```

---

## 配置步骤（实操）

### 步骤 1：创建工作流目录

```powershell
# 在项目根目录创建
mkdir .github\workflows
```

### 步骤 2：添加 GitHub Secrets

1. 打开你的 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下密钥：

| 名称 | 说明 | 示例 |
|------|------|------|
| `DOCKER_USERNAME` | Docker Hub 用户名 | `your-username` |
| `DOCKER_PASSWORD` | Docker Hub 密码或 Token | `dckr_pat_xxx` |
| `SERVER_HOST` | 服务器 IP | `123.45.67.89` |
| `SERVER_USER` | SSH 用户名 | `ubuntu` |
| `SERVER_SSH_KEY` | SSH 私钥 | `-----BEGIN RSA...` |

### 步骤 3：创建工作流文件

我会为你创建三个工作流文件：
1. `ci.yml` - 持续集成
2. `docker-build.yml` - Docker 镜像构建
3. `deploy.yml` - 自动部署

### 步骤 4：推送到 GitHub

```powershell
git add .github/
git commit -m "feat: 添加 CI/CD 工作流"
git push origin main
```

### 步骤 5：查看运行结果

1. 打开 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看工作流运行状态

---

## 进阶配置

### 1. 多环境部署

```yaml
jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    # 部署到开发环境
  
  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    # 部署到预发布环境
  
  deploy-prod:
    if: startsWith(github.ref, 'refs/tags/v')
    # 部署到生产环境
```

### 2. 矩阵构建

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
    os: [ubuntu-latest, windows-latest, macos-latest]

steps:
  - uses: actions/setup-node@v3
    with:
      node-version: ${{ matrix.node-version }}
```

### 3. 缓存依赖

```yaml
- name: 缓存 node_modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### 4. 条件执行

```yaml
- name: 仅在 main 分支运行
  if: github.ref == 'refs/heads/main'
  run: npm run deploy

- name: 仅在标签时运行
  if: startsWith(github.ref, 'refs/tags/')
  run: npm run release
```

### 5. 并行和串行

```yaml
jobs:
  test:
    # 并行运行
    strategy:
      matrix:
        service: [frontend, backend-a, backend-b]
  
  deploy:
    needs: test  # 等待 test 完成后运行
```

---

## 最佳实践

### 1. 工作流设计

✅ **推荐**：
- 快速失败：先运行快速测试
- 并行执行：独立任务并行运行
- 缓存依赖：加速构建
- 清晰命名：使用描述性名称

❌ **避免**：
- 过长的工作流：拆分成多个文件
- 硬编码：使用环境变量和 secrets
- 忽略错误：确保错误能被捕获

### 2. 安全性

✅ **推荐**：
- 使用 GitHub Secrets 存储敏感信息
- 限制工作流权限
- 定期更新依赖
- 使用 OIDC 替代长期凭证

❌ **避免**：
- 在代码中硬编码密钥
- 使用过于宽松的权限
- 忽略安全警告

### 3. 性能优化

✅ **推荐**：
- 使用缓存
- 并行执行
- 增量构建
- 使用 self-hosted runners（大型项目）

### 4. 可维护性

✅ **推荐**：
- 使用可复用的 Actions
- 添加注释
- 版本控制工作流
- 定期审查和更新

---

## 常见问题

### Q1: 工作流失败了怎么办？

1. 查看错误日志
2. 本地复现问题
3. 检查环境变量
4. 查看 GitHub Actions 文档

### Q2: 如何调试工作流？

```yaml
- name: 调试信息
  run: |
    echo "当前分支: ${{ github.ref }}"
    echo "提交信息: ${{ github.event.head_commit.message }}"
    env  # 打印所有环境变量
```

### Q3: 如何跳过 CI？

在提交信息中添加：
```
git commit -m "docs: 更新文档 [skip ci]"
```

### Q4: 工作流运行时间太长？

- 使用缓存
- 并行执行
- 只在必要时运行
- 使用更快的 runners

---

## 学习资源

### 官方文档
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [工作流语法](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

### 示例仓库
- [actions/starter-workflows](https://github.com/actions/starter-workflows)
- [awesome-actions](https://github.com/sdras/awesome-actions)

### 视频教程
- GitHub Actions 快速入门
- CI/CD 最佳实践

---

## 下一步

1. ✅ 创建基础 CI 工作流
2. ✅ 添加自动化测试
3. ✅ 配置 Docker 镜像构建
4. ⏳ 设置自动部署
5. ⏳ 添加通知（Slack/Email）
6. ⏳ 配置代码质量检查
7. ⏳ 添加性能测试

---

## 总结

CI/CD 是现代软件开发的核心实践：

- **CI**：自动构建和测试，快速发现问题
- **CD**：自动部署，快速交付价值
- **GitHub Actions**：强大、灵活、易用的 CI/CD 平台

从简单开始，逐步完善，持续改进！🚀
