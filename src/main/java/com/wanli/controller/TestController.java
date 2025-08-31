package com.wanli.controller;

import io.sentry.Sentry;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 测试控制器
 * 用于测试各种功能，包括Sentry错误报告
 */
@RestController
@RequestMapping("/test")
public class TestController {

    /**
     * 健康检查端点
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", System.currentTimeMillis());
        response.put("service", "wanli-backend");
        return ResponseEntity.ok(response);
    }

    /**
     * 测试Sentry错误报告
     */
    @GetMapping("/sentry-error")
    public ResponseEntity<Map<String, Object>> testSentryError() {
        try {
            // 故意抛出一个异常来测试Sentry
            throw new RuntimeException("这是一个测试异常，用于验证Sentry集成是否正常工作");
        } catch (Exception e) {
            // 手动发送异常到Sentry
            Sentry.captureException(e);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "异常已发送到Sentry");
            response.put("error", e.getMessage());
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 测试Sentry消息报告
     */
    @GetMapping("/sentry-message")
    public ResponseEntity<Map<String, Object>> testSentryMessage() {
        // 发送一个信息消息到Sentry
        Sentry.captureMessage("测试消息：Sentry集成正常工作");
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "测试消息已发送到Sentry");
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    /**
     * 获取监控配置信息
     */
    @GetMapping("/monitoring-info")
    public ResponseEntity<Map<String, Object>> getMonitoringInfo() {
        Map<String, Object> response = new HashMap<>();
        
        // 检查环境变量
        String sentryDsn = System.getenv("SENTRY_DSN");
        String codecovToken = System.getenv("CODECOV_TOKEN");
        
        response.put("sentry_configured", sentryDsn != null && !sentryDsn.isEmpty());
        response.put("codecov_configured", codecovToken != null && !codecovToken.isEmpty());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }
}