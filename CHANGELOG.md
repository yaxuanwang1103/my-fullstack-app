# 📝 更新日志 (Changelog)

本文档记录项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

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
