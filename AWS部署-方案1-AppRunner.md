# 🚀 方案1: AWS App Runner 完整部署步骤

**难度**: ⭐ 简单  
**时间**: 15-30 分钟  
**成本**: $20-35/月（小流量）

---

## 📋 前置准备

### 1. 注册 AWS 账号

1. 访问 https://aws.amazon.com/cn/
2. 点击右上角"创建 AWS 账户"
3. 填写以下信息：
   - 电子邮件地址
   - 密码
   - AWS 账户名称（例如：my-todoapp）
4. 选择账户类型：**个人**
5. 填写联系信息（姓名、地址、电话）
6. 添加付款信息（信用卡，会扣 $1 验证）
7. 验证身份（手机验证码）
8. 选择支持计划：**基本支持 - 免费**
9. 完成注册

### 2. 获取 AWS 访问密钥

1. 登录 AWS 控制台：https://console.aws.amazon.com/
2. 右上角点击您的用户名 → **"安全凭证"**
3. 滚动到"访问密钥"部分
4. 点击**"创建访问密钥"**
5. 选择用例：**"命令行界面 (CLI)"**
6. 勾选"我了解..."，点击**"下一步"**
7. 描述标签：`my-todoapp-cli`
8. 点击**"创建访问密钥"**
9. **⚠️ 重要**：点击**"下载 .csv 文件"**并保存
   - Access Key ID: `AKIA...`（20 个字符）
   - Secret Access Key: `wJalrXUtn...`（40 个字符）
10. **注意**：这是唯一一次看到 Secret Access Key，请妥善保存

### 3. 准备 GitHub 仓库

```powershell
# 在项目目录下
cd c:\Users\95150\OneDrive\桌面\my-fullstack-app

# 检查 Git 状态
git status

# 如果还没有初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Prepare for AWS App Runner deployment"

# 在 GitHub 上创建新仓库
# 访问 https://github.com/new
# 仓库名称：my-fullstack-app
# 可见性：Public 或 Private
# 不要初始化 README、.gitignore 或 license

# 添加远程仓库
git remote add origin https://github.com/你的用户名/my-fullstack-app.git

# 推送代码
git branch -M main
git push -u origin main
```

---

## 🗄️ 步骤1: 创建 RDS PostgreSQL 数据库

### 1.1 进入 RDS 控制台

1. 登录 AWS 控制台：https://console.aws.amazon.com/
2. 在顶部搜索框输入 **"RDS"**，点击进入
3. **⚠️ 重要**：确保右上角区域选择 **"美国东部（弗吉尼亚北部）us-east-1"**

### 1.2 创建数据库

1. 点击左侧菜单 **"数据库"**
2. 点击橙色按钮 **"创建数据库"**

#### 引擎选项
- **引擎类型**: `PostgreSQL`
- **版本**: `PostgreSQL 15.5-R2`（或最新的 15.x 版本）

#### 模板
- 选择: **`免费套餐`**（如果可用）
- 如果没有免费套餐，选择: **`开发/测试`**

#### 设置
- **数据库实例标识符**: `todoapp-db`
- **主用户名**: `todouser`
- **主密码**: 设置强密码，例如：`TodoApp2024!Secure`
- **确认密码**: 再次输入密码
- **⚠️ 重要**：将密码保存到安全的地方！

#### 实例配置
- **数据库实例类**: `db.t3.micro`（免费套餐）
- 如果没有 t3.micro，选择 `db.t4g.micro`

#### 存储
- **存储类型**: `通用型 SSD (gp3)`
- **分配的存储**: `20 GB`
- **取消勾选** "启用存储自动扩展"（节省成本）

#### 连接
- **计算资源**: `不连接到 EC2 计算资源`
- **网络类型**: `IPv4`
- **虚拟私有云 (VPC)**: 选择默认 VPC
- **公开访问**: **⚠️ 选择"是"**（重要！用于本地连接）
- **VPC 安全组**: `创建新的`
- **新 VPC 安全组名称**: `todoapp-db-sg`
- **可用区**: `无首选项`

#### 数据库身份验证
- 选择: **`密码身份验证`**

