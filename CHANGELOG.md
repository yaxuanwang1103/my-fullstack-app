# 📝 更新日志 (Changelog)

本文档记录项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [2.3.1] - 2025-10-27

### 🚀 新增
- **AWS ECR 集成**：切换到 AWS Elastic Container Registry
  - 更新 GitHub Actions 工作流使用 ECR
  - 添加 ECR 仓库创建脚本
  - 完整的 AWS ECR 使用指南

### 🐛 修复
- 修复 Backend-B SSL 连接错误
  - 禁用 PostgreSQL SSL 连接（本地开发环境）
  - Backend-B 不再崩溃重启

### 📚 文档
- 添加 `AWS_ECR使用指南.md`
- 添加 `create-ecr-repos.sh` 脚本
- 更新 README 添加 AWS ECR 集成阶段

---

## [2.3.0] - 2025-10-27

### 🚀 新增
- **访问统计功能**：后端自动记录访问次数、创建任务数、运行时间
  - `/api/stats` 接口查看统计数据
  - 自动记录每次请求的时间和 IP
- **可视化监控仪表板**：`监控仪表板.html`
  - 实时显示系统状态、访问统计、数据库统计
  - 自动每 10 秒刷新
  - 实时日志显示
- **Docker 可视化工具**：
  - Portainer 安装脚本（Docker 管理界面）
  - Dozzle 安装脚本（实时日志查看器）

### 🔧 改进
- 后端添加详细的请求日志
- 增强日志输出格式（时间戳 + IP）
- 优化数据库端口配置（避免冲突）

### 📚 文档
- 更新 README 添加可视化监控工具说明
- 完善监控和日志使用指南

---

## [2.2.2] - 2025-10-27

### 🚀 新增
- **监控和日志系统**：完整的监控和日志管理工具
  - `monitor.bat` - 实时监控服务状态和资源使用
  - `view-logs.bat` - 查看和管理日志
  - `view-data.bat` - 查看数据库数据和统计
  - `监控和日志指南.md` - 详细的监控文档

### 📚 文档
- 新增监控和日志完整指南
- 更新 README 添加监控工具说明
- 更新演示脚本到 v2.2.2

### 🔧 改进
- 提供便捷的批处理脚本快速查看系统状态
- 完善数据库查询和统计功能
- 添加故障排查和日志分析指南

---

## [2.2.1] - 2025-10-27

### 🚀 新增
- **CI/CD 自动化**：完整的 GitHub Actions 工作流配置
  - 持续集成（代码检查、构建、测试）
  - Docker 镜像自动构建和推送
  - 自动部署到服务器
  - 自动创建 GitHub Release
- 添加后端测试文件（backend-a/test.js, backend-b/test.js）
- 完整的 CI/CD 学习文档

### 🔧 修复
- 升级 actions/upload-artifact 到 v4（修复弃用警告）

### 📚 文档
- 新增 `CICD完全学习指南.md` - 详细的 CI/CD 教程
- 新增 `CICD快速配置指南.md` - 快速上手指南
- 新增 `CICD学习总结.md` - 学习总结
- 新增 `开始使用CICD.md` - 操作清单
- 更新 README.md 添加 CI/CD 章节

### 🔄 变更
- 项目进入阶段 7：CI/CD 自动化

---

## [2.1.1] - 2025-10-26

### 📚 文档
- 新增 `推送到GitHub指南.md` - 完整的 GitHub 推送教程
- 更新版本号到 2.1.1
- 完善项目文档结构

### 🔧 维护
- 统一版本号管理
- 优化发布流程

---

## [2.1.0] - 2025-10-26

### ✨ 新增
- **前端功能完善**：修复 API 连接问题，前端完全可用
  - 任务添加功能正常工作
  - 任务列表显示正常
  - 统计功能实时更新
  - 智能分类提示正常显示
