# 万里后端管理系统

## 项目简介
万里后端管理系统是一个基于Spring Boot的企业级后端管理平台，提供完整的用户管理、权限控制、数据管理等功能。

## 技术栈
- 框架: Spring Boot 3.2.0
- 数据库: PostgreSQL 15+
- 缓存: Redis
- 构建工具: Maven 3.6+
- Java版本: JDK 17+
- ORM: Spring Data JPA
- 安全: Spring Security
- 文档: Spring Doc OpenAPI

## SP1 功能实现状态

### ✅ 已完成功能
1. **用户注册功能**
   - 手机号注册
   - 短信验证码验证
   - 用户信息存储

2. **用户登录功能**
   - 手机号登录
   - JWT令牌认证
   - 安全会话管理

3. **用户信息管理**
   - 用户信息查询
   - 用户信息更新
   - 用户状态管理

4. **手机号验证**
   - 短信验证码发送
   - 验证码验证
   - 防刷机制

5. **系统健康检查**
   - 数据库连接检查
   - Redis连接检查
   - 系统性能监控

### 🧪 测试覆盖
- 单元测试: 98个测试全部通过
- 集成测试: 完整覆盖
- API测试: 全面验证

## 快速开始

### 环境要求
- JDK 17 或更高版本
- Maven 3.6 或更高版本
- PostgreSQL 15 或更高版本
- Redis 6.0 或更高版本（生产环境）

### 运行项目
```bash
# 克隆项目
git clone https://github.com/JamesWuVip/wanli-backend6.git
cd wanli-backend6

# 编译项目
mvn clean compile

# 运行测试
mvn test

# 启动应用
mvn spring-boot:run
```

### 访问应用
- 应用地址: http://localhost:8080/api
- 健康检查: http://localhost:8080/api/health
- API文档: http://localhost:8080/api/swagger-ui.html

## 开发规范

### Git工作流
- main: 生产环境分支
- staging: 测试环境分支
- dev: 开发环境分支
- feature/*: 功能开发分支

### 提交规范
```
feat(scope): 添加新功能
fix(scope): 修复问题
docs(scope): 更新文档
style(scope): 代码格式调整
refactor(scope): 代码重构
test(scope): 添加测试
```

## 项目结构
```
wanli-backend6/
├── src/
│   ├── main/
│   │   ├── java/com/wanli/
│   │   │   ├── controller/     # 控制器层
│   │   │   ├── service/        # 服务层
│   │   │   ├── repository/     # 数据访问层
│   │   │   ├── entity/         # 实体类
│   │   │   ├── dto/            # 数据传输对象
│   │   │   ├── config/         # 配置类
│   │   │   └── util/           # 工具类
│   │   └── resources/
│   └── test/                   # 测试代码
├── config/                     # 环境配置
├── docs/                       # 项目文档
└── monitoring/                 # 监控配置
```

## 联系方式
- 项目维护者: JamesWuVip
- 项目地址: https://github.com/JamesWuVip/wanli-backend6

---

**注意**: 本项目遵循gitflow工作流规范，请在开发时严格按照分支管理策略进行操作。