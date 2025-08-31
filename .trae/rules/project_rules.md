# 万里后端项目工程实践规范

## 项目概述
本文档定义了万里后端Spring Boot项目的开发规范和最佳实践，旨在确保代码质量、团队协作效率和项目可维护性。

## 1. 命名规范

### 1.1 包命名规范
- 使用小写字母，采用反向域名结构
- 基础包：`com.wanli`
- 子包结构：
  ```
  com.wanli.entity          // 实体类
  com.wanli.dto             // 数据传输对象
  com.wanli.vo              // 视图对象
  com.wanli.controller      // 控制器
  com.wanli.service         // 服务接口
  com.wanli.service.impl    // 服务实现
  com.wanli.repository      // 数据访问层
  com.wanli.config          // 配置类
  com.wanli.exception       // 异常类
  com.wanli.util            // 工具类
  com.wanli.constant        // 常量类
  com.wanli.enums           // 枚举类
  ```

### 1.2 类命名规范
- 使用PascalCase（大驼峰命名法）
- 实体类：`User`, `Course`, `StudentClass`
- 控制器：`UserController`, `CourseController`
- 服务接口：`UserService`, `CourseService`
- 服务实现：`UserServiceImpl`, `CourseServiceImpl`
- 数据访问：`UserRepository`, `CourseRepository`
- DTO类：`UserDTO`, `CreateUserDTO`, `UpdateUserDTO`
- VO类：`UserVO`, `CourseListVO`
- 异常类：`UserNotFoundException`, `InvalidParameterException`

### 1.3 方法命名规范
- 使用camelCase（小驼峰命名法）
- 查询方法：`findById()`, `findByEmail()`, `findAllByStatus()`
- 创建方法：`create()`, `save()`, `insert()`
- 更新方法：`update()`, `modify()`, `edit()`
- 删除方法：`delete()`, `remove()`, `deleteById()`
- 验证方法：`validate()`, `check()`, `verify()`
- 转换方法：`convert()`, `transform()`, `map()`
- 业务方法：`register()`, `login()`, `enroll()`

### 1.4 变量命名规范
- 使用camelCase（小驼峰命名法）
- 布尔变量：`isActive`, `hasPermission`, `canEdit`
- 集合变量：`userList`, `courseSet`, `studentMap`
- 常量：使用UPPER_SNAKE_CASE，如`MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`

## 2. 数据库设计规范

### 2.1 表命名规范
- 使用小写字母和下划线分隔
- 使用复数形式：`users`, `courses`, `student_classes`
- 关联表：`user_courses`, `student_class_enrollments`

### 2.2 字段命名规范
- 使用小写字母和下划线分隔
- 主键统一使用：`id`
- 外键格式：`关联表名_id`，如`user_id`, `course_id`
- 时间字段：`created_at`, `updated_at`, `deleted_at`
- 操作人字段：`created_by`, `updated_by`
- 状态字段：`status`, `is_active`, `is_deleted`

### 2.3 通用字段规范
每个业务表必须包含以下通用字段：
```sql
id VARCHAR(36) PRIMARY KEY COMMENT '主键ID，使用UUID',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
created_by VARCHAR(36) COMMENT '创建者ID',
updated_by VARCHAR(36) COMMENT '更新者ID',
is_deleted TINYINT(1) DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除'
```

### 2.4 索引命名规范
- 普通索引：`idx_表名_字段名`
- 唯一索引：`uk_表名_字段名`
- 复合索引：`idx_表名_字段1_字段2`

## 3. 实体类设计规范

### 3.1 实体类结构
```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @Column(name = "id")
    private String id;
    
    @Column(name = "username", nullable = false, unique = true)
    private String username;
    
    @Column(name = "email", nullable = false, unique = true)
    private String email;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "created_by")
    private String createdBy;
    
    @Column(name = "updated_by")
    private String updatedBy;
    
    @Column(name = "is_deleted")
    private Boolean isDeleted;
}
```

### 3.2 字段映射规范
- 必须使用`@Column(name = "数据库字段名")`明确映射关系
- 数据库字段使用下划线命名，Java字段使用驼峰命名
- 时间字段统一使用`LocalDateTime`类型
- 布尔字段使用`Boolean`类型，允许null值

### 3.3 关联关系规范
```java
// 一对多关系
@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
private List<Course> courses;

// 多对一关系
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "user_id")
private User user;

// 多对多关系
@ManyToMany
@JoinTable(
    name = "user_courses",
    joinColumns = @JoinColumn(name = "user_id"),
    inverseJoinColumns = @JoinColumn(name = "course_id")
)
private Set<Course> courses;
```

## 4. API设计规范

