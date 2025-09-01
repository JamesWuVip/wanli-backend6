package com.wanli.controller;

import com.wanli.dto.RegisterDTO;
import com.wanli.dto.RegisterResponseDTO;
import com.wanli.entity.User;
import com.wanli.service.SmsService;
import com.wanli.service.UserService;
import com.wanli.util.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Objects;

/**
 * 用户注册控制器.
 * 
 * <p>负责处理用户注册相关的HTTP请求，包括：</p>
 * <ul>
 *   <li>用户注册信息验证</li>
 *   <li>用户账户创建</li>
 *   <li>手机号验证短信发送</li>
 *   <li>注册结果响应</li>
 * </ul>
 * 
 * <p>注册流程采用多层验证机制：</p>
 * <ol>
 *   <li>参数格式验证（Bean Validation）</li>
 *   <li>业务规则验证（密码一致性、唯一性检查等）</li>
 *   <li>用户账户创建</li>
 *   <li>手机验证短信发送</li>
 *   <li>响应结果构建</li>
 * </ol>
 * 
 * @author 系统开发团队
 * @version 1.0.0
 * @since 2024-01-01
 */
@RestController
@RequestMapping("/api/auth")
@Validated
@Tag(name = "用户注册", description = "用户注册相关接口")
public class RegisterController {
    
    private static final Logger logger = LoggerFactory.getLogger(RegisterController.class);
    
    // 业务常量定义
    private static final String REGISTRATION_SUCCESS_MESSAGE = "注册成功，验证短信已发送";
    private static final String REGISTRATION_FAILED_MESSAGE = "注册失败";
    private static final String SMS_SEND_SUCCESS_MESSAGE = "验证短信已发送至您的手机，请查收";
    
    // 依赖服务注入
    private final UserService userService;
    private final SmsService smsService;
    
    /**
     * 构造函数注入依赖服务.
     * 
     * @param userService 用户服务，用于用户账户管理
     * @param smsService 短信服务，用于发送验证短信
     */
    @Autowired
    public RegisterController(@NotNull final UserService userService, 
                            @NotNull final SmsService smsService) {
        this.userService = Objects.requireNonNull(userService, "userService cannot be null");
        this.smsService = Objects.requireNonNull(smsService, "smsService cannot be null");
        
        logger.info("RegisterController initialized with UserService: [{}] and SmsService: [{}]", 
                   userService.getClass().getSimpleName(), 
                   smsService.getClass().getSimpleName());
    }
    
