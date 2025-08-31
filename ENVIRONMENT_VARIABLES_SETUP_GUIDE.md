# 环境变量配置指南

本指南将帮助您配置项目所需的环境变量，特别是 `CODECOV_TOKEN` 和 `SENTRY_DSN`。

## 1. 配置 CODECOV_TOKEN

### 1.1 访问 Codecov 网站
1. 打开浏览器，访问 [https://codecov.io](https://codecov.io)
2. 点击右上角的 "Log in" 按钮
3. 选择 "Sign in with GitHub" 使用您的 GitHub 账号登录

### 1.2 添加项目到 Codecov
1. 登录成功后，点击左侧菜单的 "Repositories"
2. 如果您的 `wanli-backend` 项目没有显示，点击 "Add new repository"
3. 在搜索框中输入 `wanli-backend` 或找到对应的仓库
4. 点击仓库名称进入项目页面

### 1.3 获取项目 Token
1. 在项目页面中，点击 "Settings" 标签
2. 在左侧菜单中选择 "General"
3. 找到 "Repository Upload Token" 部分
4. 复制显示的 token（格式类似：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`）

### 1.4 配置环境变量
1. 打开项目根目录下的 `.env` 文件
2. 找到 `CODECOV_TOKEN=your-codecov-token-here` 这一行
3. 将 `your-codecov-token-here` 替换为您刚才复制的 token
4. 保存文件

### 1.5 验证配置
运行以下命令验证 token 是否有效：
```bash
./codecov --dry-run
```

## 2. 配置 SENTRY_DSN

### 2.1 访问 Sentry 网站
1. 打开浏览器，访问 [https://sentry.io](https://sentry.io)
2. 如果没有账号，点击 "Get started" 注册新账号
3. 如果已有账号，点击 "Sign In" 登录

### 2.2 创建新项目
1. 登录后，点击右上角的 "Create Project" 按钮
2. 选择平台为 "Java" 或 "Spring Boot"
3. 输入项目名称：`wanli-backend`
4. 选择合适的团队（如果有多个团队）
5. 点击 "Create Project" 按钮

### 2.3 获取 DSN
1. 项目创建成功后，您会看到一个配置页面
2. 在 "Configure SDK" 部分，找到 DSN 配置
3. 复制 DSN 值（格式类似：`https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxxxx.ingest.sentry.io/xxxxxxx`）

### 2.4 配置环境变量
1. 打开项目根目录下的 `.env` 文件
2. 找到 `SENTRY_DSN=your-sentry-dsn-here` 这一行
3. 将 `your-sentry-dsn-here` 替换为您刚才复制的 DSN
4. 保存文件

### 2.5 验证配置
运行以下命令验证 DSN 是否有效：
```bash
sentry-cli info
```

## 3. 环境变量加载验证

### 3.1 检查环境变量
运行以下命令检查环境变量是否正确加载：
```bash
# 检查 Codecov token
echo $CODECOV_TOKEN

# 检查 Sentry DSN
echo $SENTRY_DSN
```

### 3.2 重启应用
配置完成后，重启您的 Spring Boot 应用以加载新的环境变量：
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

## 4. 常见问题

### 4.1 Codecov Token 无效
- 确保 token 完整复制，没有多余的空格
- 检查 GitHub 仓库是否为公开仓库或您有相应权限
- 确认 token 没有过期

### 4.2 Sentry DSN 无效
- 确保 DSN 格式正确，包含完整的 URL
- 检查 Sentry 项目是否创建成功
- 确认您有项目的访问权限

### 4.3 环境变量未生效
- 确保 `.env` 文件在项目根目录
- 检查文件编码是否为 UTF-8
- 重启终端或 IDE 后再次尝试

## 5. 安全注意事项

⚠️ **重要提醒**：
- 不要将包含真实 token 和 DSN 的 `.env` 文件提交到版本控制系统
- 确保 `.env` 文件已添加到 `.gitignore` 中
- 定期更换 token 和 DSN 以确保安全

---

配置完成后，您的项目将能够：
- 自动上传代码覆盖率报告到 Codecov
- 自动收集和报告错误信息到 Sentry
- 提供更好的代码质量监控和错误追踪能力