- 脚本：`scripts/ecs-register-update.ps1`（一键注册任务并更新 frontend/backend-a/backend-b 服务）
- 脚本：`scripts/ecs-open-ports.ps1`（开放端口，支持多个服务/端口/来源，兼容 PowerShell 逗号参数）
- 脚本：`scripts/ecs-restrict-ports.ps1`（将端口入站收紧至指定 IP/段）
- 脚本：`scripts/frontend-build-push.ps1`（前端生产镜像构建/推送，支持 `-SkipLogin` 绕过 PowerShell 管道问题）
- 脚本：`scripts/route53-update-a-record.ps1`（可选；将域名 A 记录指向当前 ECS 任务 Public IP）
- 前端生产镜像支持：`frontend/Dockerfile`（多阶段构建 + Nginx 80）、`frontend/nginx.conf`（SPA 路由）

### 🔧 修复
- **前端 API 连接问题**：修复开发环境下的 API 基础 URL 配置
- **CORS 配置优化**：确保前后端通信正常
- **Docker 网络配置**：优化容器间通信

### 🔄 变更
- `frontend/src/App.jsx` 改为使用 `VITE_API_URL` 作为 API 基址（构建时注入）
- `task-definition-frontend.json` 移除运行时 `VITE_API_URL` 环境变量（生产镜像改为构建时注入）
- `task-definition-backend-a.json`/`task-definition-backend-b.json` 显式加入 `hostPort`（3000/4000）
- 移除任务定义中 `awslogs-create-group` 以符合 ECS 日志配置规范

### 🔐 安全
- 建议前端 80 端口保持公开；后端 3000/4000 端口仅允许运营者公网 IP 访问（提供收紧/放行脚本）

### 🧩 兼容性与注意事项
- 账户暂未开放创建 Load Balancer；当前通过任务 Public IP + 安全组进行对外/内互访。
- 待解禁后可切换 ALB/NLB + Route 53，以获得稳定入口与 HTTPS。

### 📊 测试状态
- ✅ 本地 Docker 部署：完全正常
- ✅ 前端界面：完全可用
- ✅ 任务添加：正常工作
- ✅ 智能分类：正常工作
- ✅ 统计功能：正常工作

## [2.0.2] - 2024-10-25

### 📚 文档新增

#### ✨ 新增完全零基础指南
- **AWS部署-ECS-完全零基础指南.md** (新文件)
  - 从 AWS 账户注册开始的完整指南
  - 详细的 IAM 用户创建步骤（解释为什么不用 Root 用户）
  - Access Key 获取和保存的完整流程
  - AWS CLI 安装、配置、验证的详细步骤
  - Docker Desktop 安装和测试
  - 完整的故障排查指南
  - 部署前检查清单

#### 🎯 解决的问题
- 新手不理解为什么需要 IAM 用户
- 不清楚 Access Key 的作用和获取方式
- 不知道如何从零开始准备 AWS 环境
- 缺少完整的准备工作流程

#### 📖 文档结构
- **第一部分**：AWS 账户准备（注册、登录）
- **第二部分**：IAM 用户设置（创建用户、设置权限、获取密钥）
- **第三部分**：本地工具安装（AWS CLI、Docker Desktop）
- **第四部分**：ECS 部署（检查清单、开始部署）

#### 🔧 改进
- 每个步骤都有详细说明和截图指引
- 包含"为什么"的解释，不只是"怎么做"
- 添加常见错误和解决方案
- 提供安全最佳实践建议
- 包含费用说明和成本控制建议

---

## [2.0.1] - 2024-10-25

### 📚 文档更新

#### ✨ 新增内容
- **ECS Fargate 部署文档全面升级** (`AWS部署-方案2-ECS.md`)
  - 添加架构说明和快速导航
  - 新增详细的前置准备步骤（AWS CLI 配置、Docker 安装）
  - 完善 RDS 数据库创建说明
  - 优化镜像构建和推送步骤说明

- **故障排查指南** (新增章节)
  - 问题1: 任务无法启动（镜像拉取失败、资源不足、网络配置错误）
  - 问题2: 无法访问应用（安全组配置、公网IP、端口连接）
  - 问题3: 数据库连接失败（常见错误和解决方法）
  - 问题4: 服务间无法通信（安全组内部通信规则）