### 4.1 RESTful API规范
- GET `/api/users` - 获取用户列表
- GET `/api/users/{id}` - 获取单个用户
- POST `/api/users` - 创建用户
- PUT `/api/users/{id}` - 完整更新用户
- PATCH `/api/users/{id}` - 部分更新用户
- DELETE `/api/users/{id}` - 删除用户

### 4.2 统一响应格式
```java
@Data
@Builder
public class ApiResponse<T> {
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;
    
    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
            .code(200)
            .message("操作成功")
            .data(data)
            .timestamp(System.currentTimeMillis())
            .build();
    }
    
    public static <T> ApiResponse<T> error(Integer code, String message) {
        return ApiResponse.<T>builder()
            .code(code)
            .message(message)
            .timestamp(System.currentTimeMillis())
            .build();
    }
}
```

### 4.3 分页响应格式
```java
@Data
@Builder
public class PageResponse<T> {
    private List<T> content;
    private Integer pageNumber;
    private Integer pageSize;
    private Long totalElements;
    private Integer totalPages;
    private Boolean first;
    private Boolean last;
}
```

## 5. 异常处理规范

### 5.1 自定义异常体系
```java
// 基础业务异常
public class BusinessException extends RuntimeException {
    private final Integer code;
    
    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }
}

// 具体业务异常
public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(String userId) {
        super(2001, "用户不存在: " + userId);
    }
}
```

### 5.2 全局异常处理
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ApiResponse<Void> handleBusinessException(BusinessException e) {
        return ApiResponse.error(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<Void> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(FieldError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        return ApiResponse.error(1001, message);
    }
}
```

### 5.3 错误码规范
- 1000-1999：系统级错误
- 2000-2999：用户相关错误
- 3000-3999：课程相关错误
- 4000-4999：权限相关错误
- 5000-5999：业务逻辑错误
- 6000-6999：数据操作错误

## 6. 服务层设计规范

### 6.1 服务接口设计
```java
public interface UserService {
    UserVO createUser(CreateUserDTO createUserDTO);
    UserVO getUserById(String userId);
    UserVO updateUser(String userId, UpdateUserDTO updateUserDTO);
    void deleteUser(String userId);
    PageResponse<UserVO> getUserList(UserQueryDTO queryDTO);
}
```

### 6.2 服务实现规范
```java
@Service
@Transactional
@Slf4j
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public UserServiceImpl(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }
    
    @Override
    public UserVO createUser(CreateUserDTO createUserDTO) {
        // 1. 参数验证
        validateCreateUserDTO(createUserDTO);
        
        // 2. 业务逻辑处理
        User user = userMapper.toEntity(createUserDTO);
        user.setId(UUID.randomUUID().toString());
        user.setCreatedAt(LocalDateTime.now());
        
        // 3. 数据持久化
        User savedUser = userRepository.save(user);
        
        // 4. 返回结果
        return userMapper.toVO(savedUser);
    }
}
```

## 7. 数据传输对象(DTO)规范

### 7.1 DTO分类
- CreateDTO：创建操作的数据传输对象
- UpdateDTO：更新操作的数据传输对象
- QueryDTO：查询操作的数据传输对象
- VO：视图对象，返回给前端的数据

### 7.2 DTO设计示例
```java
// 创建用户DTO
@Data
@Builder
public class CreateUserDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20之间")
    private String username;
    
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20之间")
    private String password;
}

// 用户查询DTO
@Data
@Builder
public class UserQueryDTO {
    private String username;
    private String email;
    private String status;
    private Integer pageNumber = 0;
    private Integer pageSize = 10;
    private String sortBy = "createdAt";
    private String sortDirection = "DESC";
}

