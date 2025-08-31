package com.wanli.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web配置类
 * 用于配置Web相关设置
 * 
 * @author wanli-team
 * @since 1.0.0
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    // CORS配置已移至SecurityConfig中统一管理

}