- **成本优化建议** (新增章节)
  - 详细的成本计算（$70-90/月）
  - 4种优化方案：降低资源配置、使用Spot容量、Savings Plans、合并服务
  - 每种方案的节省比例和适用场景

- **监控最佳实践** (新增章节)
  - CloudWatch 告警设置示例
  - 关键指标查看方法
  - CPU/内存监控配置

- **下一步优化指南** (新增章节)
  - 配置 Application Load Balancer (ALB)
  - 配置自动扩展策略
  - 使用 Secrets Manager 存储敏感信息
  - 配置 CI/CD（GitHub Actions 示例）

#### 🔧 改进
- 添加预期输出示例（登录成功、镜像推送等）
- 完善错误处理说明（登录失败、构建失败等）
- 增强文档可读性（添加图标、分段说明）
- 添加更多验证命令（检查状态、测试连接）
- 优化任务定义说明（CPU/内存配置解释）

#### 📊 新增对比表格
- ECS Fargate vs App Runner vs EC2 详细对比
- 推荐使用场景说明
- 何时选择其他方案的建议

#### 🎯 文档结构优化
- 添加快速导航目录
- 重组章节结构（前置准备、部署步骤、故障排查、优化建议）
- 统一命令格式和代码块样式

---

## [2.0.0] - 2024-10-25

### 🎉 重大更新：Docker 容器化部署

#### ✨ 新增功能
- **Docker 容器化**: 所有服务完整 Docker 化
  - 前端容器 (todoapp-frontend)
  - 后端A容器 (todoapp-backend-a)
  - 后端B容器 (todoapp-backend-b)
  - PostgreSQL 容器 (todoapp-postgres)
- **一键启动脚本**: 
  - `start-docker.bat` - 智能启动，自动处理端口冲突
  - `start-docker.ps1` - PowerShell 高级启动脚本
  - `stop-docker.bat` - 快速停止脚本
  - `check-ports.bat` - 端口检查工具
- **完整文档**:
  - `DOCKER部署说明.md` - Docker 部署完整指南
  - `端口说明.md` - 端口配置详细说明
  - `启动脚本使用说明.md` - 脚本使用教程
  - `避免端口冲突方案.md` - 端口冲突解决方案

#### 🔧 修复
- **Node.js 版本升级**: 所有 Dockerfile 升级到 Node.js 20
  - 修复 Vite 兼容性问题 (需要 Node.js 20.19+)
  - 解决 `crypto.hash is not a function` 错误
- **端口配置优化**:
  - PostgreSQL 端口: 5432 → 5433 (避免与本地 PostgreSQL 冲突)
  - 前端端口统一: 5175 → 5173
  - 添加 PostgreSQL md5 认证方式
- **DBeaver 连接问题**: 
  - 添加 `POSTGRES_HOST_AUTH_METHOD: md5`
  - 解决密码认证失败问题

#### 📚 文档更新
- 更新 `README.md` 反映 Docker 部署方式
- 更新所有端口引用 (5432 → 5433)
- 添加 DBeaver 连接配置说明
- 添加端口冲突解决方案文档

#### ⚙️ 配置变更
- `docker-compose.yml`:
  - PostgreSQL 端口映射: `5433:5432`
  - 添加健康检查配置
  - 添加服务依赖关系
  - 添加网络配置
- `frontend/vite.config.js`:
  - 端口统一为 5173
  - 添加 `host: '0.0.0.0'` 支持容器访问

#### 🗄️ 数据库迁移
- 从 SQLite 完全迁移到 PostgreSQL
- 容器化数据库部署
- 数据持久化配置

---

## [1.2.0] - 2024-10-24

### ✨ 新增功能
- **双后端协作架构**: 拆分为后端A（智能分类）和后端B（数据存储）
- **智能任务分类**: 
  - 自动识别任务类型（工作/学习/生活/其他）
  - 自动识别优先级（高/中/低）
  - 自动提取截止日期

### 🔧 改进
- 前端 UI 优化：渐变背景、卡片式布局
- 添加实时统计分析功能
- 改进数据可视化展示