#### 监控
- **取消勾选** "启用增强监控"（节省成本）

#### 其他配置（点击展开）
- **初始数据库名称**: `todoapp` **⚠️ 重要！必须填写**
- **取消勾选** "启用自动备份"（开发环境，节省成本）
- **取消勾选** "启用加密"（开发环境）

#### 创建
1. 滚动到底部，点击 **"创建数据库"**
2. **等待 5-10 分钟**，状态从"创建中"变为"可用"
3. 可以点击数据库名称查看创建进度

### 1.3 配置安全组（允许外部访问）

1. 数据库状态变为"可用"后，点击数据库名称 **`todoapp-db`**
2. 滚动到 **"连接与安全性"** 部分
3. 在 **"VPC 安全组"** 下，点击链接（类似 `todoapp-db-sg`）
4. 在新页面，点击 **"入站规则"** 标签
5. 点击 **"编辑入站规则"**
6. 点击 **"添加规则"**：
   - **类型**: `PostgreSQL`
   - **协议**: `TCP`
   - **端口范围**: `5432`
   - **源**: `0.0.0.0/0`
   - **描述**: `Allow PostgreSQL from anywhere`
7. 再点击 **"添加规则"**（支持 IPv6）：
   - **类型**: `PostgreSQL`
   - **源**: `::/0`
   - **描述**: `Allow PostgreSQL from anywhere IPv6`
8. 点击 **"保存规则"**

### 1.4 获取数据库端点

1. 返回 RDS 控制台：https://console.aws.amazon.com/rds/
2. 点击数据库 **`todoapp-db`**
3. 在 **"连接与安全性"** 部分，找到 **"端点"**
4. 复制端点地址，格式类似：
   ```
   todoapp-db.c9akxxxxxx.us-east-1.rds.amazonaws.com
   ```
5. **⚠️ 保存这个端点地址！**（后面会用到）

### 1.5 测试本地连接（可选但推荐）

#### 使用 DBeaver 测试

1. 打开 DBeaver
2. 点击 **"新建连接"** → 选择 **`PostgreSQL`**
3. 填写连接信息：
   - **Host**: `todoapp-db.c9akxxxxxx.us-east-1.rds.amazonaws.com`
   - **Port**: `5432`
   - **Database**: `todoapp`
   - **Username**: `todouser`
   - **Password**: 您设置的密码
   - 勾选 **"保存密码"**
4. 点击 **"测试连接"**
5. 如果显示 **"连接成功"**，点击 **"完成"**
6. 如果连接失败，检查：
   - 安全组入站规则是否正确
   - 数据库是否为"可用"状态
   - 端点地址是否正确

---

## 🚀 步骤2: 部署后端B（数据存储服务）

### 2.1 进入 App Runner 控制台

1. 访问：https://console.aws.amazon.com/apprunner/
2. 确保区域是 **`us-east-1`**（美国东部）
3. 点击橙色按钮 **"创建服务"**

### 2.2 配置源和部署

#### 源
1. **存储库类型**: `源代码存储库`
2. **提供商**: `GitHub`
3. 点击 **"添加新的"** 连接 GitHub
4. 在弹出窗口中：
   - **连接名称**: `my-github-connection`
   - 点击 **"连接到 GitHub"**
   - 在 GitHub 授权页面，点击 **"Authorize AWS Connector for GitHub"**
   - 如果提示选择仓库，选择 **"All repositories"** 或只选择 `my-fullstack-app`
   - 点击 **"Install"**
5. 返回 AWS 控制台，等待连接状态变为"可用"

#### 存储库
1. **存储库**: 选择 `你的用户名/my-fullstack-app`
2. **分支**: `main`
3. **源目录**: `/backend-b` **⚠️ 重要！必须填写**

#### 部署设置
1. **部署触发器**: `自动`（代码推送时自动部署）
2. 点击 **"下一步"**

### 2.3 配置构建

#### 配置设置
1. 选择 **`手动配置`**

#### 运行时设置
1. **运行时**: `Nodejs 20`
2. **构建命令**: 
   ```
   npm install
   ```
