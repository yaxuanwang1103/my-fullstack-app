# 🚀 AWS ECS 部署完全零基础指南

**适合人群**: 第一次使用 AWS 的新手  
**前置要求**: 无（从零开始）  
**完成时间**: 2-3 小时  

---

## 📖 目录

1. [第一部分：AWS 账户准备](#第一部分aws-账户准备)
2. [第二部分：IAM 用户设置](#第二部分iam-用户设置)
3. [第三部分：本地工具安装](#第三部分本地工具安装)
4. [第四部分：ECS 部署](#第四部分ecs-部署)

---

## 🎯 整体流程图

```
第一步: 注册 AWS 账户
    ↓
第二步: 创建 IAM 用户（不用 Root）
    ↓
第三步: 获取 Access Key
    ↓
第四步: 安装 AWS CLI 和 Docker
    ↓
第五步: 配置 AWS CLI
    ↓
第六步: 开始部署 ECS
```

---

# 第一部分：AWS 账户准备

## 步骤1.1：注册 AWS 账户

### 如果您还没有 AWS 账户：

1. **访问 AWS 官网**
   - 打开：https://aws.amazon.com/
   - 点击右上角 "创建 AWS 账户"

2. **填写账户信息**
   ```
   电子邮件地址: 您的邮箱
   密码: 设置一个强密码
   AWS 账户名称: 例如 "MyProject"
   ```

3. **选择账户类型**
   - 选择 "个人" 或 "专业"（个人项目选"个人"）

4. **填写联系信息**
   - 姓名、地址、电话等

5. **添加付款方式**
   - 需要信用卡或借记卡
   - ⚠️ 注意：即使使用免费套餐，也需要绑定卡
   - 💡 提示：不会立即扣费，只有超出免费额度才收费

6. **验证身份**
   - 通过电话或短信验证

7. **选择支持计划**
   - 选择 "基本支持 - 免费"

8. **完成注册**
   - 等待账户激活（通常几分钟）

### 如果您已有 AWS 账户：

✅ 跳过此步骤，继续下一步

---

## 步骤1.2：登录 AWS Console

1. **访问登录页面**
   - 打开：https://console.aws.amazon.com/

2. **选择登录方式**
   - 选择 "Root user"（根用户）
   - 输入您注册时的邮箱
   - 输入密码
   - 点击 "登录"

3. **验证登录成功**
   - 应该看到 AWS 管理控制台首页
   - 右上角显示您的账户名

---

# 第二部分：IAM 用户设置

## 为什么需要 IAM 用户？

```
Root 用户（您刚注册的账户）:
❌ 权限太大，不安全
❌ 如果泄露，后果严重
❌ AWS 不推荐日常使用

IAM 用户（我们要创建的）:
✅ 权限可控
✅ 更安全
✅ AWS 推荐使用
✅ 适合日常开发
```

---

## 步骤2.1：进入 IAM 控制台

1. **在 AWS Console 顶部搜索栏**
   - 输入 "IAM"
   - 点击 "IAM" 服务

2. **或直接访问**
   - https://console.aws.amazon.com/iam/

---

## 步骤2.2：创建 IAM 用户

### 1. 开始创建

- 在左侧菜单点击 **"Users"（用户）**
- 点击右上角蓝色按钮 **"Create user"（创建用户）**

### 2. 设置用户详情

```
User name（用户名）: ecs-deploy-user
（或您喜欢的名字，如：admin-user, dev-user）
```

- 点击 **"Next"（下一步）**

### 3. 设置权限

**重要：这里决定了用户能做什么**

#### 选项A：管理员权限（推荐新手）

```
优点: 可以做所有事情，不会遇到权限问题
缺点: 权限较大
适合: 学习、开发、个人项目
```

操作步骤：
1. 选择 **"Attach policies directly"（直接附加策略）**
2. 在搜索框输入 **"AdministratorAccess"**
3. 勾选 **"AdministratorAccess"**
4. 点击 **"Next"**

#### 选项B：ECS 专用权限（推荐生产环境）

```
优点: 只有必需权限，更安全
缺点: 需要选择多个策略
适合: 生产环境、团队项目
```

操作步骤：
1. 选择 **"Attach policies directly"**
2. 搜索并勾选以下策略：
   - ☑ `AmazonECS_FullAccess`
   - ☑ `AmazonEC2ContainerRegistryFullAccess`
   - ☑ `AmazonRDSFullAccess`
   - ☑ `AmazonVPCFullAccess`
   - ☑ `IAMFullAccess`
   - ☑ `CloudWatchLogsFullAccess`
   - ☑ `AmazonEC2FullAccess`
3. 点击 **"Next"**

**💡 新手建议：选择选项A（AdministratorAccess）**

### 4. 审查并创建

- 检查用户名和权限
- 点击 **"Create user"（创建用户）**
- ✅ 用户创建成功！

---

## 步骤2.3：为 IAM 用户创建 Access Key

### 什么是 Access Key？

```
Access Key = 让您的本地电脑能访问 AWS 的"钥匙"

包含两部分:
1. Access Key ID（公开的，类似用户名）
2. Secret Access Key（私密的，类似密码）
```

### 创建步骤：

1. **进入用户详情**
   - 在用户列表中，点击刚创建的用户名（如 `ecs-deploy-user`）

2. **进入安全凭证**
   - 点击 **"Security credentials"（安全凭证）** 标签

3. **创建 Access Key**
   - 向下滚动到 **"Access keys"** 部分
   - 点击 **"Create access key"（创建访问密钥）**

4. **选择用例**
   - 选择 **"Command Line Interface (CLI)"**
   - 勾选底部的确认框：**"I understand..."**
   - 点击 **"Next"**

5. **设置描述（可选）**
   ```
   Description tag: Local development CLI
   ```
   - 点击 **"Create access key"**

6. **保存密钥** ⚠️ **非常重要！**

   您会看到：
   ```
   Access key ID: AKIAIOSFODNN7EXAMPLE
   Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

   **保存方式（选一种）：**

   **方式1：下载 CSV 文件**
   - 点击 **"Download .csv file"**
   - 保存到安全位置（如：`C:\Users\您的用户名\Documents\aws-keys.csv`）

   **方式2：手动复制**
   - 复制 Access key ID 到记事本
   - 点击 **"Show"** 显示 Secret access key
   - 复制 Secret access key 到记事本
   - 保存记事本文件

   **⚠️ 警告：Secret access key 只显示这一次！**
   - 如果丢失，需要删除并重新创建

7. **完成**
   - 点击 **"Done"**

---

## 步骤2.4：记录您的密钥

**请将以下信息填写并保存：**

```
AWS 账户 ID: ____________（12位数字，在右上角用户名下拉菜单中）
IAM 用户名: ecs-deploy-user（或您设置的名字）
Access Key ID: AKIA____________________
Secret Access Key: ________________________________________
区域: us-east-1（推荐）
```

**保存位置建议：**
- 密码管理器（如 1Password、LastPass）
- 加密的本地文件
- ❌ 不要：发送到邮箱、保存到云笔记、提交到 Git

---

# 第三部分：本地工具安装

## 步骤3.1：安装 AWS CLI

### Windows 安装步骤：

1. **下载安装程序**
   - 访问：https://awscli.amazonaws.com/AWSCLIV2.msi
   - 或在浏览器中打开上面的链接，会自动下载

2. **运行安装程序**
   - 双击下载的 `AWSCLIV2.msi` 文件
   - 点击 "Next"（下一步）
   - 接受许可协议
   - 选择安装位置（默认即可）
   - 点击 "Install"（安装）
   - 等待安装完成
   - 点击 "Finish"（完成）

3. **重启 PowerShell**
   - ⚠️ **重要**：必须关闭并重新打开 PowerShell
   - 否则无法识别 `aws` 命令

4. **验证安装**
   ```powershell
   # 打开新的 PowerShell 窗口
   # 运行以下命令
   aws --version
   ```

   **应该显示**：
   ```
   aws-cli/2.x.x Python/3.x.x Windows/10 exe/AMD64
   ```

   **如果显示错误**：
   - 确认已重启 PowerShell
   - 检查环境变量（参考故障排查部分）

---

## 步骤3.2：配置 AWS CLI

### 配置您的 IAM 用户凭证：

1. **运行配置命令**
   ```powershell
   aws configure
   ```

2. **按提示输入信息**

   ```
   AWS Access Key ID [None]: 
   ```
   → 输入您在步骤2.3中保存的 Access Key ID
   → 按 Enter

   ```
   AWS Secret Access Key [None]: 
   ```
   → 输入您在步骤2.3中保存的 Secret Access Key
   → 按 Enter

   ```
   Default region name [None]: 
   ```
   → 输入 `us-east-1`
   → 按 Enter

   ```
   Default output format [None]: 
   ```
   → 输入 `json`
   → 按 Enter

3. **验证配置**
   ```powershell
   # 查看配置
   aws configure list
   ```

   **应该显示**：
   ```
         Name                    Value             Type    Location
         ----                    -----             ----    --------
      profile                <not set>             None    None
   access_key     ****************XXXX shared-credentials-file
   secret_key     ****************XXXX shared-credentials-file
       region                us-east-1      config-file    ~/.aws/config
   ```

4. **测试连接**
   ```powershell
   aws sts get-caller-identity
   ```

   **应该显示**：
   ```json
   {
       "UserId": "AIDXXXXXXXXXXXXXXXXXX",
       "Account": "123456789012",
       "Arn": "arn:aws:iam::123456789012:user/ecs-deploy-user"
   }
   ```

   **✅ 如果看到上面的输出，说明配置成功！**

   **❌ 如果报错**：
   - 检查 Access Key 是否正确
   - 检查网络连接
   - 参考故障排查部分

---

## 步骤3.3：安装 Docker Desktop

### 为什么需要 Docker？

```
Docker 用于:
1. 构建应用的 Docker 镜像
2. 推送镜像到 AWS ECR
3. 本地测试容器
```

### 安装步骤：

1. **下载 Docker Desktop**
   - 访问：https://www.docker.com/products/docker-desktop
   - 点击 "Download for Windows"
   - 下载 `Docker Desktop Installer.exe`

2. **运行安装程序**
   - 双击下载的安装文件
   - 勾选 "Use WSL 2 instead of Hyper-V"（如果有选项）
   - 点击 "Ok"
   - 等待安装完成
   - 点击 "Close and restart"

3. **启动 Docker Desktop**
   - 安装完成后会自动启动
   - 或从开始菜单启动 "Docker Desktop"
   - 等待 Docker 引擎启动（右下角图标变绿）

4. **验证安装**
   ```powershell
   # 打开 PowerShell
   docker --version
   docker-compose --version
   ```

   **应该显示**：
   ```
   Docker version 24.x.x, build xxxxx
   Docker Compose version v2.x.x
   ```

5. **测试 Docker**
   ```powershell
   docker run hello-world
   ```

   **应该显示**：
   ```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ```

---

## 步骤3.4：验证所有工具

### 运行完整检查：

```powershell
# 1. 检查 AWS CLI
aws --version

# 2. 检查 AWS 配置
aws configure list

# 3. 检查 AWS 连接
aws sts get-caller-identity

# 4. 检查 Docker
docker --version

# 5. 检查 Docker 运行状态
docker ps
```

**✅ 如果所有命令都成功，您已准备好部署 ECS！**

---

# 第四部分：ECS 部署

## 🎉 恭喜！您已完成所有准备工作

现在您可以开始按照 `AWS部署-方案2-ECS.md` 文档进行部署了。

### 从哪里开始？

打开 `AWS部署-方案2-ECS.md` 文档，**跳过前置准备部分**，直接从以下步骤开始：

```
✅ 已完成: 安装 AWS CLI
✅ 已完成: 配置 AWS CLI
✅ 已完成: 安装 Docker

→ 开始: 步骤1 - 创建 RDS PostgreSQL 数据库
```

---

## 📋 部署检查清单

在开始部署前，确认：

- [ ] AWS 账户已注册并激活
- [ ] IAM 用户已创建（`ecs-deploy-user`）
- [ ] IAM 用户有管理员权限（或 ECS 相关权限）
- [ ] Access Key 已创建并保存
- [ ] AWS CLI 已安装（`aws --version` 成功）
- [ ] AWS CLI 已配置（`aws sts get-caller-identity` 成功）
- [ ] Docker Desktop 已安装并运行
- [ ] 项目代码已准备好（在 `my-fullstack-app` 目录）

**✅ 全部勾选后，开始部署！**

---

## 🔍 故障排查

### 问题1：aws 命令无法识别

**症状**：
```
aws : The term 'aws' is not recognized...
```

**解决方案**：
1. 确认已安装 AWS CLI
2. 重启 PowerShell
3. 检查环境变量：
   - 按 `Win + R`，输入 `sysdm.cpl`
   - 点击 "高级" → "环境变量"
   - 在 "系统变量" 的 `Path` 中应该有：
     `C:\Program Files\Amazon\AWSCLIV2\`
4. 如果没有，手动添加

### 问题2：Access Key 配置错误

**症状**：
```
An error occurred (InvalidClientTokenId) when calling...
```

**解决方案**：
1. 重新运行 `aws configure`
2. 仔细检查 Access Key ID 和 Secret Access Key
3. 确保没有多余的空格
4. 确认使用的是 IAM 用户的密钥，不是 Root 用户的

### 问题3：权限不足

**症状**：
```
An error occurred (AccessDenied) when calling...
```

**解决方案**：
1. 检查 IAM 用户是否有足够权限
2. 在 IAM 控制台检查用户的策略
3. 确认附加了 `AdministratorAccess` 或相关策略

### 问题4：Docker 无法启动

**症状**：
```
error during connect: This error may indicate that the docker daemon is not running
```

**解决方案**：
1. 启动 Docker Desktop
2. 等待 Docker 引擎完全启动（右下角图标变绿）
3. 运行 `docker ps` 测试

---

## 💡 重要提示

### 关于费用

```
免费套餐（12个月）:
✅ 750 小时/月 EC2 t2.micro
✅ 750 小时/月 RDS db.t2.micro
✅ 5GB S3 存储

ECS Fargate:
⚠️ 不在免费套餐内
💰 成本: 约 $60-90/月

建议:
- 学习完后及时删除资源
- 使用 AWS 成本管理工具监控费用
- 设置预算告警
```

### 关于安全

```
✅ 做:
- 使用 IAM 用户，不用 Root
- 启用 MFA（多因素认证）
- 定期轮换 Access Key
- 不要分享密钥

❌ 不要:
- 将密钥提交到 Git
- 在公开场合展示密钥
- 使用弱密码
- 长期不更换密钥
```

---

## 📚 相关文档

- **ECS 详细部署步骤**: `AWS部署-方案2-ECS.md`
- **三种方案对比**: `AWS部署-方案对比.md`
- **免费部署选项**: `免费部署方案.md`
- **AWS 入门指南**: `AWS完全入门指南.md`

---

## 🎯 下一步

1. **确认所有准备工作完成**（检查上面的清单）
2. **打开** `AWS部署-方案2-ECS.md`
3. **从步骤1开始部署**（跳过前置准备）
4. **遇到问题查看故障排查部分**

---

## ✅ 总结

### 您已完成：

1. ✅ 注册/登录 AWS 账户
2. ✅ 创建 IAM 用户（不用 Root）
3. ✅ 获取 Access Key
4. ✅ 安装并配置 AWS CLI
5. ✅ 安装 Docker Desktop
6. ✅ 验证所有工具正常工作

### 现在可以：

- 🚀 开始部署 ECS
- 📦 创建 Docker 镜像
- ☁️ 使用 AWS 服务
- 🎯 完成全栈应用部署

---

**祝您部署顺利！如有问题，请查看故障排查部分或参考其他文档。** 🎉
