#!/bin/bash

# 万里后端项目 CI/CD 自动化反馈脚本
# 根据CI/CD结果自动启动调试或优化

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目配置
REPO_OWNER="JamesWuVip"
REPO_NAME="wanli-backend"
PROJECT_DIR="/Users/wujames/Documents/wanli-backend6"

# 日志文件
LOG_FILE="${PROJECT_DIR}/ci-feedback.log"
ERROR_LOG="${PROJECT_DIR}/ci-errors.log"

# 记录日志
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    echo -e "${CYAN}[$timestamp]${NC} ${message}"
}

# 错误处理
handle_error() {
    local error_type=$1
    local error_message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [ERROR] $error_type: $error_message" >> "$ERROR_LOG"
    log_message "ERROR" "$error_type: $error_message"
}

# 编译错误自动修复
fix_compilation_errors() {
    log_message "INFO" "🔧 开始自动修复编译错误..."
    
    cd "$PROJECT_DIR"
    
    # 清理并重新编译
    log_message "INFO" "清理项目缓存..."
    mvn clean > /dev/null 2>&1 || true
    
    # 检查依赖
    log_message "INFO" "检查Maven依赖..."
    if ! mvn dependency:resolve > /dev/null 2>&1; then
        handle_error "DEPENDENCY" "Maven依赖解析失败"
        log_message "INFO" "尝试强制更新依赖..."
        mvn dependency:resolve -U > /dev/null 2>&1 || true
    fi
    
    # 尝试编译
    log_message "INFO" "尝试重新编译..."
    if mvn compile > compile.log 2>&1; then
        log_message "SUCCESS" "✅ 编译成功修复"
        rm -f compile.log
        return 0
    else
        handle_error "COMPILE" "编译仍然失败，请检查代码语法"
        log_message "INFO" "编译错误详情已保存到 compile.log"
        return 1
    fi
}

# 测试失败自动处理
fix_test_failures() {
    log_message "INFO" "🧪 开始处理测试失败..."
    
    cd "$PROJECT_DIR"
    
    # 运行测试并生成详细报告
    log_message "INFO" "运行测试套件..."
    if mvn test -Dmaven.test.failure.ignore=true > test.log 2>&1; then
        # 分析测试结果
        local failed_tests=$(grep -c "FAILURE" test.log || echo "0")
        local error_tests=$(grep -c "ERROR" test.log || echo "0")
        
        if [ "$failed_tests" -gt 0 ] || [ "$error_tests" -gt 0 ]; then
            handle_error "TEST" "发现 $failed_tests 个失败测试和 $error_tests 个错误测试"
            log_message "INFO" "测试详情已保存到 test.log"
            
            # 提取失败的测试类
            log_message "INFO" "分析失败的测试..."
            grep "FAILURE\|ERROR" test.log | head -10 >> "$ERROR_LOG"
            
            return 1
        else
            log_message "SUCCESS" "✅ 所有测试通过"
            rm -f test.log
            return 0
        fi
    else
        handle_error "TEST" "测试执行失败"
        return 1
    fi
}

# 代码质量问题自动处理
fix_quality_issues() {
    log_message "INFO" "📊 开始处理代码质量问题..."
    
    cd "$PROJECT_DIR"
    
    # 运行代码格式化
    log_message "INFO" "自动格式化代码..."
    if command -v mvn > /dev/null; then
        # 使用Maven插件格式化代码
        mvn spotless:apply > /dev/null 2>&1 || true
        mvn fmt:format > /dev/null 2>&1 || true
    fi
    
    # 检查代码风格
    log_message "INFO" "检查代码风格..."
    mvn checkstyle:check > checkstyle.log 2>&1 || true
    
    if grep -q "violation" checkstyle.log; then
        handle_error "STYLE" "发现代码风格问题"
        log_message "INFO" "代码风格检查结果已保存到 checkstyle.log"
    else
        log_message "SUCCESS" "✅ 代码风格检查通过"
        rm -f checkstyle.log
    fi
}

# 安全漏洞自动处理
fix_security_issues() {
    log_message "INFO" "🔒 开始处理安全漏洞..."
    
    cd "$PROJECT_DIR"
    
    # 更新依赖到最新安全版本
    log_message "INFO" "检查依赖安全漏洞..."
    if mvn org.owasp:dependency-check-maven:check > security.log 2>&1; then
        if grep -q "vulnerability" security.log; then
            handle_error "SECURITY" "发现安全漏洞"
            log_message "INFO" "安全扫描结果已保存到 security.log"
            
            # 尝试更新依赖
            log_message "INFO" "尝试更新依赖版本..."
            mvn versions:use-latest-releases > /dev/null 2>&1 || true
        else
            log_message "SUCCESS" "✅ 未发现安全漏洞"
            rm -f security.log
        fi
    else
        handle_error "SECURITY" "安全扫描执行失败"
    fi
}