3. **启动命令**: 
   ```
   node server.js
   ```
4. **端口**: `4000`

5. 点击 **"下一步"**

### 2.4 配置服务

#### 服务设置
1. **服务名称**: `todoapp-backend-b`

#### 环境变量
点击 **"添加环境变量"**，逐个添加以下变量：

| 键 | 值 | 说明 |
|---|---|---|
| `PORT_B` | `4000` | 后端B端口 |
| `POSTGRES_HOST` | `todoapp-db.c9akxxxxxx.us-east-1.rds.amazonaws.com` | 您的 RDS 端点 |
| `POSTGRES_PORT` | `5432` | PostgreSQL 端口 |
| `POSTGRES_DB` | `todoapp` | 数据库名称 |
| `POSTGRES_USER` | `todouser` | 数据库用户名 |
| `POSTGRES_PASSWORD` | `您的数据库密码` | 数据库密码 |

**⚠️ 重要**：确保 `POSTGRES_HOST` 使用您在步骤1.4获取的实际端点地址

#### 实例配置
1. **vCPU**: `1 vCPU`
2. **内存**: `2 GB`

#### 自动扩展
1. **最大并发**: `100`
2. **最小实例**: `1`
3. **最大实例**: `2`

#### 运行状况检查
1. **协议**: `HTTP`
2. **路径**: `/api/messages`
3. **间隔**: `10 秒`
4. **超时**: `5 秒`
5. **不正常阈值**: `3`
6. **正常阈值**: `1`

#### 安全性
1. **实例角色**: `创建新的服务角色`

7. 点击 **"下一步"**

### 2.5 审核并创建

1. 检查所有配置是否正确
2. 滚动到底部，点击 **"创建并部署"**
3. **等待 5-10 分钟**，状态变为"正在运行"
4. 可以点击 **"日志"** 标签查看部署进度

### 2.6 获取服务 URL

1. 部署完成后，在服务详情页面找到 **"默认域"**
2. 格式类似：`https://abc123xyz.us-east-1.awsapprunner.com`
3. **⚠️ 保存这个 URL！**（后端A 需要用到）

### 2.7 测试后端B

```powershell
# 测试获取消息（应该返回空数组）
curl https://abc123xyz.us-east-1.awsapprunner.com/api/messages

# 应该返回: []

# 测试添加消息
curl -X POST https://abc123xyz.us-east-1.awsapprunner.com/api/messages `
  -H "Content-Type: application/json" `
  -d '{\"author\":\"测试\",\"text\":\"测试消息\"}'

# 应该返回新创建的消息对象
```

---

## 🚀 步骤3: 部署后端A（智能分类服务）

### 3.1 创建新的 App Runner 服务

1. 返回 App Runner 控制台：https://console.aws.amazon.com/apprunner/
2. 点击 **"创建服务"**

### 3.2 配置源

#### 源
1. **存储库类型**: `源代码存储库`
2. **提供商**: `GitHub`
3. **连接**: 选择之前创建的 `my-github-connection`
4. **存储库**: `你的用户名/my-fullstack-app`
5. **分支**: `main`
6. **源目录**: `/backend-a` **⚠️ 重要！**

#### 部署设置
1. **部署触发器**: `自动`
2. 点击 **"下一步"**

### 3.3 配置构建

1. 选择 **`手动配置`**
2. **运行时**: `Nodejs 20`
3. **构建命令**: `npm install`
4. **启动命令**: `node server.js`
5. **端口**: `3000`
6. 点击 **"下一步"**

### 3.4 配置服务

#### 服务设置
1. **服务名称**: `todoapp-backend-a`

#### 环境变量

| 键 | 值 |
|---|---|
| `PORT` | `3000` |
| `BACKEND_B_URL` | `https://abc123xyz.us-east-1.awsapprunner.com` |

**⚠️ 重要**：`BACKEND_B_URL` 使用步骤2.6获取的后端B URL

#### 实例配置
1. **vCPU**: `1 vCPU`
2. **内存**: `2 GB`