// 用户视图对象
@Data
@Builder
public class UserVO {
    private String id;
    private String username;
    private String email;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

## 8. 数据映射规范

### 8.1 使用MapStruct进行对象映射
```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "isDeleted", constant = "false")
    User toEntity(CreateUserDTO createUserDTO);
    
    UserVO toVO(User user);
    
    List<UserVO> toVOList(List<User> users);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    void updateEntity(@MappingTarget User user, UpdateUserDTO updateUserDTO);
}
```

## 9. 配置类规范

### 9.1 配置类命名和结构
```java
@Configuration
@EnableConfigurationProperties
public class DatabaseConfig {
    
    @Bean
    @Primary
    @ConfigurationProperties("spring.datasource.primary")
    public DataSource primaryDataSource() {
        return DataSourceBuilder.create().build();
    }
}
```

### 9.2 配置属性类
```java
@Data
@ConfigurationProperties(prefix = "app.security")
@Component
public class SecurityProperties {
    private String jwtSecret;
    private Long jwtExpiration;
    private String[] allowedOrigins;
}
```

## 10. 测试规范

### 10.1 单元测试规范
```java
@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private UserMapper userMapper;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    @DisplayName("应该成功创建用户当提供有效数据时")
    void should_CreateUser_When_ValidDataProvided() {
        // Given
        CreateUserDTO createUserDTO = CreateUserDTO.builder()
            .username("testuser")
            .email("test@example.com")
            .password("password123")
            .build();
        
        User user = new User();
        UserVO expectedVO = new UserVO();
        
        when(userMapper.toEntity(createUserDTO)).thenReturn(user);
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(userMapper.toVO(user)).thenReturn(expectedVO);
        
        // When
        UserVO result = userService.createUser(createUserDTO);
        
        // Then
        assertThat(result).isEqualTo(expectedVO);
        verify(userRepository).save(any(User.class));
    }
}
```

### 10.2 集成测试规范
```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class UserControllerIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void should_CreateUser_When_ValidRequest() {
        // Given
        CreateUserDTO request = CreateUserDTO.builder()
            .username("testuser")
            .email("test@example.com")
            .password("password123")
            .build();
        
        // When
        ResponseEntity<ApiResponse> response = restTemplate.postForEntity(
            "/api/users", request, ApiResponse.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getCode()).isEqualTo(200);
    }
}
```

## 11. 日志规范

### 11.1 日志级别使用
- ERROR：系统错误、异常情况
- WARN：警告信息、潜在问题
- INFO：重要业务流程、系统启动信息
- DEBUG：调试信息、详细执行流程

### 11.2 日志格式规范
```java
@Slf4j
@Service
public class UserServiceImpl implements UserService {
    
    @Override
    public UserVO createUser(CreateUserDTO createUserDTO) {
        log.info("开始创建用户，用户名: {}", createUserDTO.getUsername());
        
        try {
            // 业务逻辑
            User savedUser = userRepository.save(user);
            log.info("用户创建成功，用户ID: {}", savedUser.getId());
            return userMapper.toVO(savedUser);
        } catch (Exception e) {
            log.error("用户创建失败，用户名: {}, 错误信息: {}", 
                createUserDTO.getUsername(), e.getMessage(), e);
            throw new BusinessException(2002, "用户创建失败");
        }
    }
}
```

## 12. 安全规范

### 12.1 密码处理
```java
@Component
public class PasswordEncoder {
    
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    
    public String encode(String rawPassword) {
        return encoder.encode(rawPassword);
    }
    
    public boolean matches(String rawPassword, String encodedPassword) {
        return encoder.matches(rawPassword, encodedPassword);
    }
}
```

### 12.2 输入验证
- 使用Bean Validation注解进行参数验证
- 对所有外部输入进行验证和清理
- 防止SQL注入、XSS攻击

### 12.3 权限控制
```java
@PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
public UserVO getUserById(String userId) {
    // 方法实现
}
```

## 13. 性能优化规范

### 13.1 数据库查询优化
- 使用合适的索引
- 避免N+1查询问题
- 使用分页查询
- 合理使用缓存

### 13.2 缓存使用规范
```java
@Service
public class UserServiceImpl implements UserService {
    
    @Cacheable(value = "users", key = "#userId")
    public UserVO getUserById(String userId) {
        // 查询逻辑
    }
    
    @CacheEvict(value = "users", key = "#userId")
    public void deleteUser(String userId) {
        // 删除逻辑
    }
}
```

## 14. 代码质量检查清单

### 14.1 提交前检查
- [ ] 代码格式化是否正确
- [ ] 是否有未使用的导入
- [ ] 方法长度是否超过50行
- [ ] 是否有重复代码
- [ ] 异常处理是否完善
- [ ] 日志记录是否合理
- [ ] 单元测试是否覆盖
- [ ] 文档注释是否完整

### 14.2 Code Review检查点
- [ ] 命名是否符合规范
- [ ] 业务逻辑是否正确
- [ ] 性能是否有问题
- [ ] 安全性是否考虑
- [ ] 可维护性是否良好
- [ ] 错误处理是否完善

## 15. 常见错误避免

### 15.1 命名相关错误
- ❌ 使用拼音命名：`yonghu`, `kecheng`
- ✅ 使用英文命名：`user`, `course`
- ❌ 缩写不明确：`usr`, `crs`
- ✅ 完整单词：`user`, `course`

### 15.2 数据库映射错误
- ❌ 忘记@Column注解导致字段映射错误
- ✅ 明确指定字段映射关系
- ❌ 实体类字段与数据库字段不一致
- ✅ 保持命名转换规则一致

### 15.3 API设计错误
- ❌ 不统一的响应格式
- ✅ 使用统一的ApiResponse包装
- ❌ 缺少参数验证
- ✅ 使用Bean Validation注解

### 15.4 异常处理错误
- ❌ 吞掉异常不处理
- ✅ 合理的异常处理和日志记录
- ❌ 直接抛出底层异常
- ✅ 转换为业务异常

---

**注意：本规范应在项目开发过程中严格遵守，定期review和更新，确保代码质量和团队协作效率。**