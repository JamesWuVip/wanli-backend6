#!/bin/bash

# 万里后端项目 CI/CD 状态监控脚本
# 用于实时监控 GitHub Actions 工作流状态

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
GITHUB_REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
ACTIONS_URL="${GITHUB_REPO_URL}/actions"

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -o, --once     单次检查状态"
    echo "  -m, --monitor  持续监控模式 (默认30秒间隔)"
    echo "  -i, --interval 设置监控间隔 (秒)"
    echo "  -b, --branch   指定分支 (默认当前分支)"
    echo "  -v, --verbose  详细输出模式"
    echo ""
    echo "示例:"
    echo "  $0 -o                    # 单次检查"
    echo "  $0 -m                    # 持续监控"
    echo "  $0 -m -i 60             # 每60秒监控一次"
    echo "  $0 -b dev -v            # 监控dev分支，详细输出"
}

# 显示标题
show_header() {
    clear
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${CYAN}🚀 万里后端项目 CI/CD 状态监控${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo ""
    echo -e "${BLUE}📊 项目信息:${NC}"
    echo -e "  仓库: ${GITHUB_REPO_URL}"
    echo -e "  分支: ${YELLOW}${CURRENT_BRANCH}${NC}"
    echo -e "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# 显示CI/CD状态检查指南
show_status_guide() {
    echo -e "${PURPLE}🔍 CI/CD 状态检查指南:${NC}"
    echo ""
    echo -e "${GREEN}✅ 自动化测试检查项:${NC}"
    echo -e "  • 单元测试执行状态"
    echo -e "  • 集成测试执行状态"
    echo -e "  • 测试覆盖率报告"
    echo ""
    echo -e "${GREEN}✅ 代码质量检查项:${NC}"
    echo -e "  • SonarCloud 代码质量分析"
    echo -e "  • OWASP 安全漏洞扫描"
    echo -e "  • 代码风格检查"
    echo ""
    echo -e "${GREEN}✅ 部署状态检查项:${NC}"
    echo -e "  • 开发环境部署 (dev 分支)"
    echo -e "  • 测试环境部署 (staging 分支)"
    echo -e "  • 生产环境部署 (main 分支)"
    echo ""
}

# 显示实时反馈链接
show_feedback_links() {
    echo -e "${YELLOW}🔗 实时反馈链接:${NC}"
    echo ""
    echo -e "  ${BLUE}GitHub Actions:${NC} ${ACTIONS_URL}"
    echo -e "  ${BLUE}工作流运行:${NC} ${ACTIONS_URL}/workflows/ci-cd.yml"
    echo -e "  ${BLUE}SonarCloud:${NC} https://sonarcloud.io/project/overview?id=${REPO_OWNER}_${REPO_NAME}"
    echo -e "  ${BLUE}Codecov:${NC} https://codecov.io/gh/${REPO_OWNER}/${REPO_NAME}"
    echo ""
}

# 显示监控提示
show_monitoring_tips() {
    echo -e "${CYAN}💡 监控提示:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} 打开上述链接查看详细的CI/CD状态"
    echo -e "  ${GREEN}2.${NC} 绿色✅表示成功，红色❌表示失败，黄色🟡表示进行中"
    echo -e "  ${GREEN}3.${NC} 如果发现失败，点击具体作业查看错误日志"
    echo -e "  ${GREEN}4.${NC} 所有测试和质量检查必须通过才能合并代码"
    echo ""
}

# 显示当前状态
show_current_status() {
    echo -e "${PURPLE}📋 当前状态概览:${NC}"
    echo ""
    
    # 检查最近的提交
    LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cr)" 2>/dev/null || echo "无法获取提交信息")
    echo -e "  ${BLUE}最近提交:${NC} ${LAST_COMMIT}"
    
    # 检查工作目录状态
    if git diff --quiet 2>/dev/null; then
        echo -e "  ${GREEN}工作目录:${NC} 干净 ✅"
    else
        echo -e "  ${YELLOW}工作目录:${NC} 有未提交的更改 🟡"
    fi
    
    # 检查是否有未推送的提交
    UNPUSHED=$(git log origin/${CURRENT_BRANCH}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNPUSHED" -eq 0 ]; then
        echo -e "  ${GREEN}推送状态:${NC} 已同步 ✅"
    else
        echo -e "  ${YELLOW}推送状态:${NC} 有 ${UNPUSHED} 个未推送的提交 🟡"
    fi
    
    echo ""
}

# 显示自动化调试提示
show_debug_tips() {
    echo -e "${RED}🔧 自动化调试提示:${NC}"
    echo ""
    echo -e "  ${YELLOW}如果CI/CD失败，请检查:${NC}"
    echo -e "  • 编译错误: 检查代码语法和依赖"
    echo -e "  • 测试失败: 运行本地测试并修复"
    echo -e "  • 质量检查: 查看SonarCloud报告"
    echo -e "  • 部署失败: 检查环境配置和密钥"
    echo ""
    echo -e "  ${GREEN}本地调试命令:${NC}"
    echo -e "  • mvn clean compile    # 检查编译"
    echo -e "  • mvn test            # 运行测试"
    echo -e "  • mvn verify          # 完整验证"
    echo ""
}

# 主要监控函数
monitor_status() {
    local interval=${1:-30}
    local verbose=${2:-false}
    
    while true; do
        show_header
        
        if [ "$verbose" = true ]; then
            show_status_guide
        fi
        
        show_current_status
        show_feedback_links
        
        if [ "$verbose" = true ]; then
            show_monitoring_tips
            show_debug_tips
        fi
        
        echo -e "${CYAN}⏰ 下次更新: ${interval}秒后 (按 Ctrl+C 退出)${NC}"
        echo ""
        
        sleep $interval
    done
}

# 单次检查
check_once() {
    local verbose=${1:-false}
    
    show_header
    
    if [ "$verbose" = true ]; then
        show_status_guide
    fi
    
    show_current_status
    show_feedback_links
    
    if [ "$verbose" = true ]; then
        show_monitoring_tips
        show_debug_tips
    fi
}

# 解析命令行参数
INTERVAL=30
MODE="once"
VERBOSE=false
BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--once)
            MODE="once"
            shift
            ;;
        -m|--monitor)
            MODE="monitor"
            shift
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            CURRENT_BRANCH="$BRANCH"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 执行相应的模式
case $MODE in
    "once")
        check_once $VERBOSE
        ;;
    "monitor")
        monitor_status $INTERVAL $VERBOSE
        ;;
    *)
        echo "未知模式: $MODE"
        show_help
        exit 1
        ;;
esac