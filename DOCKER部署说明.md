# 🐳 Docker 部署完整说明

## 📋 项目 Docker 化完成清单

### ✅ 已完成的工作

1. **数据库迁移**
   - ✅ 从 SQLite 迁移到 PostgreSQL
   - ✅ 更新 `backend-b/db.js` 使用 pg 驱动
   - ✅ 修改所有数据库查询为异步操作
   - ✅ 更新数据表结构

2. **Docker 配置文件**
   - ✅ 创建 `.dockerignore`
   - ✅ 创建 `frontend/Dockerfile`
   - ✅ 创建 `backend-a/Dockerfile`
   - ✅ 创建 `backend-b/Dockerfile`
   - ✅ 创建 `docker-compose.yml`

3. **代码更新**
   - ✅ 更新 `backend-a/server.js` 使用环境变量
   - ✅ 删除 MongoDB 相关配置
   - ✅ 统一使用 Node.js 20

4. **文档更新**
   - ✅ 更新 `README.md`
   - ✅ 更新 `DEMO演示脚本.md`
   - ✅ 创建 `.env.example`

---

## 🚀 一键启动命令

```bash
# 进入项目目录
cd C:\Users\95150\OneDrive\桌面\my-fullstack-app

# 启动所有服务
docker-compose up --build
```

---

## 📦 Docker 容器列表

| 容器名 | 服务 | 端口 | 说明 |
|--------|------|------|------|
| `todoapp-postgres` | PostgreSQL 15 | 5433 | 数据库服务（避免与本地冲突） |
| `todoapp-backend-b` | 后端B | 4000 | 数据存储服务 |
| `todoapp-backend-a` | 后端A | 3000 | 智能分类服务 |
| `todoapp-frontend` | 前端 | 5173 | React 应用 |

---

## 🔧 常用 Docker 命令

### 启动和停止

```bash
# 启动（前台运行，可以看到日志）
docker-compose up

# 启动（后台运行）
docker-compose up -d

# 重新构建并启动
docker-compose up --build

# 停止服务
docker-compose down

# 停止并删除数据卷（会清空数据库）
docker-compose down -v
```

### 查看状态

```bash
# 查看所有容器状态
docker-compose ps

# 查看所有 Docker 容器
docker ps

# 查看所有镜像
docker images
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs

# 实时查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs backend-b
docker-compose logs postgres

# 查看最近 100 行日志
docker-compose logs --tail=100 backend-b
```

### 进入容器

```bash
# 进入 PostgreSQL 容器
docker exec -it todoapp-postgres psql -U todouser -d todoapp

# 进入后端B容器
docker exec -it todoapp-backend-b sh

# 进入后端A容器
docker exec -it todoapp-backend-a sh
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart backend-b
```

---

## 🗄️ PostgreSQL 数据库操作

### 连接数据库

```bash
# 方法1：通过 Docker
docker exec -it todoapp-postgres psql -U todouser -d todoapp

# 方法2：从本地连接（如果安装了 psql）
psql -h localhost -p 5433 -U todouser -d todoapp
# 密码：todopass123
```

### 常用 SQL 命令

```sql
-- 查看所有表
\dt

-- 查看表结构
\d todos

-- 查看所有数据
SELECT * FROM todos;

-- 查看数据数量
SELECT COUNT(*) FROM todos;

-- 按类别统计
SELECT category, COUNT(*) FROM todos GROUP BY category;

-- 退出
\q
```

### 备份和恢复

```bash
# 备份数据库
docker exec todoapp-postgres pg_dump -U todouser todoapp > backup.sql

# 恢复数据库
docker exec -i todoapp-postgres psql -U todouser todoapp < backup.sql

# 导出为 CSV
docker exec todoapp-postgres psql -U todouser -d todoapp -c "COPY todos TO STDOUT WITH CSV HEADER" > todos.csv
```

---

## 🔍 故障排查

### 问题 1: 端口被占用

**错误信息：**
```
Error: bind: address already in use
```

**解决方案：**
```bash
# 查看端口占用
netstat -ano | findstr :5173
netstat -ano | findstr :4000
netstat -ano | findstr :3000
netstat -ano | findstr :5433

# 停止占用端口的进程，或修改 docker-compose.yml 中的端口映射
```

