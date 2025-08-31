<<<<<<< HEAD
# 万里后端管理系统

## 项目简介

万里后端管理系统是一个基于Spring Boot的企业级后端管理平台，提供完整的用户管理、权限控制、数据管理等功能。

## 技术栈

- **框架**: Spring Boot 3.2.0
- **数据库**: MySQL 8.0+
- **缓存**: Redis
- **构建工具**: Maven 3.6+
- **Java版本**: JDK 17+
- **ORM**: Spring Data JPA
- **安全**: Spring Security
- **文档**: Spring Doc OpenAPI

## 项目结构

```
wanli-backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── wanli/
│   │   │           ├── controller/     # 控制器层
│   │   │           ├── service/        # 服务层
│   │   │           ├── repository/     # 数据访问层
│   │   │           ├── entity/         # 实体类
│   │   │           ├── dto/            # 数据传输对象
│   │   │           ├── config/         # 配置类
│   │   │           ├── exception/      # 异常处理
│   │   │           └── util/           # 工具类
│   │   └── resources/
│   │       ├── application.yml         # 主配置文件
│   │       ├── application-dev.yml     # 开发环境配置
│   │       ├── application-staging.yml # 测试环境配置
│   │       └── application-prod.yml    # 生产环境配置
│   └── test/                          # 测试代码
├── doc/                               # 项目文档
├── pom.xml                           # Maven配置文件
└── README.md                         # 项目说明文档
```

## 环境要求

- JDK 17 或更高版本
- Maven 3.6 或更高版本
- MySQL 8.0 或更高版本
- Redis 6.0 或更高版本（生产环境）

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd wanli-backend
```

### 2. 配置数据库

创建MySQL数据库：

```sql
CREATE DATABASE wanli_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 修改配置

编辑 `src/main/resources/application-dev.yml` 文件，修改数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wanli_dev
    username: your_username
    password: your_password
```

### 4. 运行项目

```bash
# 使用Maven运行
mvn spring-boot:run

# 或者先编译再运行
mvn clean package
java -jar target/wanli-backend-1.0.0.jar
```

### 5. 访问应用

- 应用地址: http://localhost:8080/api
- 健康检查: http://localhost:8080/api/health
- API文档: http://localhost:8080/api/swagger-ui.html

## 环境配置

### 开发环境 (dev)

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 测试环境 (staging)

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=staging
```

### 生产环境 (prod)

```bash
java -jar wanli-backend-1.0.0.jar --spring.profiles.active=prod
```

## 构建部署

### 构建Docker镜像

```bash
# 构建JAR包
mvn clean package -DskipTests

# 构建Docker镜像
docker build -t wanli-backend:1.0.0 .
```

### 使用Docker Compose

```bash
docker-compose up -d
```

## 开发规范

### 代码规范

- 遵循阿里巴巴Java开发手册
- 使用统一的代码格式化配置
- 所有公共方法必须添加JavaDoc注释
- 单元测试覆盖率不低于80%

### Git工作流

- `main`: 生产环境分支
- `staging`: 测试环境分支  
- `dev`: 开发环境分支
- `feature/*`: 功能开发分支
- `fix/*`: 问题修复分支

### 提交规范

```
feat(scope): 添加新功能
fix(scope): 修复问题
docs(scope): 更新文档
style(scope): 代码格式调整
refactor(scope): 代码重构
test(scope): 添加测试
chore(scope): 构建过程或辅助工具的变动
```

## API文档

项目集成了OpenAPI 3.0，启动应用后可通过以下地址访问API文档：

- Swagger UI: http://localhost:8080/api/swagger-ui.html
- OpenAPI JSON: http://localhost:8080/api/v3/api-docs

## 监控和日志

### 应用监控

- 健康检查: `/actuator/health`
- 应用信息: `/actuator/info`
- 指标监控: `/actuator/metrics`

### 日志配置

- 开发环境：控制台输出，DEBUG级别
- 测试环境：文件输出，INFO级别
- 生产环境：文件输出，WARN级别，支持日志轮转

## 常见问题

### Q: 启动时提示数据库连接失败？
A: 请检查数据库服务是否启动，配置文件中的连接信息是否正确。

### Q: 如何切换不同的环境配置？
A: 通过 `--spring.profiles.active=环境名` 参数指定，或设置环境变量 `SPRING_PROFILES_ACTIVE`。

### Q: 如何添加新的API接口？
A: 在对应的Controller中添加方法，遵循RESTful设计规范。

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目维护者: wanli-team
- 邮箱: team@wanli.com
- 项目地址: https://github.com/JamesWuVip/wanli-backend

---

**注意**: 请在生产环境部署前仔细阅读部署文档，确保所有配置项都已正确设置。
=======
# Wanli Backend

万里后端服务项目

## 项目概述

这是一个基于Spring Boot的后端服务项目，集成了监控、测试覆盖率和错误追踪等功能。

## 技术栈

- Java 17
- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- MySQL
- Maven
- JaCoCo (代码覆盖率)
- Sentry (错误追踪)
- Codecov (覆盖率报告)

## 快速开始

### 环境要求

- Java 17+
- Maven 3.6+
- MySQL 8.0+

### 配置监控服务

运行监控服务配置脚本：

```bash
./setup-monitoring.sh
```

该脚本将自动配置：
- Codecov token
- Sentry DSN
- 生成测试覆盖率报告
- 验证服务连接

### 运行应用

```bash
# 开发环境
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 生产环境
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### 测试端点

应用启动后，可以访问以下测试端点：

- `GET /api/test/health` - 健康检查
- `GET /api/test/monitoring-info` - 监控配置信息
- `GET /api/test/sentry-error` - 测试Sentry错误报告
- `GET /api/test/sentry-message` - 测试Sentry消息报告

## 开发规范

### Git Flow

- `main` - 生产环境分支
- `staging` - 测试环境分支  
- `dev` - 开发分支
- `feature/*` - 功能分支
- `fix/*` - 修复分支

### 提交规范

使用 Conventional Commits 规范：

```
feat(scope): 添加新功能
fix(scope): 修复bug
docs(scope): 文档更新
style(scope): 代码格式调整
refactor(scope): 代码重构
test(scope): 测试相关
chore(scope): 构建过程或辅助工具的变动
```

## 监控和质量保证

### 代码覆盖率

使用 JaCoCo 生成覆盖率报告：

```bash
mvn clean test jacoco:report
```

### 错误追踪

集成 Sentry 进行实时错误监控和性能追踪。

### 持续集成

- 自动运行测试
- 生成覆盖率报告
- 上传到 Codecov
- Sentry 错误监控

## 许可证

MIT License
>>>>>>> 46918f4a44e598f44cfc9284915f96fdea41398d
