# 万里后端项目综合部署指导方案

## 目录
- [1. 项目概述](#1-项目概述)
- [2. 技术架构设计](#2-技术架构设计)
- [3. 免费云服务资源选择](#3-免费云服务资源选择)
- [4. 环境配置](#4-环境配置)
- [5. CI/CD流程配置](#5-cicd流程配置)
- [6. 数据模型和API定义](#6-数据模型和api定义)
- [7. 安全架构](#7-安全架构)
- [8. 性能优化](#8-性能优化)
- [9. 监控和维护](#9-监控和维护)
- [10. 部署步骤](#10-部署步骤)
- [11. 故障排除](#11-故障排除)
- [12. 成本优化建议](#12-成本优化建议)

## 1. 项目概述

### 1.1 技术栈
- **前端**: React 18 + TypeScript + Vite + TailwindCSS
- **后端框架**: Spring Boot 3.2.x + Java 17
- **数据库**: MySQL 8.0 (Railway托管) + Redis 7.x (缓存)
- **ORM**: Spring Data JPA + Hibernate 6.x
- **认证**: Spring Security 6.x + JWT
- **构建工具**: Maven 3.9.x
- **部署平台**: Railway (主要) + Docker容器
- **版本控制**: GitHub
- **CI/CD**: GitHub Actions
- **监控**: Sentry + UptimeRobot + Spring Boot Actuator
- **代码质量**: SonarCloud + Checkstyle + SpotBugs + PMD

### 1.2 分支管理策略和部署环境
- `main`: 生产环境分支 (部署到Railway)
- `staging`: 测试环境分支 (部署到Railway)
- `dev`: 开发环境分支 (本地运行)
- `feature/*`: 功能开发分支
- `hotfix/*`: 紧急修复分支

### 1.3 部署环境说明
- **开发环境 (dev)**: 本地运行，使用内嵌Tomcat服务器，连接本地MySQL和Redis
- **测试环境 (staging)**: 部署到Railway平台，使用Railway提供的MySQL和Redis服务
- **生产环境 (production)**: 部署到Railway平台，使用Railway提供的MySQL和Redis服务

## 2. 技术架构设计

### 2.1 整体架构图

```mermaid
graph TD
    A[用户浏览器] --> B[Cloudflare CDN]
    B --> C[Railway Load Balancer]
    C --> D[Spring Boot 应用]
    D --> E[MySQL 数据库]
    D --> F[Redis 缓存]
    D --> G[外部服务]
    
    subgraph "前端层"
        A
    end
    
    subgraph "CDN层"
        B
    end
    
    subgraph "应用层 (Railway)"
        C
        D
    end
    
    subgraph "数据层 (Railway)"
        E
        F
    end
    
    subgraph "外部服务层"
        G --> H[SendGrid 邮件]
        G --> I[Sentry 监控]
        G --> J[UptimeRobot 监控]
        G --> K[SonarCloud 代码质量]
    end
```

### 2.2 服务器架构图

```mermaid
graph TD
    A[客户端请求] --> B[Controller层]
    B --> C[Service层]
    C --> D[Repository层]
    D --> E[(MySQL数据库)]
    C --> F[(Redis缓存)]
    C --> G[外部服务]
    
    subgraph "Spring Boot应用"
        B
        C
        D
        H[Security层]
        I[Exception处理层]
        J[Validation层]
    end
    
    subgraph "数据存储"
        E
        F
    end
    
    subgraph "外部集成"
        G
    end
    
    B --> H
    B --> I
    B --> J
```

### 2.3 路由定义

| 路由 | 用途 |
|------|------|
| /api/auth/login | 用户登录接口 |
| /api/auth/register | 用户注册接口 |
| /api/auth/refresh | JWT令牌刷新 |
| /api/users/profile | 用户个人资料管理 |
| /api/courses | 课程管理接口 |
| /api/courses/{id} | 单个课程操作 |
| /api/health | 应用健康检查 |
| /api/actuator/health | Spring Boot健康检查 |
| /api/actuator/info | 应用信息接口 |
| /api/actuator/metrics | 应用指标监控 |

## 3. 免费云服务资源选择

### 3.1 核心服务

#### Railway (主要部署平台)
- **免费额度**: $5/月免费额度
- **包含服务**: 
  - Web应用部署
  - PostgreSQL/MySQL数据库
  - Redis缓存
  - 自动SSL证书
  - 自定义域名支持

#### GitHub (代码托管和CI/CD)
- **免费额度**: 
  - 无限公共仓库
  - 私有仓库支持
  - GitHub Actions: 2000分钟/月
  - GitHub Packages: 500MB存储

### 3.2 辅助服务

#### 监控和日志
- **UptimeRobot**: 免费网站监控 (50个监控点)
- **Sentry**: 免费错误追踪 (5000错误/月)
- **SonarCloud**: 免费代码质量分析
- **LogRocket**: 免费日志分析 (1000会话/月)

#### 邮件服务
- **SendGrid**: 免费邮件发送 (100封/天)
- **Resend**: 免费邮件服务 (3000封/月)
- **Mailgun**: 免费邮件服务 (5000封/月前3个月)

#### 文件存储
- **Cloudinary**: 免费图片/视频处理 (25GB存储)
- **AWS S3**: 免费层 (5GB存储，12个月)

#### DNS和CDN
- **Cloudflare**: 免费CDN和DNS
- **Vercel**: 免费静态资源托管

## 4. 环境配置

### 4.1 本地开发环境 (dev分支)

#### 必需工具安装
```bash
# Java 17 (推荐使用SDKMAN)
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.9-tem
sdk use java 17.0.9-tem

# Maven
sdk install maven 3.9.6

# Git (macOS)
brew install git

# MySQL 8.0
brew install mysql@8.0
brew services start mysql@8.0

# Redis 7.x
brew install redis
brew services start redis

# Railway CLI
npm install -g @railway/cli
```

#### 本地数据库初始化
```bash
# 连接MySQL并创建数据库
mysql -u root -p

# 在MySQL中执行
CREATE DATABASE wanli_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wanli_dev'@'localhost' IDENTIFIED BY 'dev_password_123';
GRANT ALL PRIVILEGES ON wanli_dev.* TO 'wanli_dev'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 本地服务启动
```bash
# 启动Spring Boot应用 (使用内嵌Tomcat)
mvn spring-boot:run

# 或者使用IDE运行主类
# com.wanli.WanliBackendApplication
```

#### 环境变量配置
创建 `src/main/resources/application-dev.yml`：
```yaml
spring:
  profiles:
    active: dev
  datasource:
    url: jdbc:mysql://localhost:3306/wanli_dev?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8mb4
    username: wanli_dev
    password: dev_password_123
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
  data:
    redis:
      host: localhost
      port: 6379
      timeout: 2000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 0
  mail:
    host: smtphz.qiye.163.com
    port: 465
    username: wuning@wanli.ai
    password: CPyx-8vBkKhn5Fx
    properties:
      mail:
        smtp:
          ssl:
            enable: true
          auth: true

server:
  port: 8080
  servlet:
    context-path: /api

jwt:
  secret: ${JWT_SECRET:dev-jwt-secret-key-at-least-32-characters-long}
  expiration: 86400000

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always

logging:
  level:
    com.wanli: DEBUG
    org.springframework.security: DEBUG
```

### 4.2 Railway项目配置

#### 创建Railway项目
```bash
# 登录Railway
railway login

# 创建staging项目
railway init --name wanli-backend-staging
railway add --service mysql
railway add --service redis

# 创建production项目  
railway init --name wanli-backend-production
railway add --service mysql
railway add --service redis
```

#### Railway环境变量配置

**测试环境 (staging)**
```env
# Spring配置
SPRING_PROFILES_ACTIVE=staging
SERVER_PORT=8080

# 数据库配置 (使用Railway变量)
SPRING_DATASOURCE_URL=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8mb4
SPRING_DATASOURCE_USERNAME=${MYSQL_USER}
SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD}

# Redis配置 (使用Railway变量)
SPRING_DATA_REDIS_HOST=${REDIS_HOST}
SPRING_DATA_REDIS_PORT=${REDIS_PORT}
SPRING_DATA_REDIS_PASSWORD=${REDIS_PASSWORD}

# JWT配置
JWT_SECRET=wanli-backend-jwt-secret-key-2024
JWT_EXPIRATION=86400000

# CORS配置
CORS_ALLOWED_ORIGINS=https://wanli-frontend-staging.vercel.app

# 邮件配置
SPRING_MAIL_HOST=smtphz.qiye.163.com
SPRING_MAIL_PORT=465
SPRING_MAIL_USERNAME=wuning@wanli.ai
SPRING_MAIL_PASSWORD=CPyx-8vBkKhn5Fx
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true

# 监控配置
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

**生产环境 (production)**
```env
# Spring配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# 数据库配置 (使用Railway变量)
SPRING_DATASOURCE_URL=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8mb4
SPRING_DATASOURCE_USERNAME=${MYSQL_USER}
SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD}

# Redis配置 (使用Railway变量)
SPRING_DATA_REDIS_HOST=${REDIS_HOST}
SPRING_DATA_REDIS_PORT=${REDIS_PORT}
SPRING_DATA_REDIS_PASSWORD=${REDIS_PASSWORD}

# JWT配置
JWT_SECRET=wanli-backend-jwt-secret-key-2024
JWT_EXPIRATION=86400000

# CORS配置
CORS_ALLOWED_ORIGINS=https://wanli-frontend.vercel.app

# 邮件配置
SPRING_MAIL_HOST=smtphz.qiye.163.com
SPRING_MAIL_PORT=465
SPRING_MAIL_USERNAME=wuning@wanli.ai
SPRING_MAIL_PASSWORD=CPyx-8vBkKhn5Fx
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true

# 监控配置
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

## 5. CI/CD流程配置

### 5.1 GitHub Actions工作流

创建 `.github/workflows/ci-cd.yml`：

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, staging, dev]
  pull_request:
    branches: [main, staging]

env:
  JAVA_VERSION: '17'
  MAVEN_OPTS: '-Xmx1024m'

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root_password
          MYSQL_DATABASE: test_db
          MYSQL_USER: test_user
          MYSQL_PASSWORD: test_password
        options: >
          --health-cmd="mysqladmin ping -h localhost"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
        ports:
          - 3306:3306
      
      redis:
        image: redis:7-alpine
        options: >
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
        ports:
          - 6379:6379
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: ${{ env.JAVA_VERSION }}
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Verify MySQL connection
      run: |
        mysql -h 127.0.0.1 -P 3306 -u test_user -ptest_password -e "SELECT 1"
    
    - name: Compile project
      run: mvn clean compile
    
    - name: Run code quality checks
      run: |
        mvn checkstyle:check
        mvn spotbugs:check
        mvn pmd:check
    
    - name: Run tests
      run: mvn test
      env:
        SPRING_DATASOURCE_URL: jdbc:mysql://localhost:3306/test_db
        SPRING_DATASOURCE_USERNAME: test_user
        SPRING_DATASOURCE_PASSWORD: test_password
        SPRING_DATA_REDIS_HOST: localhost
        SPRING_DATA_REDIS_PORT: 6379
    
    - name: Run integration tests
      run: mvn failsafe:integration-test
      env:
        SPRING_DATASOURCE_URL: jdbc:mysql://localhost:3306/test_db
        SPRING_DATASOURCE_USERNAME: test_user
        SPRING_DATASOURCE_PASSWORD: test_password
        SPRING_DATA_REDIS_HOST: localhost
        SPRING_DATA_REDIS_PORT: 6379
    
    - name: Generate test coverage
      run: mvn jacoco:report
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        file: ./target/site/jacoco/jacoco.xml
        fail_ci_if_error: false

  code-quality:
    name: Code Quality Analysis
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'pull_request'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: ${{ env.JAVA_VERSION }}
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Cache SonarCloud packages
      uses: actions/cache@v3
      with:
        path: ~/.sonar/cache
        key: ${{ runner.os }}-sonar
        restore-keys: ${{ runner.os }}-sonar
    
    - name: Build and analyze with SonarCloud
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      run: |
        mvn clean verify sonar:sonar \
          -Dsonar.projectKey=wanli-backend \
          -Dsonar.organization=your-org \
          -Dsonar.host.url=https://sonarcloud.io

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/maven@master
      continue-on-error: true
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
    
    - name: Run CodeQL Analysis
      uses: github/codeql-action/init@v2
      with:
        languages: java
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2

  deploy-staging:
    name: Deploy to Staging
    needs: [test, code-quality]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/staging' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: ${{ env.JAVA_VERSION }}
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Build application
      run: mvn clean package -DskipTests -Dspring.profiles.active=staging
    
    - name: Install Railway CLI
      run: npm install -g @railway/cli
    
    - name: Deploy to Railway Staging
      env:
        RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
      run: |
        railway login --token $RAILWAY_TOKEN
        railway link ${{ secrets.RAILWAY_STAGING_PROJECT_ID }}
        railway up --detach
    
    - name: Wait for deployment
      run: sleep 60
    
    - name: Health check
      run: |
        curl -f ${{ secrets.STAGING_URL }}/api/health || exit 1
    
    - name: Run E2E tests
      run: mvn test -Dtest=**/*E2ETest
      env:
        API_BASE_URL: ${{ secrets.STAGING_URL }}

  deploy-production:
    name: Deploy to Production
    needs: [test, code-quality, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: ${{ env.JAVA_VERSION }}
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Build application
      run: mvn clean package -DskipTests -Dspring.profiles.active=prod
    
    - name: Install Railway CLI
      run: npm install -g @railway/cli
    
    - name: Deploy to Railway Production
      env:
        RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
      run: |
        railway login --token $RAILWAY_TOKEN
        railway link ${{ secrets.RAILWAY_PRODUCTION_PROJECT_ID }}
        railway up --detach
    
    - name: Wait for deployment
      run: sleep 90
    
    - name: Health check
      run: |
        curl -f ${{ secrets.PRODUCTION_URL }}/api/health || exit 1
    
    - name: Notify deployment success
      if: success()
      uses: 8398a7/action-slack@v3
      with:
        status: success
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
        text: '🚀 Production deployment successful!'
```

### 5.2 GitHub Secrets配置

在GitHub仓库设置中添加以下Secrets：

```bash
# Railway配置
RAILWAY_TOKEN=your_railway_api_token
RAILWAY_STAGING_PROJECT_ID=your_staging_project_id
RAILWAY_PRODUCTION_PROJECT_ID=your_production_project_id

# 部署URL
STAGING_URL=https://wanli-backend-staging.up.railway.app
PRODUCTION_URL=https://wanli-backend-production.up.railway.app

# 代码质量和安全
SONAR_TOKEN=your_sonarcloud_token
SNYK_TOKEN=your_snyk_security_token
CODECOV_TOKEN=your_codecov_coverage_token

# 通知
SLACK_WEBHOOK_URL=your_slack_notification_webhook
```

## 6. 数据模型和API定义

### 6.1 数据模型定义

```mermaid
erDiagram
    USER ||--o{ COURSE : creates
    USER ||--o{ ENROLLMENT : enrolls
    COURSE ||--o{ ENROLLMENT : has
    COURSE ||--o{ LESSON : contains
    USER ||--o{ USER_PROFILE : has
    
    USER {
        bigint id PK
        varchar email UK
        varchar username UK
        varchar password_hash
        varchar full_name
        varchar avatar
        boolean is_active
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }
    
    USER_PROFILE {
        bigint id PK
        bigint user_id FK
        varchar phone
        date birth_date
        varchar bio
        varchar location
        timestamp created_at
        timestamp updated_at
    }
    
    COURSE {
        bigint id PK
        varchar title
        text description
        decimal price
        boolean is_published
        bigint creator_id FK
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }
    
    LESSON {
        bigint id PK
        bigint course_id FK
        varchar title
        text content
        integer sort_order
        integer duration_minutes
        timestamp created_at
        timestamp updated_at
    }
    
    ENROLLMENT {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        decimal paid_amount
        varchar status
        timestamp enrolled_at
        timestamp completed_at
    }
```

### 6.2 数据定义语言

**用户表 (users)**
```sql
-- 创建用户表
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    avatar VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_users_email (email),
    INDEX idx_users_username (username),
    INDEX idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初始化管理员用户
INSERT INTO users (email, username, password_hash, full_name, is_active) VALUES
('admin@wanli.com', 'admin', '$2a$10$example_hash', '系统管理员', TRUE);
```

**课程表 (courses)**
```sql
-- 创建课程表
CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0.00,
    is_published BOOLEAN DEFAULT FALSE,
    creator_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (creator_id) REFERENCES users(id),
    INDEX idx_courses_creator_id (creator_id),
    INDEX idx_courses_created_at (created_at),
    INDEX idx_courses_is_published (is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初始化示例课程
INSERT INTO courses (title, description, price, is_published, creator_id) VALUES
('Java基础教程', 'Java编程语言基础知识学习', 99.00, TRUE, 1),
('Spring Boot实战', 'Spring Boot框架实战开发', 199.00, TRUE, 1);
```

### 6.3 核心API定义

#### 用户认证相关

**用户登录**
```
POST /api/auth/login
```

请求参数:
| 参数名 | 参数类型 | 是否必需 | 描述 |
|--------|----------|----------|------|
| email | string | true | 用户邮箱 |
| password | string | true | 用户密码 |

响应参数:
| 参数名 | 参数类型 | 描述 |
|--------|----------|------|
| success | boolean | 请求是否成功 |
| message | string | 响应消息 |
| data | object | 响应数据 |
| data.token | string | JWT访问令牌 |
| data.refreshToken | string | JWT刷新令牌 |
| data.user | object | 用户信息 |

请求示例:
```json
{
  "email": "wuning@wanli.ai",
  "password": "password123"
}
```

响应示例:
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "wuning@wanli.ai",
      "username": "user123",
      "fullName": "张三"
    }
  }
}
```

#### 课程管理相关

**获取课程列表**
```
GET /api/courses
```

查询参数:
| 参数名 | 参数类型 | 是否必需 | 描述 |
|--------|----------|----------|------|
| page | integer | false | 页码，默认0 |
| size | integer | false | 每页大小，默认10 |
| sort | string | false | 排序字段，默认createdAt |
| direction | string | false | 排序方向，默认desc |

#### 健康检查API

**应用健康检查**
```
GET /api/health
```

响应示例:
```json
{
  "status": "UP",
  "service": "wanli-backend",
  "version": "1.0.0",
  "database": "UP",
  "redis": "UP",
  "timestamp": "2024-01-20T10:30:00Z"
}
```

## 7. 安全架构

### 7.1 认证授权流程

```mermaid
sequenceDiagram
    participant C as 客户端
    participant S as Spring Security
    participant J as JWT Service
    participant D as 数据库
    
    C->>S: 登录请求 (email/password)
    S->>D: 验证用户凭据
    D-->>S: 返回用户信息
    S->>J: 生成JWT令牌
    J-->>S: 返回访问令牌和刷新令牌
    S-->>C: 返回令牌
    
    C->>S: API请求 (携带JWT)
    S->>J: 验证JWT令牌
    J-->>S: 返回用户信息
    S-->>C: 允许访问
```

### 7.2 数据安全措施

1. **密码加密**: 使用BCrypt算法加密存储
2. **JWT令牌**: 使用HS256算法签名
3. **HTTPS强制**: 生产环境强制使用HTTPS
4. **SQL注入防护**: 使用JPA参数化查询
5. **XSS防护**: 输入验证和输出编码
6. **CSRF防护**: 使用Spring Security CSRF保护

### 7.3 Spring Security配置

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/auth/**", "/api/health", "/actuator/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

## 8. 性能优化

### 8.1 缓存策略

```java
// Redis缓存配置
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(30))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .build();
    }
}
```

### 8.2 数据库优化

1. **连接池配置**: HikariCP连接池优化
2. **索引优化**: 为常用查询字段添加索引
3. **分页查询**: 使用Spring Data JPA分页
4. **查询优化**: 避免N+1查询问题

### 8.3 JVM优化

```bash
# JVM参数优化
JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport"
```

## 9. 监控和维护

### 9.1 应用监控

#### 健康检查端点
```java
@RestController
@RequestMapping("/api")
public class HealthController {
    
    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 检查数据库连接
            try (Connection connection = dataSource.getConnection()) {
                connection.createStatement().execute("SELECT 1");
                response.put("database", "UP");
            }
            
            // 检查Redis连接
            redisTemplate.opsForValue().get("health-check");
            response.put("redis", "UP");
            
            response.put("status", "UP");
            response.put("service", "wanli-backend");
            response.put("version", "1.0.0");
            response.put("timestamp", Instant.now().toString());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "DOWN");
            response.put("error", e.getMessage());
            response.put("timestamp", Instant.now().toString());
            
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
        }
    }
}
```

#### UptimeRobot监控配置
1. 注册UptimeRobot账户
2. 添加HTTP(s)监控
3. 监控URL: `https://wanli-backend-production.up.railway.app/api/health`
4. 检查间隔: 5分钟
5. 配置邮件/短信告警

### 9.2 错误追踪

#### Sentry集成
```yaml
# application.yml
sentry:
  dsn: ${SENTRY_DSN}
  environment: ${SPRING_PROFILES_ACTIVE}
  traces-sample-rate: 1.0
  debug: false
```

### 9.3 日志管理

```yaml
# logback-spring.xml配置
logging:
  level:
    com.wanli: INFO
    org.springframework.security: WARN
    org.hibernate.SQL: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/wanli-backend.log
    max-size: 10MB
    max-history: 30
```

## 10. 部署步骤

### 10.1 初始化项目

#### 步骤1: 创建GitHub仓库
```bash
# 创建本地仓库
git init
git add .
git commit -m "feat: 初始化万里后端项目"

# 关联远程仓库
git remote add origin https://github.com/JamesWuVip/wanli-backend6.git
git branch -M main
git push -u origin main

# 创建开发分支
git checkout -b dev
git push -u origin dev

# 创建测试分支
git checkout -b staging
git push -u origin staging
```

#### 步骤2: 配置本地开发环境
```bash
# 安装并启动MySQL
brew install mysql@8.0
brew services start mysql@8.0

# 安装并启动Redis
brew install redis
brew services start redis

# 创建开发数据库
mysql -u root -p
CREATE DATABASE wanli_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 步骤3: 配置Railway项目
```bash
# 登录Railway
railway login

# 为staging环境创建项目
railway init --name wanli-backend-staging
railway add --service mysql
railway add --service redis

# 为production环境创建项目
railway init --name wanli-backend-production
railway add --service mysql
railway add --service redis
```

### 10.2 部署配置文件

#### Railway配置 (railway.json)
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "mvn clean package -DskipTests"
  },
  "deploy": {
    "startCommand": "java -Dserver.port=$PORT -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE -jar target/wanli-backend-*.jar",
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

#### Docker配置 (Dockerfile)
```dockerfile
# 多阶段构建
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# 安装Maven
RUN apk add --no-cache maven

# 复制Maven配置和源代码
COPY pom.xml .
COPY src ./src

# 构建应用
RUN mvn clean package -DskipTests

# 生产镜像
FROM eclipse-temurin:17-jre-alpine AS production

WORKDIR /app

# 创建非root用户
RUN addgroup -g 1001 -S spring && \
    adduser -S spring -u 1001 -G spring

# 安装curl用于健康检查
RUN apk add --no-cache curl

# 复制JAR文件
COPY --from=builder --chown=spring:spring /app/target/wanli-backend-*.jar app.jar

# 切换到非root用户
USER spring

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1

# JVM优化参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport"

# 启动应用
CMD ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-prod} -jar app.jar"]
```

## 11. 故障排除

### 11.1 常见部署问题

#### Railway部署失败
```bash
# 查看部署日志
railway logs

# 查看构建日志
railway logs --build

# 重新部署
railway up --detach
```

#### 数据库连接问题
```bash
# 检查Railway数据库状态
railway status

# 连接到Railway数据库
railway connect mysql
```

#### 内存不足问题
```bash
# 在Railway环境变量中设置JVM参数
JAVA_OPTS=-Xms256m -Xmx512m -XX:+UseG1GC
```

### 11.2 性能问题诊断

#### 应用性能监控
```bash
# 查看JVM内存使用情况
curl https://your-app.railway.app/actuator/metrics/jvm.memory.used

# 查看数据库连接池状态
curl https://your-app.railway.app/actuator/metrics/hikaricp.connections
```

#### 数据库性能优化
```sql
-- 查看慢查询
SHOW PROCESSLIST;

-- 分析查询执行计划
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- 添加索引
CREATE INDEX idx_users_email ON users(email);
```

### 11.3 日志分析

#### 应用日志查看
```bash
# Railway日志查看
railway logs --tail

# 过滤错误日志
railway logs | grep ERROR

# 查看特定时间段日志
railway logs --since 1h
```

## 12. 成本优化建议

### 12.1 Railway资源优化

1. **合理配置资源**: 根据实际需求调整CPU和内存配置
2. **数据库优化**: 定期清理无用数据，优化查询性能
3. **缓存策略**: 合理使用Redis缓存，减少数据库查询
4. **监控使用量**: 定期检查Railway使用量，避免超出免费额度

### 12.2 第三方服务成本控制

1. **邮件服务**: 选择合适的邮件服务提供商，控制发送量
2. **监控服务**: 合理配置监控频率，避免过度监控
3. **代码质量工具**: 充分利用免费额度，合理安排扫描频率

### 12.3 开发效率提升

1. **自动化部署**: 充分利用CI/CD流程，减少手动操作
2. **代码质量**: 提前发现和修复问题，减少生产环境故障
3. **监控告警**: 及时发现问题，快速响应和修复

---

## 总结

本文档整合了万里后端项目的完整技术架构、部署流程和最佳实践。通过遵循本指南，可以实现：

1. **完整的开发环境搭建**：从本地开发到生产部署的完整流程
2. **自动化CI/CD流程**：代码质量检查、安全扫描、自动部署
3. **全面的监控体系**：应用监控、错误追踪、性能分析
4. **成本优化策略**：充分利用免费资源，控制运营成本
5. **故障排除指南**：常见问题的诊断和解决方案

建议开发团队严格按照本文档执行，确保项目的稳定性、安全性和可维护性。

## 13. 云端服务清单

### 13.1 核心部署服务

#### Railway (主要部署平台)
- **管理面板**: https://railway.app/dashboard
- **项目访问地址**:
  - Staging: https://wanli-backend-staging.up.railway.app
  - Production: https://wanli-backend-production.up.railway.app
- **健康检查端点**:
  - Staging: https://wanli-backend-staging.up.railway.app/api/health
  - Production: https://wanli-backend-production.up.railway.app/api/health
- **数据库连接**: 通过Railway环境变量自动配置
- **Redis连接**: 通过Railway环境变量自动配置
- **CLI工具**: `npm install -g @railway/cli`
- **登录命令**: `railway login`

#### GitHub (代码托管和CI/CD)
- **仓库地址**: https://github.com/JamesWuVip/wanli-backend6
- **Actions面板**: https://github.com/JamesWuVip/wanli-backend6/actions
- **Secrets配置**: https://github.com/JamesWuVip/wanli-backend6/settings/secrets/actions
- **分支管理**:
  - main: 生产环境分支
  - staging: 测试环境分支
  - dev: 开发环境分支

### 13.2 监控和日志服务

#### UptimeRobot (网站监控)
- **管理面板**: https://uptimerobot.com/dashboard
- **监控端点**:
  - Staging: https://wanli-backend-staging.up.railway.app/api/health
  - Production: https://wanli-backend-production.up.railway.app/api/health
- **免费额度**: 50个监控点
- **检查间隔**: 5分钟
- **告警方式**: 邮件、短信、Webhook

#### Sentry (错误追踪)
- **管理面板**: https://sentry.io/
- **项目地址**: https://sentry.io/organizations/your-org/projects/wanli-backend/
- **DSN配置**: 在环境变量中设置 `SENTRY_DSN`
- **免费额度**: 5000错误/月
- **集成方式**: Spring Boot自动配置

#### LogRocket (用户会话录制)
- **管理面板**: https://app.logrocket.com/
- **免费额度**: 1000会话/月
- **集成方式**: JavaScript SDK

### 13.3 代码质量和安全服务

#### SonarCloud (代码质量分析)
- **管理面板**: https://sonarcloud.io/
- **项目地址**: https://sonarcloud.io/project/overview?id=wanli-backend
- **组织**: your-org
- **Token配置**: GitHub Secrets中的 `SONAR_TOKEN`
- **集成方式**: GitHub Actions自动触发

#### Codecov (代码覆盖率)
- **管理面板**: https://codecov.io/
- **项目地址**: https://codecov.io/gh/JamesWuVip/wanli-backend6
- **Token配置**: GitHub Secrets中的 `CODECOV_TOKEN`
- **报告上传**: GitHub Actions自动上传

#### Snyk (安全漏洞扫描)
- **管理面板**: https://app.snyk.io/
- **项目地址**: https://app.snyk.io/org/your-org/projects
- **Token配置**: GitHub Secrets中的 `SNYK_TOKEN`
- **扫描方式**: GitHub Actions自动扫描

### 13.4 邮件服务

#### SendGrid (邮件发送)
- **管理面板**: https://app.sendgrid.com/
- **API文档**: https://docs.sendgrid.com/
- **免费额度**: 100封/天
- **SMTP配置**:
  - Host: smtp.sendgrid.net
  - Port: 587 (TLS) 或 465 (SSL)
  - Username: apikey
  - Password: 您的API密钥

#### 网易企业邮箱 (当前使用)
- **SMTP服务器**: smtphz.qiye.163.com
- **端口**: 465 (SSL)
- **用户名**: wuning@wanli.ai
- **密码**: CPyx-8vBkKhn5Fx
- **管理面板**: https://qiye.163.com/

### 13.5 文件存储服务

#### Cloudinary (图片/视频处理)
- **管理面板**: https://cloudinary.com/console
- **免费额度**: 25GB存储，25GB带宽/月
- **API文档**: https://cloudinary.com/documentation
- **上传端点**: https://api.cloudinary.com/v1_1/{cloud_name}/image/upload

#### AWS S3 (对象存储)
- **管理控制台**: https://s3.console.aws.amazon.com/
- **免费层**: 5GB存储，20000个GET请求，2000个PUT请求/月
- **区域**: us-east-1 (推荐)
- **访问方式**: AWS SDK或REST API

### 13.6 CDN和DNS服务

#### Cloudflare (CDN和DNS)
- **管理面板**: https://dash.cloudflare.com/
- **DNS管理**: 免费DNS解析服务
- **CDN服务**: 免费全球CDN加速
- **SSL证书**: 免费SSL/TLS证书
- **API文档**: https://developers.cloudflare.com/api/

#### Vercel (静态资源托管)
- **管理面板**: https://vercel.com/dashboard
- **部署方式**: Git集成自动部署
- **自定义域名**: 支持免费自定义域名
- **边缘函数**: Serverless函数支持

### 13.7 通知服务

#### Slack (团队通知)
- **工作区**: your-workspace.slack.com
- **Webhook URL**: 在GitHub Secrets中配置 `SLACK_WEBHOOK_URL`
- **集成方式**: GitHub Actions通知
- **通知内容**: 部署状态、测试结果、安全扫描结果

### 13.8 CI/CD基础设施服务

#### GitHub Actions (CI/CD平台)
- **管理面板**: https://github.com/JamesWuVip/wanli-backend6/actions
- **工作流配置**: `.github/workflows/`目录
- **免费额度**: 2000分钟/月 (公共仓库无限制)
- **Runner类型**: ubuntu-latest, windows-latest, macos-latest
- **必需的Secrets配置**:
  - `RAILWAY_TOKEN`: Railway部署令牌
  - `RAILWAY_TOKEN_DEV`: 开发环境Railway令牌
  - `RAILWAY_TOKEN_STAGING`: 测试环境Railway令牌
  - `RAILWAY_TOKEN_PROD`: 生产环境Railway令牌
  - `SONAR_TOKEN`: SonarCloud分析令牌
  - `CODECOV_TOKEN`: Codecov上传令牌
  - `SNYK_TOKEN`: Snyk安全扫描令牌
  - `SLACK_WEBHOOK_URL`: Slack通知Webhook
  - `DOCKER_USERNAME`: Docker Hub用户名
  - `DOCKER_PASSWORD`: Docker Hub密码

#### Maven Central Repository (依赖管理)
- **仓库地址**: https://repo1.maven.org/maven2/
- **镜像配置**: 阿里云Maven镜像 (https://maven.aliyun.com/repository/public)
- **私有仓库**: GitHub Packages (可选)
- **配置文件**: `pom.xml`, `settings.xml`

#### Docker Hub (容器镜像仓库)
- **管理面板**: https://hub.docker.com/
- **镜像仓库**: `your-username/wanli-backend`
- **免费额度**: 1个私有仓库，无限公共仓库
- **自动构建**: 与GitHub集成自动构建
- **标签策略**:
  - `latest`: 最新稳定版本
  - `staging`: 测试环境版本
  - `v1.0.0`: 版本标签

#### JaCoCo (代码覆盖率工具)
- **集成方式**: Maven插件
- **报告生成**: `target/site/jacoco/index.html`
- **上传到**: Codecov平台
- **配置文件**: `pom.xml`中的jacoco-maven-plugin

#### Checkstyle (代码风格检查)
- **配置文件**: `checkstyle.xml`
- **集成方式**: Maven插件
- **检查规则**: Google Java Style Guide
- **报告输出**: `target/checkstyle-result.xml`

#### SpotBugs (静态代码分析)
- **集成方式**: Maven插件
- **分析规则**: FindBugs规则集
- **报告格式**: XML, HTML
- **配置文件**: `spotbugs-exclude.xml`

### 13.9 数据库和缓存服务

#### Railway MySQL (主数据库)
- **管理面板**: Railway项目控制台
- **连接信息**: 通过环境变量自动注入
- **版本**: MySQL 8.0
- **备份策略**: Railway自动备份
- **监控**: Railway内置监控
- **连接池**: HikariCP (Spring Boot默认)

#### Railway Redis (缓存服务)
- **管理面板**: Railway项目控制台
- **连接信息**: 通过环境变量自动注入
- **版本**: Redis 7.x
- **持久化**: RDB + AOF
- **监控**: Railway内置监控
- **客户端**: Lettuce (Spring Boot默认)

#### 本地开发数据库
- **MySQL**: 本地安装或Docker容器
- **Redis**: 本地安装或Docker容器
- **管理工具**:
  - MySQL Workbench
  - phpMyAdmin
  - Redis Desktop Manager
  - RedisInsight

### 13.10 安全和合规服务

#### OWASP Dependency Check
- **集成方式**: Maven插件
- **扫描内容**: 依赖漏洞检查
- **报告格式**: HTML, XML, JSON
- **更新频率**: 每日更新漏洞数据库

#### GitHub Security Advisories
- **管理面板**: https://github.com/JamesWuVip/wanli-backend6/security
- **功能**: 依赖漏洞告警
- **集成**: Dependabot自动PR
- **扫描范围**: Maven依赖、Docker镜像

#### Dependabot (依赖更新)
- **配置文件**: `.github/dependabot.yml`
- **更新频率**: 每周检查
- **支持生态**: Maven, Docker, GitHub Actions
- **自动PR**: 安全更新和版本更新

### 13.11 性能和负载测试服务

#### JMeter (性能测试)
- **测试计划**: `src/test/jmeter/`
- **CI集成**: GitHub Actions中运行
- **报告生成**: HTML报告
- **测试场景**: API负载测试、压力测试

#### Artillery (负载测试)
- **配置文件**: `artillery.yml`
- **测试类型**: HTTP API测试
- **报告格式**: JSON, HTML
- **集成方式**: npm包，CI/CD中执行

### 13.12 API文档和测试服务

#### Swagger/OpenAPI (API文档)
- **访问地址**: 
  - 开发环境: http://localhost:8080/swagger-ui.html
  - 测试环境: https://wanli-backend-staging.up.railway.app/swagger-ui.html
  - 生产环境: https://wanli-backend-production.up.railway.app/swagger-ui.html
- **JSON规范**: `/v3/api-docs`
- **工具**: Knife4j (增强版Swagger UI)

#### Postman (API测试)
- **工作区**: Postman Cloud
- **集合导出**: `postman_collection.json`
- **环境变量**: 开发、测试、生产环境
- **自动化测试**: Newman CLI集成

### 13.13 环境变量和密钥管理

#### GitHub Secrets (CI/CD密钥)
- **配置路径**: Repository Settings > Secrets and variables > Actions
- **环境级别**: Repository, Environment
- **加密存储**: AES-256加密
- **访问控制**: 基于分支和环境

#### Railway Environment Variables (运行时配置)
- **配置方式**: Railway控制台或CLI
- **环境隔离**: 开发、测试、生产环境独立
- **动态更新**: 支持运行时更新
- **模板变量**: 支持服务间引用

#### Spring Boot Profiles (应用配置)
- **配置文件**: 
  - `application.yml` (默认)
  - `application-dev.yml` (开发)
  - `application-staging.yml` (测试)
  - `application-prod.yml` (生产)
- **激活方式**: `SPRING_PROFILES_ACTIVE`环境变量
- **配置优先级**: 环境变量 > 配置文件 > 默认值

### 13.14 构建和部署工具

#### Maven (构建工具)
- **版本**: 3.9.x
- **配置文件**: `pom.xml`
- **仓库镜像**: 阿里云Maven仓库
- **插件管理**: Spring Boot Maven Plugin
- **生命周期**: compile, test, package, install, deploy

#### Docker (容器化)
- **基础镜像**: openjdk:17-jdk-slim
- **多阶段构建**: 构建阶段 + 运行阶段
- **镜像优化**: 分层缓存、最小化镜像大小
- **健康检查**: 内置健康检查端点

#### Railway CLI (部署工具)
- **安装**: `npm install -g @railway/cli`
- **认证**: `railway login`
- **项目管理**: `railway init`, `railway connect`
- **服务管理**: `railway add`, `railway remove`
- **日志查看**: `railway logs`
- **环境管理**: `railway environment`

### 13.15 开发和调试工具

#### IntelliJ IDEA (IDE)
- **版本**: Ultimate Edition (推荐)
- **插件**:
  - Spring Boot
  - Lombok
  - SonarLint
  - CheckStyle-IDEA
  - Docker
- **配置**: 代码格式化、检查规则

#### Visual Studio Code (轻量级编辑器)
- **扩展**:
  - Extension Pack for Java
  - Spring Boot Extension Pack
  - Docker
  - GitLens
- **配置**: `settings.json`, `launch.json`

#### Git (版本控制)
- **托管平台**: GitHub
- **分支策略**: GitFlow
- **提交规范**: Conventional Commits
- **钩子**: pre-commit, pre-push

### 13.16 API端点清单

#### 健康检查端点
- **应用健康检查**: `/api/health`
- **Spring Boot Actuator**: `/actuator/health`
- **详细健康信息**: `/actuator/health/details`
- **应用信息**: `/actuator/info`
- **应用指标**: `/actuator/metrics`

#### 认证授权端点
- **用户登录**: `POST /api/auth/login`
- **用户注册**: `POST /api/auth/register`
- **令牌刷新**: `POST /api/auth/refresh`
- **用户登出**: `POST /api/auth/logout`
- **密码重置**: `POST /api/auth/reset-password`

#### 业务功能端点
- **用户管理**: `/api/users/*`
- **课程管理**: `/api/courses/*`
- **文件上传**: `/api/upload/*`
- **系统配置**: `/api/config/*`

#### 监控和管理端点
- **应用指标**: `/actuator/metrics/*`
- **JVM信息**: `/actuator/metrics/jvm.*`
- **数据库连接池**: `/actuator/metrics/hikaricp.*`
- **HTTP请求**: `/actuator/metrics/http.*`
- **缓存统计**: `/actuator/metrics/cache.*`

### 13.17 快速访问链接

#### 开发环境
- **本地应用**: http://localhost:8080
- **本地API文档**: http://localhost:8080/swagger-ui.html
- **本地健康检查**: http://localhost:8080/api/health
- **本地Actuator**: http://localhost:8080/actuator

#### 测试环境
- **应用地址**: https://wanli-backend-staging.up.railway.app
- **API文档**: https://wanli-backend-staging.up.railway.app/swagger-ui.html
- **健康检查**: https://wanli-backend-staging.up.railway.app/api/health
- **Railway控制台**: https://railway.app/project/[staging-project-id]

#### 生产环境
- **应用地址**: https://wanli-backend-production.up.railway.app
- **API文档**: https://wanli-backend-production.up.railway.app/swagger-ui.html
- **健康检查**: https://wanli-backend-production.up.railway.app/api/health
- **Railway控制台**: https://railway.app/project/[production-project-id]

#### 监控和分析
- **UptimeRobot监控**: https://uptimerobot.com/dashboard
- **Sentry错误追踪**: https://sentry.io/organizations/[org]/projects/wanli-backend/
- **SonarCloud代码质量**: https://sonarcloud.io/project/overview?id=wanli-backend
- **Codecov覆盖率**: https://codecov.io/gh/JamesWuVip/wanli-backend6

### 13.18 紧急联系和恢复

#### 紧急联系方式
- **技术负责人**: wuning@wanli.ai
- **运维团队**: ops@wanli.ai
- **Slack紧急频道**: #incidents
- **电话支持**: +86-xxx-xxxx-xxxx

#### 灾难恢复
- **数据备份**: Railway自动备份 + 手动备份
- **代码恢复**: GitHub仓库 + 本地克隆
- **配置恢复**: 环境变量文档 + Secrets备份
- **服务恢复**: Railway重新部署 + Docker镜像回滚

#### 故障响应流程
1. **监控告警**: UptimeRobot/Sentry自动告警
2. **问题确认**: 检查健康检查端点和日志
3. **影响评估**: 确定故障范围和影响用户
4. **快速修复**: 回滚部署或热修复
5. **根因分析**: 分析日志和监控数据
6. **预防措施**: 更新监控规则和部署流程

---

## 云端服务配置检查清单

### 必需配置项
- [ ] Railway项目创建和环境变量配置
- [ ] GitHub仓库创建和Secrets配置
- [ ] UptimeRobot监控设置
- [ ] Sentry项目创建和DSN配置
- [ ] SonarCloud项目创建和Token配置
- [ ] Codecov项目集成和Token配置
- [ ] SendGrid账户创建和API Key配置
- [ ] Slack工作区创建和Webhook配置

### 可选配置项
- [ ] Snyk安全扫描集成
- [ ] Docker Hub镜像仓库
- [ ] Cloudflare CDN配置
- [ ] LogRocket会话录制
- [ ] Cloudinary图片处理
- [ ] AWS S3存储配置

### 验证步骤
- [ ] 本地开发环境启动成功
- [ ] CI/CD流程运行正常
- [ ] 测试环境部署成功
- [ ] 生产环境部署成功
- [ ] 监控告警正常工作
- [ ] 所有健康检查端点响应正常

**注意**: 请确保所有敏感信息（API密钥、密码等）都通过环境变量或Secrets管理，不要在代码中硬编码。

### 13.8 Token获取和配置指南

#### Railway Token 获取步骤
1. **登录Railway控制台**: https://railway.app/
2. **进入Account Settings**: 点击右上角头像 → Account Settings
3. **生成API Token**: 
   - 点击 "Tokens" 标签
   - 点击 "Create New Token"
   - 输入描述（如："GitHub Actions CI/CD"）
   - 复制生成的token（格式：`railway_xxxxx`）
4. **获取项目ID**:
   - 进入项目页面
   - URL中的ID即为项目ID（如：`https://railway.app/project/abc123def456`）
   - Staging项目ID和Production项目ID需要分别获取

#### SonarCloud Token 获取步骤
1. **登录SonarCloud**: https://sonarcloud.io/
2. **创建组织和项目**:
   - 使用GitHub账户登录
   - 导入GitHub仓库
3. **生成Token**:
   - 点击右上角头像 → My Account
   - 点击 "Security" 标签
   - 在 "Generate Tokens" 部分输入名称
   - 点击 "Generate" 并复制token
4. **配置项目**:
   - 在项目设置中配置Quality Gate
   - 设置项目key（通常为：`组织名_仓库名`）

#### Codecov Token 获取步骤
1. **登录Codecov**: https://codecov.io/
2. **添加仓库**:
   - 使用GitHub账户登录
   - 在仓库列表中找到项目并启用
3. **获取Token**:
   - 进入项目设置页面
   - 在 "Repository Upload Token" 部分复制token
   - 对于公共仓库，token是可选的

#### Snyk Token 获取步骤
1. **注册Snyk账户**: https://app.snyk.io/
2. **集成GitHub**:
   - 在 "Integrations" 中连接GitHub账户
   - 导入需要扫描的仓库
3. **生成API Token**:
   - 点击右上角头像 → Account Settings
   - 在 "API Token" 部分点击 "Show" 并复制

#### Slack Webhook URL 获取步骤
1. **创建Slack应用**:
   - 访问 https://api.slack.com/apps
   - 点击 "Create New App" → "From scratch"
   - 输入应用名称和选择工作区
2. **启用Incoming Webhooks**:
   - 在应用设置中点击 "Incoming Webhooks"
   - 切换开关至 "On"
   - 点击 "Add New Webhook to Workspace"
   - 选择要发送消息的频道
   - 复制生成的Webhook URL

### 13.9 GitHub Secrets 配置步骤

#### 配置路径
1. 进入GitHub仓库页面
2. 点击 "Settings" 标签
3. 在左侧菜单中选择 "Secrets and variables" → "Actions"
4. 点击 "New repository secret"

#### 必需的Secrets配置
```bash
# Railway部署相关
RAILWAY_TOKEN=railway_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
RAILWAY_STAGING_PROJECT_ID=12345678-1234-1234-1234-123456789abc
RAILWAY_PRODUCTION_PROJECT_ID=87654321-4321-4321-4321-cba987654321

# 环境URL（可选，用于通知）
STAGING_URL=https://wanli-backend-staging.up.railway.app
PRODUCTION_URL=https://wanli-backend-production.up.railway.app

# 代码质量和安全扫描
SONAR_TOKEN=squ_1234567890abcdef1234567890abcdef12345678
SNYK_TOKEN=12345678-1234-1234-1234-123456789abc
CODECOV_TOKEN=12345678-1234-1234-1234-123456789abc

# 通知服务
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX

# Docker Hub（可选）
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=your_dockerhub_password_or_token
```

#### 环境级别Secrets（推荐）
对于不同环境使用不同的配置：
1. 创建环境：Repository Settings → Environments
2. 创建 "staging" 和 "production" 环境
3. 为每个环境配置专用的secrets

### 13.10 Token验证方法

#### Railway Token验证
```bash
# 安装Railway CLI
npm install -g @railway/cli

# 使用token登录
railway login --token your_railway_token

# 验证项目访问
railway projects
railway status
```

#### SonarCloud Token验证
```bash
# 使用curl验证token
curl -u your_sonar_token: https://sonarcloud.io/api/authentication/validate

# 或者在项目中测试
mvn sonar:sonar -Dsonar.token=your_sonar_token
```

#### Codecov Token验证
```bash
# 上传测试报告验证
curl -X POST \
  -H "Authorization: Bearer your_codecov_token" \
  -F "file=@coverage.xml" \
  https://codecov.io/upload/v2
```

#### Slack Webhook验证
```bash
# 发送测试消息
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Hello, World!"}' \
  your_slack_webhook_url
```

### 13.11 安全注意事项

#### Token安全管理
1. **定期轮换**: 每3-6个月更新一次API token
2. **最小权限原则**: 只授予必要的权限
3. **监控使用**: 定期检查token使用日志
4. **及时撤销**: 发现泄露立即撤销并重新生成

#### 环境隔离
1. **分离环境**: 开发、测试、生产使用不同的token
2. **访问控制**: 限制token的访问范围和时间
3. **审计日志**: 启用所有服务的审计日志

#### 代码安全
1. **禁止硬编码**: 绝不在代码中硬编码token
2. **环境变量**: 使用环境变量或配置文件
3. **版本控制**: 确保敏感文件不被提交到Git
4. **代码审查**: 所有涉及配置的代码都需要审查

#### 应急响应
1. **泄露处理**: 发现token泄露的处理流程
2. **备用方案**: 准备备用的访问方式
3. **联系方式**: 各服务的紧急联系方式
4. **恢复计划**: 服务中断时的恢复计划

### 13.12 Railway环境变量配置

#### 配置路径
1. 登录Railway控制台：https://railway.app/
2. 选择对应的项目（Staging或Production）
3. 点击项目名称进入项目详情
4. 点击 "Variables" 标签
5. 添加环境变量

#### Staging环境变量配置
```bash
# Spring Boot配置
SPRING_PROFILES_ACTIVE=staging
SERVER_PORT=8080

# 数据库配置（Railway自动注入）
# MYSQL_URL, MYSQL_USERNAME, MYSQL_PASSWORD 由Railway自动提供

# Redis配置（Railway自动注入）
# REDIS_URL 由Railway自动提供

# JWT配置
JWT_SECRET=wanli-backend-jwt-secret-staging-2024-$(openssl rand -hex 32)
JWT_EXPIRATION=86400000

# CORS配置
CORS_ALLOWED_ORIGINS=https://wanli-frontend-staging.vercel.app,http://localhost:3000

# Sentry错误追踪
SENTRY_DSN=https://your-sentry-dsn@o123456.ingest.sentry.io/123456
SENTRY_ENVIRONMENT=staging

# 邮件配置
SMTP_HOST=smtphz.qiye.163.com
SMTP_PORT=465
SMTP_USERNAME=wuning@wanli.ai
SMTP_PASSWORD=your-email-password

# 文件上传配置
FILE_UPLOAD_PATH=/tmp/uploads
MAX_FILE_SIZE=10MB
```

#### Production环境变量配置
```bash
# Spring Boot配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# JWT配置（使用更强的密钥）
JWT_SECRET=wanli-backend-jwt-secret-production-2024-$(openssl rand -hex 64)
JWT_EXPIRATION=86400000

# CORS配置（仅允许生产域名）
CORS_ALLOWED_ORIGINS=https://wanli-frontend.vercel.app

# Sentry错误追踪
SENTRY_DSN=https://your-sentry-dsn@o123456.ingest.sentry.io/123456
SENTRY_ENVIRONMENT=production

# 邮件配置
SMTP_HOST=smtphz.qiye.163.com
SMTP_PORT=465
SMTP_USERNAME=wuning@wanli.ai
SMTP_PASSWORD=your-email-password

# 性能配置
SPRING_JPA_SHOW_SQL=false
LOGGING_LEVEL_ROOT=WARN
LOGGING_LEVEL_COM_WANLI=INFO

# 缓存配置
SPRING_CACHE_TYPE=redis
SPRING_REDIS_TIMEOUT=2000ms
```

#### Sentry DSN获取步骤
1. **登录Sentry**: https://sentry.io/
2. **创建项目**:
   - 选择 "Java" 平台
   - 输入项目名称（如：wanli-backend）
3. **获取DSN**:
   - 在项目设置中找到 "Client Keys (DSN)"
   - 复制DSN URL（格式：`https://key@o123456.ingest.sentry.io/123456`）
4. **配置告警**:
   - 设置错误告警规则
   - 配置邮件或Slack通知

### 13.13 API端点清单

#### 应用API端点
- **健康检查**: `GET /api/health`
- **用户认证**: `POST /api/auth/login`
- **用户注册**: `POST /api/auth/register`
- **令牌刷新**: `POST /api/auth/refresh`
- **用户资料**: `GET /api/users/profile`
- **课程管理**: `GET /api/courses`
- **Spring Boot Actuator**: `GET /api/actuator/health`

#### 监控端点
- **应用指标**: `GET /api/actuator/metrics`
- **应用信息**: `GET /api/actuator/info`
- **JVM内存**: `GET /api/actuator/metrics/jvm.memory.used`
- **数据库连接池**: `GET /api/actuator/metrics/hikaricp.connections`

### 13.14 快速访问链接

#### 开发环境
- **本地应用**: http://localhost:8080/api/health
- **本地API文档**: http://localhost:8080/swagger-ui.html
- **本地Actuator**: http://localhost:8080/actuator/health
- **本地数据库**: mysql://localhost:3306/wanli_dev
- **本地Redis**: redis://localhost:6379
- **本地管理工具**:
  - MySQL Workbench: 连接localhost:3306
  - Redis Desktop Manager: 连接localhost:6379

#### 测试环境
- **应用地址**: https://wanli-backend-staging.up.railway.app
- **API文档**: https://wanli-backend-staging.up.railway.app/swagger-ui.html
- **健康检查**: https://wanli-backend-staging.up.railway.app/api/health
- **Railway项目**: https://railway.app/project/{staging-project-id}
- **Railway日志**: `railway logs --tail -p {staging-project-id}`

#### 生产环境
- **应用地址**: https://wanli-backend-production.up.railway.app
- **API文档**: https://wanli-backend-production.up.railway.app/swagger-ui.html
- **健康检查**: https://wanli-backend-production.up.railway.app/api/health
- **Railway项目**: https://railway.app/project/{production-project-id}
- **Railway日志**: `railway logs --tail -p {production-project-id}`

#### 监控和分析工具
- **UptimeRobot监控**: https://uptimerobot.com/dashboard
- **Sentry错误追踪**: https://sentry.io/organizations/{org}/projects/wanli-backend/
- **SonarCloud代码质量**: https://sonarcloud.io/project/overview?id=wanli-backend
- **Codecov覆盖率**: https://codecov.io/gh/JamesWuVip/wanli-backend6
- **GitHub Actions**: https://github.com/JamesWuVip/wanli-backend6/actions

### 13.15 紧急联系和恢复

#### 服务状态页面
- **Railway状态**: https://status.railway.app/
- **GitHub状态**: https://www.githubstatus.com/
- **Cloudflare状态**: https://www.cloudflarestatus.com/

#### 紧急恢复步骤
1. **检查服务状态**: 访问各服务状态页面
2. **查看监控告警**: 检查UptimeRobot和Sentry告警
3. **查看部署日志**: `railway logs --tail`
4. **回滚部署**: 通过Railway Dashboard或CLI回滚
5. **联系支持**: 通过各服务的支持渠道获取帮助

---

---

## 14. 完整配置检查清单

### 14.1 服务注册和Token获取
- [ ] **Railway账户**: 注册并创建Staging和Production项目
- [ ] **GitHub仓库**: 创建仓库并配置Secrets
- [ ] **SonarCloud**: 注册账户，导入项目，生成Token
- [ ] **Codecov**: 注册账户，添加仓库，获取Token
- [ ] **Snyk**: 注册账户，集成GitHub，生成API Token
- [ ] **Sentry**: 创建项目，获取DSN
- [ ] **Slack**: 创建应用，配置Webhook
- [ ] **UptimeRobot**: 创建监控，配置告警

### 14.2 GitHub Secrets配置验证
```bash
# 检查必需的Secrets是否已配置
gh secret list

# 验证Secrets内容（不会显示实际值）
gh secret get RAILWAY_TOKEN
gh secret get SONAR_TOKEN
gh secret get CODECOV_TOKEN
gh secret get SNYK_TOKEN
gh secret get SLACK_WEBHOOK_URL
```

### 14.3 Railway环境变量配置验证
```bash
# 安装Railway CLI
npm install -g @railway/cli

# 登录Railway
railway login

# 检查项目列表
railway projects

# 连接到Staging项目
railway link {staging-project-id}

# 查看环境变量
railway variables

# 检查服务状态
railway status
```

### 14.4 本地开发环境验证
```bash
# 检查Java版本
java -version  # 应该是17或更高

# 检查Maven版本
mvn -version   # 应该是3.6或更高

# 检查MySQL连接
mysql -h localhost -u root -p -e "SELECT VERSION();"

# 检查Redis连接
redis-cli ping  # 应该返回PONG

# 运行应用
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 验证健康检查
curl http://localhost:8080/api/health
```

### 14.5 CI/CD流程验证
```bash
# 触发GitHub Actions
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main

# 检查工作流状态
gh run list
gh run view {run-id}

# 查看部署日志
railway logs --tail
```

### 14.6 监控和告警验证
1. **UptimeRobot监控**:
   - 访问 https://uptimerobot.com/dashboard
   - 确认监控状态为 "Up"
   - 测试告警通知

2. **Sentry错误追踪**:
   - 访问Sentry项目页面
   - 手动触发一个测试错误
   - 确认错误被正确捕获

3. **SonarCloud代码质量**:
   - 检查代码质量门禁状态
   - 查看代码覆盖率报告
   - 确认没有阻塞性问题

### 14.7 常见问题排除

#### Railway部署失败
```bash
# 检查部署日志
railway logs --tail

# 检查环境变量
railway variables

# 重新部署
railway up --detach

# 检查服务健康状态
curl https://your-app.up.railway.app/api/health
```

#### GitHub Actions失败
1. **检查Secrets配置**:
   - 确认所有必需的Secrets都已配置
   - 验证Token的有效性和权限

2. **检查工作流文件**:
   - 确认`.github/workflows/`目录存在
   - 检查YAML语法是否正确

3. **查看详细日志**:
   ```bash
   gh run view {run-id} --log
   ```

#### 数据库连接问题
1. **检查Railway数据库状态**:
   - 在Railway控制台查看数据库服务状态
   - 确认环境变量正确注入

2. **本地数据库问题**:
   ```bash
   # 启动MySQL服务
   brew services start mysql  # macOS
   sudo systemctl start mysql # Linux
   
   # 检查连接
   mysql -u root -p -e "SHOW DATABASES;"
   ```

#### Token验证失败
1. **Railway Token**:
   ```bash
   railway whoami
   railway projects
   ```

2. **SonarCloud Token**:
   ```bash
   curl -u {token}: https://sonarcloud.io/api/authentication/validate
   ```

3. **Slack Webhook**:
   ```bash
   curl -X POST -H 'Content-type: application/json' \
     --data '{"text":"Test message"}' \
     {webhook-url}
   ```

### 14.8 性能优化建议

#### Railway部署优化
1. **使用多阶段Docker构建**减少镜像大小
2. **配置健康检查**确保服务可用性
3. **设置合适的资源限制**避免超出免费额度

#### 应用性能优化
1. **启用Redis缓存**减少数据库查询
2. **配置连接池**优化数据库连接
3. **使用异步处理**提高响应速度
4. **启用GZIP压缩**减少网络传输

#### 监控优化
1. **设置合理的告警阈值**避免误报
2. **配置多级告警**区分严重程度
3. **定期检查监控数据**优化系统性能

---

**重要提醒**: 
1. **安全第一**: 所有敏感信息必须通过环境变量或Secrets管理，绝不在代码中硬编码
2. **定期维护**: 每月检查和更新所有Token和密钥
3. **备份策略**: 确保数据和配置都有可靠的备份方案
4. **文档更新**: 配置变更时及时更新文档
5. **团队协作**: 确保团队成员都了解配置和部署流程