# 🤖 智能待办清单 - 双后端协作系统

一个基于 React + Express + PostgreSQL 的全栈应用，实现了双后端协作架构和智能任务分类功能，支持 Docker 一键部署。

---

## 📖 项目演进历程

### 阶段 1：基础项目（原始版本）
- ✅ 简单的待办清单应用
- ✅ 前端：React + Vite
- ✅ 后端：Express + SQLite
- ✅ 基础的增删查改功能

### 阶段 2：数据库升级
- ✅ 从 SQLite 迁移到 PostgreSQL
- ✅ 使用关系型数据库实现数据持久化
- ✅ 添加 pg 驱动

### 阶段 3：双后端协作架构 ⭐ **（核心创新）**
- ✅ 拆分为后端A（智能分类）和后端B（数据存储）
- ✅ 实现微服务架构思想
- ✅ 职责分离，易于扩展

### 阶段 4：智能分类功能 🤖
- ✅ AI 自动识别任务类型（工作/学习/生活/其他）
- ✅ AI 自动识别优先级（高/中/低）
- ✅ AI 自动提取截止日期（今天/明天/下周）

### 阶段 5：前端优化 🎨
- ✅ 渐变背景设计
- ✅ 卡片式布局
- ✅ 实时统计分析
- ✅ 可视化展示

### 阶段 6：容器化部署 🐳 **（最新升级）**
- ✅ Docker 容器化所有服务
- ✅ Docker Compose 一键启动
- ✅ PostgreSQL 容器化部署
- ✅ 环境隔离和版本管理

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────┐
│                    前端 (React)                      │
│              http://localhost:5173                   │
│              Docker Container: todoapp-frontend      │
│                                                       │
│  功能：                                               │
│  • 用户界面                                           │
│  • 任务输入和展示                                     │
│  • 统计数据可视化                                     │
└──────────────────────┬──────────────────────────────┘
                       │
                       ↓ HTTP 请求
┌─────────────────────────────────────────────────────┐
│            后端A - 智能分类服务 (Express)             │
│              http://localhost:3000                   │
│              Docker Container: todoapp-backend-a     │
│                                                       │
│  功能：                                               │
│  • 接收前端请求                                       │
│  • 智能分析任务内容（关键词匹配）                     │
│  • 识别类型、优先级、截止日期                         │
│  • 添加统计信息                                       │
│  • 转发数据到后端B                                    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ↓ HTTP 请求
┌─────────────────────────────────────────────────────┐
│            后端B - 数据存储服务 (Express)             │
│              http://localhost:4000                   │
│              Docker Container: todoapp-backend-b     │
│                                                       │
│  功能：                                               │
│  • 连接 PostgreSQL 数据库                             │
│  • 执行 CRUD 操作                                     │
│  • 数据持久化                                         │
│  • 返回结果给后端A                                    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ↓
              ┌────────────────┐
              │   PostgreSQL    │
              │  Docker Container│
              │ todoapp-postgres│
              └────────────────┘