---

## [1.1.0] - 2024-10-23

### 🗄️ 数据库升级
- 从 SQLite 迁移到 PostgreSQL
- 添加 pg 驱动
- 优化数据库连接配置

---

## [1.0.0] - 2024-10-22

### 🎉 初始版本
- ✅ 基础待办清单功能
- ✅ React + Vite 前端
- ✅ Express 后端
- ✅ SQLite 数据库
- ✅ 基础的增删查改功能

---

## 版本说明

### 版本号格式：主版本号.次版本号.修订号

- **主版本号 (Major)**: 重大架构变更、不兼容的 API 修改
  - 例如：1.x.x → 2.0.0 (Docker 容器化)
  
- **次版本号 (Minor)**: 新增功能、向后兼容的改进
  - 例如：1.1.x → 1.2.0 (双后端架构)
  
- **修订号 (Patch)**: Bug 修复、小改进
  - 例如：1.1.0 → 1.1.1 (修复小问题)

---

## 变更类型说明

- **✨ 新增 (Added)**: 新功能
- **🔧 修复 (Fixed)**: Bug 修复
- **🔄 变更 (Changed)**: 现有功能的变更
- **🗑️ 废弃 (Deprecated)**: 即将移除的功能
- **❌ 移除 (Removed)**: 已移除的功能
- **🔒 安全 (Security)**: 安全相关的修复

---

## 升级指南

### 从 1.x 升级到 2.0.0

#### 必要步骤：

1. **安装 Docker Desktop**
   ```bash
   # 下载并安装 Docker Desktop
   # https://www.docker.com/products/docker-desktop
   ```

2. **停止旧版本服务**
   ```bash
   # 停止本地运行的服务
   # Ctrl+C 停止 npm start
   ```

3. **使用 Docker 启动**
   ```bash
   # 方式1：使用脚本（推荐）
   双击 start-docker.bat
   
   # 方式2：使用命令
   docker-compose up --build
   ```

4. **更新数据库连接**
   - DBeaver/pgAdmin 连接端口: 5432 → 5433
   - 主机: localhost 或 127.0.0.1
   - 用户名: todouser
   - 密码: todopass123

#### 配置变更：

- **环境变量**: 
  - 不再需要本地 `.env` 文件（Docker 容器内配置）
  
- **端口变更**:
  - PostgreSQL: 5432 → 5433
  - 前端: 5175 → 5173

#### 数据迁移：

如果有旧数据需要迁移：
```bash
# 1. 从旧 PostgreSQL 导出
pg_dump -U postgres todoapp > backup.sql

# 2. 导入到 Docker PostgreSQL
docker exec -i todoapp-postgres psql -U todouser -d todoapp < backup.sql
```

---

## 已知问题

### 2.0.0 版本

- [ ] Windows 本地 PostgreSQL 可能与 Docker 端口冲突
  - **解决方案**: 使用 `start-docker.bat` 自动处理
  - **或**: 停止本地 PostgreSQL 服务

---

## 路线图

### 近期计划 (v2.1.0)

- [ ] 添加用户认证功能
- [ ] 实现任务分享功能
- [ ] 添加任务提醒通知
- [ ] 优化移动端适配

### 中期计划 (v2.2.0)

- [ ] 添加 Nginx 反向代理
- [ ] 配置 HTTPS
- [ ] 添加 Redis 缓存
- [ ] 实现数据库自动备份

### 长期计划 (v3.0.0)

- [ ] 迁移到 Kubernetes
- [ ] 实现 CI/CD 自动化部署
- [ ] 添加监控和告警系统
- [ ] 实现多环境部署（开发/测试/生产）

---

## 贡献者

感谢所有为本项目做出贡献的开发者！

---

## 支持

如有问题，请查看：
- [README.md](./README.md) - 项目说明
- [DOCKER部署说明.md](./DOCKER部署说明.md) - Docker 部署指南
- [启动脚本使用说明.md](./启动脚本使用说明.md) - 脚本使用教程

或提交 Issue 到 GitHub。
