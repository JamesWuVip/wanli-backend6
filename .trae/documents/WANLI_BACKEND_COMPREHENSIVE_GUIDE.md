# 万里后端项目综合技术文档

## 目录

* [1. 项目概述](#1-项目概述)

* [2. 技术架构设计](#2-技术架构设计)

* [3. 免费云服务资源选择](#3-免费云服务资源选择)

* [4. 环境配置](#4-环境配置)

* [5. CI/CD流程配置](#5-cicd流程配置)

* [6. 数据模型和API定义](#6-数据模型和api定义)

* [7. 安全架构](#7-安全架构)

* [8. 性能优化](#8-性能优化)

* [9. 监控和维护](#9-监控和维护)

* [10. 部署步骤](#10-部署步骤)

* [11. 故障排除](#11-故障排除)

* [12. 成本优化建议](#12-成本优化建议)

## 1. 项目概述

### 1.1 技术栈

* **前端**: React 18 + TypeScript + Vite + TailwindCSS

* **后端框架**: Spring Boot 3.2.x + Java 17

* **数据库**: MySQL 8.0 (Railway托管) + Redis 7.x (缓存)

* **ORM**: Spring Data JPA + Hibernate

* **认证**: Spring Security + JWT

* **构建工具**: Maven 3.9.x

* **部署平台**: Railway (主要) + Docker容器

* **版本控制**: GitHub

* **CI/CD**: GitHub Actions

* **监控**: Sentry + UptimeRobot + Spring Boot Actuator

* **代码质量**: SonarCloud + Checkstyle + SpotBugs + PMD

### 1.2 分支管理策略和部署环境

* `main`: 生产环境分支 (部署到Railway)

* `staging`: 测试环境分支 (部署到Railway)

* `dev`: 开发环境分支 (本地Tomcat运行)

* `feature/*`: 功能开发分支

* `fix/*`: 修复分支

### 1.3 部署环境说明

* **开发环境 (dev)**: 本地运行，使用内嵌Tomcat服务器，连接本地MySQL和Redis

* **测试环境 (staging)**: 部署到Railway平台，使用Railway提供的MySQL和Redis服务

* **生产环境 (production)**: 部署到Railway平台，使用Railway提供的MySQL和Redis服务

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

| 路由                    | 用途              |
| --------------------- | --------------- |
| /api/auth/login       | 用户登录接口          |
| /api/auth/register    | 用户注册接口          |
| /api/auth/refresh     | JWT令牌刷新         |
| /api/users/profile    | 用户个人资料管理        |
| /api/courses          | 课程管理接口          |
| /api/courses/{id}     | 单个课程操作          |
| /api/health           | 应用健康检查          |
| /api/actuator/health  | Spring Boot健康检查 |
| /api/actuator/info    | 应用信息接口          |
| /api/actuator/metrics | 应用指标监控          |

## 3. 免费云服务资源选择

### 3.1 核心服务

#### Railway (主要部署平台)

* **免费额度**: $5/月免费额度

* **包含服务**:

  * Web应用部署

  * MySQL数据库

  * Redis缓存

  * 自动SSL证书

  * 自定义域名

#### GitHub (代码托管和CI/CD)

* **免费额度**:

  * 无限公共仓库

  * 私有仓库 (个人账户)

  * GitHub Actions: 2000分钟/月

  * GitHub Packages: 500MB存储

### 3.2 辅助服务

#### 监控和日志

* **UptimeRobot**: 免费网站监控 (50个监控点)

* **LogRocket**: 免费日志分析 (1000会话/月)

* **Sentry**: 免费错误追踪 (5000错误/月)

#### 邮件服务

* **SendGrid**: 免费邮件发送 (100封/天)

* **Mailgun**: 免费邮件服务 (5000封/月前3个月)

#### 文件存储

* **Cloudinary**: 免费图片/视频处理 (25GB存储)

* **AWS S3**: 免费层 (5GB存储，12个月)

#### DNS和CDN

* **Cloudflare**: 免费CDN和DNS

* **Vercel**: 免费静态资源托管

## 4. 环境配置

### 4.1 本地开发环境 (dev分支)

#### 必需工具

```bash
# Java 17 (推荐使用SDKMAN管理版本)
curl -s "https://get.sdkman.io" | bash
sdk install java 17.0.8-oracle
sdk use java 17.0.8-oracle

# Maven
sdk install maven 3.9.4

# Git
brew install git  # macOS

# MySQL (本地数据库)
brew install mysql  # macOS
brew services start mysql

# Redis (本地缓存)
brew install redis  # macOS
brew services start redis

# Railway CLI (用于部署到staging/production)
npm install -g @railway/cli
```

#### 本地服务启动

```bash
# 启动Spring Boot应用 (使用内嵌Tomcat)
mvn spring-boot:run

# 或者使用IDE运行主类
# com.wanli.WanliBackendApplication
```

#### 环境变量配置

创建 `.env.example` 文件：

```env
# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=wanli_dev
DB_USERNAME=root
DB_PASSWORD=password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# 应用配置
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=dev
JWT_SECRET=dev-jwt-secret-key-change-in-production
JWT_EXPIRATION=86400000

# 邮件服务配置
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

### 4.2 Railway项目配置 (staging和production环境)

#### 创建Railway项目

```bash
# 登录Railway
railway login

# 为staging环境创建项目
railway init wanli-backend-staging

# 为production环境创建项目
railway init wanli-backend-production

# 在每个项目中添加MySQL数据库
railway add mysql

# 在每个项目中添加Redis
railway add redis
```

#### 环境变量配置

在Railway Dashboard中为不同环境配置环境变量：

**测试环境 (staging)**

```env
SPRING_PROFILES_ACTIVE=staging
SPRING_DATASOURCE_URL=jdbc:mysql://${{MySQL.MYSQL_HOST}}:${{MySQL.MYSQL_PORT}}/${{MySQL.MYSQL_DATABASE}}
SPRING_DATASOURCE_USERNAME=${{MySQL.MYSQL_USER}}
SPRING_DATASOURCE_PASSWORD=${{MySQL.MYSQL_PASSWORD}}
SPRING_DATA_REDIS_HOST=${{Redis.REDIS_HOST}}
SPRING_DATA_REDIS_PORT=${{Redis.REDIS_PORT}}
SPRING_DATA_REDIS_PASSWORD=${{Redis.REDIS_PASSWORD}}
JWT_SECRET=wanli-backend-jwt-secret-key-2024
JWT_EXPIRATION=86400000
SERVER_PORT=8080
CORS_ALLOWED_ORIGINS=https://wanli-frontend-staging.vercel.app
SPRING_MAIL_HOST=smtphz.qiye.163.com
SPRING_MAIL_PORT=465
SPRING_MAIL_USERNAME=wuning@wanli.ai
SPRING_MAIL_PASSWORD=CPyx-8vBkKhn5Fx
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

**生产环境 (main)**

```env
SPRING_PROFILES_ACTIVE=prod
SPRING_DATASOURCE_URL=jdbc:mysql://${{MySQL.MYSQL_HOST}}:${{MySQL.MYSQL_PORT}}/${{MySQL.MYSQL_DATABASE}}
SPRING_DATASOURCE_USERNAME=${{MySQL.MYSQL_USER}}
SPRING_DATASOURCE_PASSWORD=${{MySQL.MYSQL_PASSWORD}}
SPRING_DATA_REDIS_HOST=${{Redis.REDIS_HOST}}
SPRING_DATA_REDIS_PORT=${{Redis.REDIS_PORT}}
SPRING_DATA_REDIS_PASSWORD=${{Redis.REDIS_PASSWORD}}
JWT_SECRET=wanli-backend-jwt-secret-key-2024
JWT_EXPIRATION=86400000
SERVER_PORT=8080
CORS_ALLOWED_ORIGINS=https://wanli-frontend.vercel.app
SPRING_MAIL_HOST=smtphz.qiye.163.com
SPRING_MAIL_PORT=465
SPRING_MAIL_USERNAME=wuning@wanli.ai
SPRING_MAIL_PASSWORD=CPyx-8vBkKhn5Fx
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics
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
    branches: [main, staging, dev]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test_db
          MYSQL_USER: test
          MYSQL_PASSWORD: test
        options: >-
          --health-cmd "mysqladmin ping -h localhost"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 3306:3306
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Compile project
      run: mvn clean compile
    
    - name: Run code quality checks
      run: |
        mvn checkstyle:check
        mvn spotbugs:check
        mvn pmd:check
    
    - name: Run unit tests
      run: mvn test
      env:
        DATABASE_URL: mysql://test:test@localhost:3306/test_db
        REDIS_URL: redis://localhost:6379
    
    - name: Run integration tests
      run: mvn failsafe:integration-test
      env:
        DATABASE_URL: mysql://test:test@localhost:3306/test_db
        REDIS_URL: redis://localhost:6379
    
    - name: Generate test coverage
      run: mvn jacoco:report
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        file: ./target/site/jacoco/jacoco.xml

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/maven@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
    
    - name: Run CodeQL Analysis
      uses: github/codeql-action/init@v2
      with:
        languages: java
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2

  deploy-staging:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/staging' && github.event_name == 'push'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Build JAR
      run: mvn clean package -DskipTests
    
    - name: Deploy to Railway (Staging)
      uses: railway-app/railway-action@v1
      with:
        token: ${{ secrets.RAILWAY_TOKEN_STAGING }}
        service: wanli-backend-staging
    
    - name: Run database migrations
      run: |
        railway run --service wanli-backend-staging mvn flyway:migrate
      env:
        RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_STAGING }}

  deploy-production:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Build JAR
      run: mvn clean package -DskipTests
    
    - name: Deploy to Railway (Production)
      uses: railway-app/railway-action@v1
      with:
        token: ${{ secrets.RAILWAY_TOKEN_PROD }}
        service: wanli-backend-prod
    
    - name: Run database migrations
      run: |
        railway run --service wanli-backend-prod mvn flyway:migrate
      env:
        RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN_PROD }}
    
    - name: Health check
      run: |
        sleep 30
        curl -f https://wanli-backend.railway.app/health || exit 1
    
    - name: Notify deployment
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 5.2 GitHub Secrets配置

在GitHub仓库设置中添加以下Secrets：

```
# Railway部署tokens
RAILWAY_TOKEN_STAGING=your-railway-staging-token
RAILWAY_TOKEN_PROD=your-railway-production-token

# 第三方服务Token（可选）
SNYK_TOKEN=your-snyk-security-token
CODECOV_TOKEN=your-codecov-coverage-token
SLACK_WEBHOOK=your-slack-notification-webhook
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

| 参数名      | 参数类型   | 是否必需 | 描述   |
| -------- | ------ | ---- | ---- |
| email    | string | true | 用户邮箱 |
| password | string | true | 用户密码 |

响应参数:

| 参数名               | 参数类型    | 描述      |
| ----------------- | ------- | ------- |
| success           | boolean | 请求是否成功  |
| message           | string  | 响应消息    |
| data              | object  | 响应数据    |
| data.token        | string  | JWT访问令牌 |
| data.refreshToken | string  | JWT刷新令牌 |
| data.user         | object  | 用户信息    |

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

| 参数名       | 参数类型    | 是否必需  | 描述               |
| --------- | ------- | ----- | ---------------- |
| page      | integer | false | 页码，默认0           |
| size      | integer | false | 每页大小，默认10        |
| sort      | string  | false | 排序字段，默认createdAt |
| direction | string  | false | 排序方向，默认desc      |

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
4. **懒加载**: JPA关联关系懒加载

### 8.3 JVM调优

```bash
# 生产环境JVM参数
JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+HeapDumpOnOutOfMemoryError"
```

## 9. 监控和维护

### 9.1 应用监控

#### 健康检查端点

```java
// HealthController.java
@RestController
@RequestMapping("/health")
public class HealthController {
    
    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 检查数据库连接
            try (Connection connection = dataSource.getConnection()) {
                connection.createStatement().execute("SELECT 1");
                response.put("database", "connected");
            }
            
            // 检查Redis连接
            redisTemplate.opsForValue().get("health-check");
            response.put("redis", "connected");
            
            response.put("status", "healthy");
            response.put("timestamp", Instant.now().toString());
            response.put("uptime", ManagementFactory.getRuntimeMXBean().getUptime());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "unhealthy");
            response.put("timestamp", Instant.now().toString());
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
        }
    }
}
```

#### UptimeRobot配置

1. 注册UptimeRobot账户
2. 添加HTTP监控
3. 设置监控URL: `https://wanli-backend-production.up.railway.app/health`
4. 配置告警通知

### 9.2 错误追踪

#### Sentry集成

```java
// Sentry配置
@Configuration
public class SentryConfig {
    
    @Bean
    public SentryOptions sentryOptions() {
        SentryOptions options = new SentryOptions();
        options.setDsn(System.getenv("SENTRY_DSN"));
        options.setEnvironment(System.getenv("SPRING_PROFILES_ACTIVE"));
        options.setTracesSampleRate(1.0);
        return options;
    }
}
```

### 9.3 日志配置

```yaml
# logback-spring.xml配置
logging:
  level:
    com.wanli: INFO
    org.springframework.security: WARN
    org.hibernate.SQL: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/wanli-backend.log
    max-size: 100MB
    max-history: 30
```

## 10. 部署步骤

### 10.1 环境部署概览

**开发环境 (dev分支)**:

* 本地运行，使用内嵌Tomcat服务器

* 连接本地MySQL和Redis服务

* 使用 `mvn spring-boot:run` 启动

**测试环境 (staging分支)**:

* 自动部署到Railway平台

* 使用Railway提供的MySQL和Redis服务

* 通过GitHub Actions自动部署

**生产环境 (main分支)**:

* 自动部署到Railway平台

* 使用Railway提供的MySQL和Redis服务

* 通过GitHub Actions自动部署

### 10.2 初始化项目

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
brew install mysql
brew services start mysql

# 安装并启动Redis
brew install redis
brew services start redis

# 创建开发数据库
mysql -u root -p
CREATE DATABASE wanli_dev;
```

#### 步骤3: 配置Railway项目

```bash
# 登录Railway
railway login

# 为staging环境创建项目
railway init wanli-backend-staging
railway add mysql
railway add redis

# 为production环境创建项目
railway init wanli-backend-production
railway add mysql
railway add redis
```

### 10.3 应用配置文件

#### Railway配置 (railway.json)

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "java -jar target/*.jar",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

#### Docker配置 (Dockerfile)

```dockerfile
# 多阶段构建
FROM openjdk:17-jdk-slim AS builder

WORKDIR /app

# 安装Maven
RUN apt-get update && apt-get install -y maven

# 复制Maven配置文件
COPY pom.xml ./
COPY src ./src/

# 构建应用
RUN mvn clean package -DskipTests

# 生产镜像
FROM openjdk:17-jre-slim AS production

WORKDIR /app

# 创建非root用户
RUN groupadd -r spring && useradd -r -g spring spring

# 安装curl用于健康检查
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 复制JAR文件
COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar

# 切换到非root用户
USER spring

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1

# 启动应用
CMD ["java", "-jar", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:dev}", "app.jar"]
```

## 11. 故障排除

### 11.1 常见问题

#### 部署失败

```bash
# 检查Railway日志
railway logs

# 检查构建日志
railway logs --build

# 重新部署
railway up
```

#### 数据库连接问题

```bash
# 检查数据库状态
railway run mysql --version

# 检查环境变量
railway variables

# 测试数据库连接
railway run mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD
```

#### Redis连接问题

```bash
# 检查Redis状态
railway run redis-cli ping

# 检查Redis配置
railway run redis-cli config get '*'
```

### 11.2 性能问题排查

#### 内存使用过高

```bash
# 检查JVM内存使用
jstat -gc <pid>

# 生成堆转储
jmap -dump:format=b,file=heapdump.hprof <pid>

# 分析堆转储
jhat heapdump.hprof
```

#### 数据库性能问题

```sql
-- 查看慢查询
SHOW PROCESSLIST;

-- 查看表锁定情况
SHOW OPEN TABLES WHERE In_use > 0;

-- 分析查询执行计划
EXPLAIN SELECT * FROM users WHERE email = 'wuning@wanli.ai';
```

### 11.3 监控告警

#### 设置告警规则

1. **CPU使用率** > 80%
2. **内存使用率** > 85%
3. **响应时间** > 2秒
4. **错误率** > 5%
5. **数据库连接数** > 80%

## 12. 成本优化建议

### 12.1 资源优化

1. **合理配置JVM内存**: 根据实际使用情况调整堆内存大小
2. **数据库连接池优化**: 设置合适的最大连接数
3. **缓存策略**: 合理设置缓存过期时间，避免内存浪费
4. **日志级别**: 生产环境使用INFO级别，避免过多DEBUG日志

### 12.2 服务选择

1. **Railway免费额度**: 充分利用$5/月免费额度
2. **GitHub Actions**: 合理使用2000分钟/月免费额度
3. **第三方服务**: 选择有免费层的服务，如Sentry、UptimeRobot

### 12.3 监控成本

1. **定期检查**: 每月检查各服务使用情况
2. **资源清理**: 及时清理不用的资源和服务
3. **成本告警**: 设置成本告警，避免超出预算

***

**技术架构特点**:

1. 采用微服务友好的Spring Boot架构
2. 使用Railway云平台简化部署和运维
3. 集成完整的CI/CD流程
4. 实现全面的监控和日志记录
5. 遵循安全最佳实践
6. 支持水平扩展和高可用部署
7. 成本优化，充分利用免费资源
8. 完整的故障排除和维护指南