# 部署失败自动处理
fix_deployment_issues() {
    log_message "INFO" "🚀 开始处理部署问题..."
    
    cd "$PROJECT_DIR"
    
    # 检查应用配置
    log_message "INFO" "检查应用配置文件..."
    
    local config_files=("application.yml" "application-dev.yml" "application-staging.yml" "application-prod.yml")
    
    for config_file in "${config_files[@]}"; do
        if [ -f "src/main/resources/$config_file" ]; then
            log_message "INFO" "✅ 找到配置文件: $config_file"
        else
            handle_error "CONFIG" "缺少配置文件: $config_file"
        fi
    done
    
    # 检查环境变量
    log_message "INFO" "检查环境变量配置..."
    if [ -f ".env" ]; then
        log_message "INFO" "✅ 找到环境变量文件"
    else
        handle_error "CONFIG" "缺少 .env 文件"
    fi
    
    # 验证应用能否启动
    log_message "INFO" "验证应用启动配置..."
    if mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev --server.port=0" > startup.log 2>&1 &
    then
        local pid=$!
        sleep 10
        if kill -0 $pid 2>/dev/null; then
            log_message "SUCCESS" "✅ 应用启动配置正常"
            kill $pid 2>/dev/null || true
            rm -f startup.log
        else
            handle_error "STARTUP" "应用启动失败"
            log_message "INFO" "启动日志已保存到 startup.log"
        fi
    fi
}

# 生成修复报告
generate_fix_report() {
    local report_file="${PROJECT_DIR}/ci-fix-report.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$report_file" << EOF
# CI/CD 自动修复报告

**生成时间**: $timestamp
**项目**: $REPO_NAME
**分支**: $(git branch --show-current 2>/dev/null || echo "unknown")

## 修复摘要

### 执行的修复操作

EOF
    
    if [ -f "$LOG_FILE" ]; then
        echo "### 修复日志" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        tail -20 "$LOG_FILE" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    if [ -f "$ERROR_LOG" ]; then
        echo "### 发现的问题" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        tail -10 "$ERROR_LOG" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF
## 建议的后续操作

1. 检查修复日志中的所有问题
2. 运行本地测试验证修复效果
3. 提交修复后的代码
4. 重新触发CI/CD流水线

## 有用的命令

\`\`\`bash
# 本地验证
mvn clean compile test

# 检查代码质量
mvn checkstyle:check spotbugs:check

# 安全扫描
mvn org.owasp:dependency-check-maven:check

# 重新监控CI/CD
./monitor-ci-status.sh -m
\`\`\`
EOF
    
    log_message "INFO" "📋 修复报告已生成: $report_file"
}

# 主要修复流程
main_fix_process() {
    local fix_type=${1:-"all"}
    
    log_message "INFO" "🚀 开始CI/CD自动修复流程..."
    
    case "$fix_type" in
        "compile")
            fix_compilation_errors
            ;;
        "test")
            fix_test_failures
            ;;
        "quality")
            fix_quality_issues
            ;;
        "security")
            fix_security_issues
            ;;
        "deploy")
            fix_deployment_issues
            ;;
        "all")
            log_message "INFO" "执行完整的自动修复流程..."
            fix_compilation_errors
            fix_test_failures
            fix_quality_issues
            fix_security_issues
            fix_deployment_issues
            ;;
        *)
            log_message "ERROR" "未知的修复类型: $fix_type"
            exit 1
            ;;
    esac
    
    generate_fix_report
    log_message "INFO" "✅ 自动修复流程完成"
}

# 显示帮助信息
show_help() {
    echo "万里后端项目 CI/CD 自动化反馈脚本"
    echo ""
    echo "用法: $0 [修复类型]"
    echo ""
    echo "修复类型:"
    echo "  compile   - 修复编译错误"
    echo "  test      - 处理测试失败"
    echo "  quality   - 修复代码质量问题"
    echo "  security  - 处理安全漏洞"
    echo "  deploy    - 修复部署问题"
    echo "  all       - 执行所有修复 (默认)"
    echo ""
    echo "示例:"
    echo "  $0              # 执行所有自动修复"
    echo "  $0 compile      # 只修复编译错误"
    echo "  $0 test         # 只处理测试问题"
}

# 解析命令行参数
case "${1:-}" in
    "-h"|"--help")
        show_help
        exit 0
        ;;
    "")
        main_fix_process "all"
        ;;
    *)
        main_fix_process "$1"
        ;;
esac