```

---

## ✨ 核心功能

### 1. 智能任务分类 🤖

**自动识别任务类型：**
- 💼 **工作**：识别"工作"、"会议"、"项目"、"开发"等关键词
- 📚 **学习**：识别"学习"、"读书"、"课程"、"作业"等关键词
- 🏠 **生活**：识别"买"、"吃"、"运动"、"健身"等关键词
- 📝 **其他**：未匹配的任务

**自动识别优先级：**
- 🔴 **高优先级**：识别"紧急"、"重要"、"马上"、"立刻"等关键词
- 🔵 **普通优先级**：默认优先级
- 🟢 **低优先级**：识别"有空"、"可以"、"随便"等关键词

**自动提取截止日期：**
- ⏰ 识别"今天"、"明天"、"下周"等时间关键词
- 📅 自动设置对应的截止日期

### 2. 实时统计分析 📊

- 按类别统计（工作/学习/生活/其他）
- 按优先级统计（高/中/低）
- 可视化展示

### 3. 双后端协作 🔄

- 后端A负责智能分析和业务逻辑
- 后端B负责数据存储和数据库操作
- 清晰的职责分离，易于维护和扩展

---

## 🚀 快速开始

### 方式一：Docker 部署（推荐）⭐

#### 前置要求
- Docker Desktop
- Git

#### 启动步骤

1. **克隆项目**
```bash
git clone https://github.com/jinchengw888/my-fullstack-app.git
cd my-fullstack-app
```

2. **配置环境变量**

复制 `.env.example` 为 `.env`（PostgreSQL 配置已在 docker-compose.yml 中定义）：
```bash
cp .env.example .env
```

3. **一键启动所有服务**
```bash
docker-compose up --build
```

4. **访问应用**
- 前端：http://localhost:5173
- 后端A：http://localhost:3000
- 后端B：http://localhost:4000
- PostgreSQL：localhost:5432

5. **停止服务**
```bash
docker-compose down
```

---

### 方式二：本地开发部署

#### 前置要求
- Node.js 20+
- PostgreSQL 15+
- Git

#### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/jinchengw888/my-fullstack-app.git
cd my-fullstack-app
```

2. **创建 PostgreSQL 数据库**
```bash
psql -U postgres
CREATE DATABASE todoapp;
\q
```

3. **安装依赖**
```bash
# 安装根目录依赖
npm install

# 安装后端A依赖
cd backend-a
npm install
cd ..

# 安装后端B依赖
cd backend-b
npm install
cd ..

# 安装前端依赖
cd frontend
npm install
cd ..
```

4. **配置环境变量**

复制 `.env.example` 为 `.env`：
```bash
cp .env.example .env
```

编辑 `.env` 文件，填入你的 PostgreSQL 配置：
```env
BACKEND_B_URL=http://localhost:4000

POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=todoapp
POSTGRES_USER=postgres
POSTGRES_PASSWORD=你的密码

PORT=3000
PORT_B=4000
```

5. **启动项目**
```bash
npm start
```

6. **访问应用**
- 前端：http://localhost:5173
- 后端A：http://localhost:3000
- 后端B：http://localhost:4000

---

## 🧪 测试示例

尝试输入以下任务，查看智能分类效果：

| 输入 | 预期结果 |
|------|---------|
| `紧急工作会议` | 💼 工作 + 🔴 高优先级 |
| `明天买菜` | 🏠 生活 + ⏰ 明天截止 |
| `学习React课程` | 📚 学习 + 🔵 普通优先级 |
| `有空读书` | 📝 其他 + 🟢 低优先级 |
| `开发新功能模块` | 💼 工作 + 🔵 普通优先级 |

---

## 📁 项目结构

```
my-fullstack-app/
├── frontend/                 # 前端应用
│   ├── src/
│   │   └── App.jsx          # 主组件（包含统计和可视化）
│   ├── Dockerfile           # 前端 Docker 配置
│   ├── package.json
│   └── vite.config.js
│
├── backend-a/               # 后端A - 智能分类服务
│   ├── server.js           # 主服务器（智能分析逻辑）
│   ├── Dockerfile          # 后端A Docker 配置
│   └── package.json
│
├── backend-b/               # 后端B - 数据存储服务
│   ├── server.js           # 主服务器
│   ├── db.js               # PostgreSQL 连接
│   ├── routes/
│   │   └── messages.js     # API 路由
│   ├── Dockerfile          # 后端B Docker 配置
│   └── package.json
│
├── docker-compose.yml      # Docker Compose 配置
├── .dockerignore          # Docker 忽略文件
├── package.json            # 根配置（启动脚本）
├── .env.example           # 环境变量示例
├── .gitignore
└── README.md
```

---

## 🔧 技术栈

### 前端
- **React** - UI 框架
- **Vite** - 构建工具
- **Axios** - HTTP 客户端