### 问题 2: PostgreSQL 端口冲突（5432 已被占用）

**原因：** 本地已安装 PostgreSQL 占用了 5432 端口

**解决方案：**
```bash
# 方案1：停止本地 PostgreSQL 服务
Stop-Service postgresql*

# 方案2：使用不同端口（已配置为 5433）
# docker-compose.yml 中已设置为 5433:5432
```

**说明：** 本项目默认使用 5433 端口避免冲突

### 问题 3: PostgreSQL 连接失败

**解决方案：**
```bash
# 查看 PostgreSQL 日志
docker-compose logs postgres

# 检查健康状态
docker inspect todoapp-postgres | findstr Health

# 重启 PostgreSQL
docker-compose restart postgres
```

### 问题 3: 前端无法连接后端

**解决方案：**
```bash
# 检查网络
docker network ls
docker network inspect my-fullstack-app_todoapp-network

# 检查容器是否在同一网络
docker inspect todoapp-frontend | findstr Network
docker inspect todoapp-backend-a | findstr Network
```

### 问题 4: 修改代码后不生效

**解决方案：**
```bash
# 重新构建镜像
docker-compose build backend-b

# 或者重新构建所有镜像
docker-compose build

# 然后重启
docker-compose up -d
```

### 问题 5: 数据丢失

**说明：**
数据存储在 Docker volume `postgres_data` 中，只有执行 `docker-compose down -v` 才会删除。

**查看数据卷：**
```bash
docker volume ls
docker volume inspect my-fullstack-app_postgres_data
```

---

## 📊 性能监控

### 查看资源使用

```bash
# 查看所有容器资源使用
docker stats

# 查看特定容器
docker stats todoapp-postgres
```

### 查看容器详情

```bash
# 查看容器详细信息
docker inspect todoapp-backend-b

# 查看容器进程
docker top todoapp-backend-b
```

---

## 🔐 安全建议

### 生产环境部署

1. **修改默认密码**
   - 在 `.env` 和 `docker-compose.yml` 中使用强密码
   - 不要提交 `.env` 到 Git

2. **使用环境变量**
   ```yaml
   environment:
     POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
   ```

3. **限制端口暴露**
   - 生产环境中，数据库端口不要暴露到外网
   - 只暴露前端和必要的 API 端口

4. **使用 Docker secrets**
   - 对于敏感信息，使用 Docker secrets 管理

---

## 🎯 下一步建议

### 短期改进

- [ ] 添加健康检查端点
- [ ] 配置日志轮转
- [ ] 添加数据库连接池配置
- [ ] 优化 Docker 镜像大小

### 中期改进

- [ ] 添加 Nginx 反向代理
- [ ] 配置 HTTPS
- [ ] 添加 Redis 缓存
- [ ] 实现数据库自动备份

### 长期规划

- [ ] 迁移到 Kubernetes
- [ ] 实现 CI/CD 自动化部署
- [ ] 添加监控和告警系统
- [ ] 实现多环境部署（开发/测试/生产）

---

## 🔗 使用 DBeaver 连接数据库

### 连接配置

```
主机:      127.0.0.1 或 localhost
端口:      5433          ← 注意不是 5432
数据库:    todoapp
用户名:    todouser
密码:      todopass123
```

### 驱动属性（如果连接失败）

在 DBeaver 的"驱动属性"中添加：
```
ssl = false
sslmode = disable
```

---

## 📚 相关资源

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [PostgreSQL Docker 镜像](https://hub.docker.com/_/postgres)
- [Node.js Docker 最佳实践](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

---

## ✅ 验证清单

部署完成后，验证以下内容：

- [ ] 所有 4 个容器都在运行
- [ ] 前端可以访问 (http://localhost:5173)
- [ ] 后端A可以访问 (http://localhost:3000/health)
- [ ] 后端B可以访问 (http://localhost:4000/health)
- [ ] PostgreSQL 可以连接
- [ ] 可以创建新任务
- [ ] 智能分类功能正常
- [ ] 数据持久化正常（重启容器后数据仍在）

---

**部署完成！🎉**

如有问题，请查看日志：`docker-compose logs -f`