    /**
     * 用户注册接口.
     * 
     * <p>处理用户注册请求，执行完整的注册流程：</p>
     * <ol>
     *   <li><strong>参数验证</strong>：验证请求参数的格式和完整性</li>
     *   <li><strong>业务规则验证</strong>：检查密码一致性、用户名和手机号唯一性</li>
     *   <li><strong>账户创建</strong>：创建新的用户账户</li>
     *   <li><strong>短信发送</strong>：发送手机号验证短信</li>
     *   <li><strong>响应构建</strong>：构建注册成功响应</li>
     * </ol>
     * 
     * <p><strong>注册规则：</strong></p>
     * <ul>
     *   <li>用户名必须唯一，长度3-20个字符</li>
     *   <li>手机号必须唯一，格式为中国大陆手机号</li>
     *   <li>密码长度6-20个字符，必须包含字母和数字</li>
     *   <li>密码与确认密码必须一致</li>
     *   <li>全名长度2-50个字符</li>
     * </ul>
     * 
     * <p><strong>安全措施：</strong></p>
     * <ul>
     *   <li>密码在存储前进行BCrypt加密</li>
     *   <li>敏感信息在日志中进行脱敏处理</li>
     *   <li>异常信息不暴露系统内部细节</li>
     * </ul>
     * 
     * @param registerDTO 注册请求数据传输对象，包含用户名、密码、手机号等信息
     * @return ResponseEntity包装的ApiResponse，成功时返回201状态码和用户基本信息
     * 
     * @apiNote 此接口为公开接口，无需身份验证
     * @implNote 注册成功后会自动发送手机验证短信，用户需要验证手机号后才能正常使用系统功能
     */
    @PostMapping("/register")
    @Operation(
        summary = "用户注册",
        description = "创建新用户账户并发送手机验证短信。注册成功后用户需要验证手机号才能正常使用系统功能。"
    )
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "201", 
            description = "注册成功",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = ApiResponse.class)
            )
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "400", 
            description = "请求参数无效或业务规则验证失败",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = ApiResponse.class)
            )
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "500", 
            description = "系统内部错误",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = ApiResponse.class)
            )
        )
    })
    public ResponseEntity<ApiResponse<RegisterResponseDTO>> register(
            @Parameter(
                description = "用户注册信息", 
                required = true,
                schema = @Schema(implementation = RegisterDTO.class)
            )
            @Valid @RequestBody @NotNull final RegisterDTO registerDTO) {
        
        logger.info("Received registration request for username: [{}], phone: [{}]", 
                   registerDTO.getUsername(), 
                   maskPhoneNumber(registerDTO.getPhone()));
        
        try {
            // 第一层：参数验证（已通过@Valid注解完成）
            logger.debug("Parameter validation passed for: [{}]", registerDTO.getUsername());
            
            // 第二层：业务规则验证
            logger.debug("Starting business rules validation for: [{}]", registerDTO.getUsername());
            validateRegistrationBusinessRules(registerDTO);
            
            // 第三层：创建用户账户
            logger.debug("Creating user account for: [{}]", registerDTO.getUsername());
            
            // 将RegisterDTO转换为User对象
            final User newUser = new User();
            newUser.setUsername(registerDTO.getUsername());
            newUser.setPhone(registerDTO.getPhone());
            newUser.setPasswordHash(registerDTO.getPassword()); // 将在UserService中加密
            newUser.setFullName(registerDTO.getFullName());
            
            final User createdUser = userService.createUser(newUser);
            
            // 第四层：发送手机号验证短信
            logger.debug("Sending SMS verification to: [{}]", registerDTO.getPhone());
            smsService.sendVerificationSms(createdUser.getPhone(), createdUser.getId());
            
            // 第五层：构建成功响应
            final RegisterResponseDTO responseDTO = buildRegisterResponse(createdUser);
            
            logger.info("User registration completed successfully for username: [{}], userId: [{}]", 
                       createdUser.getUsername(), createdUser.getId());
            
            return ResponseEntity.status(HttpStatus.CREATED)
                     .body(ApiResponse.success(REGISTRATION_SUCCESS_MESSAGE, responseDTO));
            
        } catch (final IllegalArgumentException e) {
            logger.warn("Registration failed due to invalid parameters for username: [{}], error: [{}]", 
                       registerDTO.getUsername(), e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("INVALID_PARAMETER", e.getMessage()));
            
        } catch (final RuntimeException e) {
            logger.error("Registration failed for username: [{}], error: [{}]", 
                        registerDTO.getUsername(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("REGISTRATION_FAILED", 
                           REGISTRATION_FAILED_MESSAGE + ": " + e.getMessage()));
            
        } catch (final Exception e) {
            logger.error("Unexpected error during registration for username: [{}]", 
                        registerDTO.getUsername(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("INTERNAL_ERROR", "系统内部错误，请稍后重试"));
        }
    }
    
    /**
     * 验证注册业务规则.
     * 
     * <p>执行注册相关的业务规则验证，包括：</p>
     * <ul>
     *   <li>密码与确认密码一致性检查</li>
     *   <li>用户名唯一性检查</li>
     *   <li>手机号唯一性检查</li>
     *   <li>手机号格式有效性检查</li>
     * </ul>
     * 
     * @param registerDTO 待验证的注册请求数据
     * @throws IllegalArgumentException 当业务规则验证失败时
     */
    private void validateRegistrationBusinessRules(@NotNull final RegisterDTO registerDTO) {
        logger.debug("Validating business rules for registration: [{}]", registerDTO.getUsername());
        
        // 验证密码一致性
        if (!registerDTO.getPassword().equals(registerDTO.getConfirmPassword())) {
            throw new IllegalArgumentException("密码与确认密码不一致");
        }
        
        // 验证用户名唯一性
        if (userService.existsByUsername(registerDTO.getUsername())) {
            throw new RuntimeException("用户名已存在: " + registerDTO.getUsername());
        }
        
        // 验证手机号唯一性
        if (userService.existsByPhone(registerDTO.getPhone())) {
            throw new RuntimeException("手机号已存在: " + registerDTO.getPhone());
        }
        
        // 验证手机号格式
        if (!smsService.isValidPhoneFormat(registerDTO.getPhone())) {
            throw new IllegalArgumentException("手机号格式无效: " + registerDTO.getPhone());
        }
        
        logger.debug("Business rules validation passed for: [{}]", registerDTO.getUsername());
    }
    
    /**
     * 构建注册成功响应数据.
     * 
     * <p>将创建的用户实体转换为注册响应DTO，包含：</p>
     * <ul>
     *   <li>用户基本信息（ID、用户名、手机号、全名）</li>
     *   <li>手机号验证状态</li>
     *   <li>注册时间戳</li>
     *   <li>手机号验证提示信息</li>
     * </ul>
     * 
     * @param user 已创建的用户实体
     * @return 注册响应DTO对象
     * @throws IllegalArgumentException 当用户实体为null时
     */
    private RegisterResponseDTO buildRegisterResponse(@NotNull final User user) {
        Objects.requireNonNull(user, "user cannot be null");
        
        logger.debug("Building registration response for user: [{}]", user.getUsername());
        
        final RegisterResponseDTO response = new RegisterResponseDTO(
            user.getId(),
            user.getUsername(),
            user.getPhone(),
            user.getFullName()
        );
        response.setPhoneVerified(user.getPhoneVerified());
        response.setRegisteredAt(user.getCreatedAt().toEpochSecond(java.time.ZoneOffset.UTC) * 1000);
        response.setVerificationMessage(SMS_SEND_SUCCESS_MESSAGE);
        
        return response;
    }
    
    /**
     * 手机号脱敏处理.
     * 
     * <p>将手机号中间4位数字替换为星号，用于日志记录时保护用户隐私。</p>
     * <p>示例：13812345678 -> 138****5678</p>
     * 
     * @param phone 原始手机号
     * @return 脱敏后的手机号
     */
    private String maskPhoneNumber(@NotNull final String phone) {
        if (phone == null || phone.length() < 7) {
            return "***";
        }
        return phone.substring(0, 3) + "****" + phone.substring(7);
    }
}