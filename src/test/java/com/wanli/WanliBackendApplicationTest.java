package com.wanli;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 应用程序启动测试类
 * 
 * @author wanli-team
 * @since 1.0.0
 */
@SpringBootTest
@ActiveProfiles("test")
class WanliBackendApplicationTest {

    /**
     * 测试应用程序上下文加载
     */
    @Test
    void contextLoads() {
        // 测试Spring Boot应用程序能够正常启动
    }

}