#### 自动扩展
1. **最大并发**: `100`
2. **最小实例**: `1`
3. **最大实例**: `2`

#### 运行状况检查
1. **协议**: `HTTP`
2. **路径**: `/api/messages`
3. **间隔**: `10 秒`

7. 点击 **"下一步"** → **"创建并部署"**

### 3.5 获取服务 URL

1. 部署完成后，复制 **"默认域"**
2. 格式类似：`https://def456uvw.us-east-1.awsapprunner.com`
3. **⚠️ 保存这个 URL！**（前端需要用到）

### 3.6 测试后端A

```powershell
# 测试智能分类
curl -X POST https://def456uvw.us-east-1.awsapprunner.com/api/messages `
  -H "Content-Type: application/json" `
  -d '{\"author\":\"测试\",\"text\":\"紧急工作会议\"}'

# 应该返回带有分类信息的任务
# category: "work", priority: "high"
```

---

## 🎨 步骤4: 部署前端

### 4.1 修改前端配置

在部署前端之前，需要更新 API 地址。

#### 编辑 frontend/src/App.jsx

找到 API URL 配置部分（通常在文件开头），修改为：

```javascript
// 修改前
const API_URL = 'http://localhost:3000';

// 修改后
const API_URL = import.meta.env.VITE_API_URL || 'https://def456uvw.us-east-1.awsapprunner.com';
```

**⚠️ 重要**：将 `https://def456uvw.us-east-1.awsapprunner.com` 替换为您在步骤3.5获取的后端A URL

#### 提交并推送更改

```powershell
cd c:\Users\95150\OneDrive\桌面\my-fullstack-app

# 添加修改
git add frontend/src/App.jsx

# 提交
git commit -m "Update API URL for production"

# 推送到 GitHub
git push
```

### 4.2 创建前端 App Runner 服务

1. 返回 App Runner 控制台
2. 点击 **"创建服务"**

### 4.3 配置源

1. **存储库**: `你的用户名/my-fullstack-app`
2. **分支**: `main`
3. **源目录**: `/frontend` **⚠️ 重要！**
4. **部署触发器**: `自动`
5. 点击 **"下一步"**

### 4.4 配置构建

1. 选择 **`手动配置`**
2. **运行时**: `Nodejs 20`
3. **构建命令**: 
   ```
   npm install && npm run build
   ```
4. **启动命令**: 
   ```
   npm run preview -- --host 0.0.0.0 --port 5173
   ```
5. **端口**: `5173`
6. 点击 **"下一步"**

### 4.5 配置服务

#### 服务设置
1. **服务名称**: `todoapp-frontend`

#### 环境变量

| 键 | 值 |
|---|---|
| `VITE_API_URL` | `https://def456uvw.us-east-1.awsapprunner.com` |

**⚠️ 重要**：使用您的后端A URL

#### 实例配置
1. **vCPU**: `1 vCPU`
2. **内存**: `2 GB`

3. 点击 **"下一步"** → **"创建并部署"**

### 4.6 获取应用 URL

1. 部署完成后，复制 **"默认域"**
2. 格式类似：`https://ghi789rst.us-east-1.awsapprunner.com`
3. **🎉 这就是您的应用访问地址！**

### 4.7 访问应用

1. 在浏览器中打开：`https://ghi789rst.us-east-1.awsapprunner.com`
2. 您应该看到您的智能待办清单应用！
3. 尝试添加任务，测试智能分类功能

---

## 🔍 步骤5: 配置本地数据库观察

### 5.1 在 DBeaver 中连接 RDS

1. 打开 DBeaver
2. 点击 **"新建连接"** → 选择 **`PostgreSQL`**
3. 填写连接信息：
   - **Host**: `todoapp-db.c9akxxxxxx.us-east-1.rds.amazonaws.com`
   - **Port**: `5432`
   - **Database**: `todoapp`
   - **Username**: `todouser`
   - **Password**: 您的数据库密码
   - 勾选 **"保存密码"**
4. 点击 **"测试连接"**
5. 连接成功后，点击 **"完成"**

### 5.2 查看实时数据