### 后端A（智能分类）
- **Express** - Web 框架
- **Axios** - HTTP 客户端（调用后端B）
- **自然语言处理** - 关键词匹配算法

### 后端B（数据存储）
- **Express** - Web 框架
- **pg** - PostgreSQL 驱动
- **PostgreSQL** - 关系型数据库

### 容器化
- **Docker** - 容器化平台
- **Docker Compose** - 多容器编排
- **Node.js 20 Alpine** - 轻量级基础镜像
- **PostgreSQL 15 Alpine** - 数据库镜像

---

## 📊 数据流程

### 添加任务流程

```
1. 用户在前端输入："紧急工作会议"
   ↓
2. 前端发送 POST 请求到后端A (localhost:3000)
   ↓
3. 后端A智能分析：
   - 检测到"紧急" → priority: "high"
   - 检测到"工作"、"会议" → category: "work"
   ↓
4. 后端A构建增强数据：
   {
     text: "紧急工作会议",
     category: "work",
     priority: "high",
     processedBy: "AI-Backend-A"
   }
   ↓
5. 后端A转发到后端B (localhost:4000)
   ↓
6. 后端B保存到 PostgreSQL
   ↓
7. 后端B返回结果给后端A
   ↓
8. 后端A返回给前端，显示：
   "✅ 任务已分类为【工作】，优先级【高优先级】"
```

---

## 🎯 核心创新点

### 1. 微服务架构思想
- 将单体后端拆分为两个独立服务
- 每个服务职责单一、易于维护
- 可独立扩展和部署

### 2. 智能分析能力
- 基于关键词的自然语言处理
- 自动分类和优先级识别
- 提升用户体验

### 3. 可视化展示
- 实时统计分析
- 颜色和图标标识
- 直观的数据展示

### 4. 容器化部署
- Docker 容器化所有服务
- 一键启动完整环境
- 环境隔离和版本控制

### 5. PostgreSQL 数据库
- 关系型数据库保证数据一致性
- Docker 卷持久化数据
- 易于备份和迁移

---

## 📝 技术亮点

### 后端A - 智能分析算法

```javascript
function analyzeTask(task) {
  const text = task.toLowerCase();
  
  // 分析类别
  let category = 'other';
  if (text.includes('工作') || text.includes('会议')) {
    category = 'work';
  } else if (text.includes('学习') || text.includes('读书')) {
    category = 'study';
  }
  
  // 分析优先级
  let priority = 'normal';
  if (text.includes('紧急') || text.includes('重要')) {
    priority = 'high';
  }
  
  // 提取截止日期
  let deadline = null;
  if (text.includes('今天')) {
    deadline = new Date();
  }
  
  return { category, priority, deadline };
}
```

### 数据模型设计

```sql
CREATE TABLE IF NOT EXISTS todos (
  id SERIAL PRIMARY KEY,
  author TEXT NOT NULL,
  text TEXT NOT NULL,
  category TEXT DEFAULT 'other',
  priority TEXT DEFAULT 'normal',
  deadline TIMESTAMP,
  tags TEXT,
  completed INTEGER DEFAULT 0,
  "processedBy" TEXT,
  "processedAt" TIMESTAMP,
  email TEXT,
  ip TEXT,
  ua TEXT,
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🚧 未来改进方向

- [ ] 接入真正的 AI 模型（如 GPT）提高分类准确率
- [ ] 添加用户认证系统
- [ ] 支持任务完成、编辑、删除功能
- [ ] 添加任务提醒功能
- [ ] 支持多语言
- [ ] 添加数据导出功能
- [ ] 实现任务搜索和过滤
- [ ] Kubernetes 部署支持
- [ ] CI/CD 自动化部署
- [ ] 监控和日志系统

---

## 📄 许可证

MIT License

---

## 👤 作者

jinchengw888 - [GitHub](https://github.com/jinchengw888)

---

## 🙏 致谢

感谢原项目作者提供的基础框架！