1. 展开连接 → `Schemas` → `public` → `Tables`
2. 双击 `todos` 表查看数据
3. 在应用中添加任务
4. 在 DBeaver 中点击刷新按钮（或按 F5）
5. 您应该看到新添加的任务数据

### 5.3 使用 SQL 查询数据

```sql
-- 查看所有任务
SELECT * FROM todos ORDER BY "createdAt" DESC;

-- 按类别统计
SELECT category, COUNT(*) as count 
FROM todos 
GROUP BY category;

-- 按优先级统计
SELECT priority, COUNT(*) as count 
FROM todos 
GROUP BY priority;

-- 查看最近添加的10条任务
SELECT id, author, text, category, priority, "createdAt"
FROM todos 
ORDER BY "createdAt" DESC 
LIMIT 10;
```

---

## ✅ 部署完成检查清单

- [ ] RDS PostgreSQL 数据库创建成功，状态为"可用"
- [ ] 安全组配置正确，允许 0.0.0.0/0 访问端口 5432
- [ ] 后端B 部署成功，可以访问 `/api/messages`
- [ ] 后端A 部署成功，可以调用后端B
- [ ] 前端部署成功，可以访问应用
- [ ] 本地 DBeaver 可以连接到 RDS 数据库
- [ ] 在应用中添加任务，数据正确保存到数据库
- [ ] 智能分类功能正常工作
- [ ] 可以在 DBeaver 中看到实时数据变化

---

## 📝 重要信息汇总

请将以下信息保存到安全的地方：

```
=== AWS 账号信息 ===
AWS 账号 ID: ____________
Access Key ID: AKIA____________
Secret Access Key: ____________

=== RDS 数据库信息 ===
端点: todoapp-db.____________.us-east-1.rds.amazonaws.com
端口: 5432
数据库名: todoapp
用户名: todouser
密码: ____________

=== App Runner 服务 URL ===
后端B: https://____________.us-east-1.awsapprunner.com
后端A: https://____________.us-east-1.awsapprunner.com
前端: https://____________.us-east-1.awsapprunner.com

=== 应用访问地址 ===
https://____________.us-east-1.awsapprunner.com
```

---

## 🔧 常见问题

### Q1: 部署失败，显示"构建错误"

**解决方案**：
1. 检查 GitHub 仓库中的代码是否完整
2. 确保 `package.json` 文件存在
3. 查看 App Runner 日志，找到具体错误信息
4. 确保源目录路径正确（`/backend-a`, `/backend-b`, `/frontend`）

### Q2: 后端B 无法连接数据库

**解决方案**：
1. 检查 RDS 安全组入站规则
2. 确保 `POSTGRES_HOST` 环境变量正确
3. 确保数据库状态为"可用"
4. 检查数据库密码是否正确

### Q3: 前端无法调用后端A

**解决方案**：
1. 检查 `VITE_API_URL` 环境变量是否正确
2. 检查后端A 是否正常运行
3. 检查浏览器控制台是否有 CORS 错误
4. 确保后端A 的 CORS 配置允许前端域名

### Q4: 本地无法连接 RDS 数据库

**解决方案**：
1. 检查 RDS 安全组入站规则是否包含 `0.0.0.0/0`
2. 确保 RDS 的"公开访问"设置为"是"
3. 检查本地防火墙是否阻止了端口 5432
4. 尝试使用 `telnet` 测试连接：
   ```powershell
   telnet todoapp-db.xxx.us-east-1.rds.amazonaws.com 5432
   ```

### Q5: 成本比预期高

**解决方案**：
1. 检查是否有多余的服务在运行
2. 将最小实例数设置为 1
3. 考虑使用 RDS 免费套餐
4. 监控 CloudWatch 指标，优化资源使用

---

## 🎉 恭喜！

您已经成功将应用部署到 AWS！

**下一步**：
- 分享您的应用 URL 给朋友
- 监控应用性能和成本
- 考虑添加自定义域名
- 配置 CloudWatch 告警

**需要帮助？**
- AWS 文档：https://docs.aws.amazon.com/apprunner/
- AWS 支持：https://console.aws.amazon.com/support/
