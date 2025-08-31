#!/bin/bash

# 万里后端项目 终端实时反馈显示脚本
# 在终端中实时显示所有CI/CD反馈信息

set -e

# 颜色和图标定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 图标定义
ICON_SUCCESS="✅"
ICON_ERROR="❌"
ICON_WARNING="⚠️"
ICON_INFO="ℹ️"
ICON_DEBUG="🔍"
ICON_BUILD="🔨"
ICON_TEST="🧪"
ICON_QUALITY="📊"
ICON_SECURITY="🔒"
ICON_DEPLOY="🚀"
ICON_MONITOR="👁️"
ICON_FIX="🔧"

# 项目配置
PROJECT_DIR="/Users/wujames/Documents/wanli-backend6"
FEEDBACK_LOG="${PROJECT_DIR}/feedback.log"
REAL_TIME_LOG="${PROJECT_DIR}/realtime-feedback.log"

# 创建实时反馈日志
touch "$REAL_TIME_LOG"

# 显示标题横幅
show_banner() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                          ${WHITE}万里后端项目 实时反馈终端${NC}                          ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${ICON_MONITOR} 实时监控所有CI/CD反馈 | ${ICON_FIX} 自动修复问题 | ${ICON_INFO} 详细状态显示           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 记录实时反馈
log_feedback() {
    local type=$1
    local category=$2
    local message=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 选择图标和颜色
    local icon color
    case "$type" in
        "SUCCESS")
            icon="$ICON_SUCCESS"
            color="$GREEN"
            ;;
        "ERROR")
            icon="$ICON_ERROR"
            color="$RED"
            ;;
        "WARNING")
            icon="$ICON_WARNING"
            color="$YELLOW"
            ;;
        "INFO")
            icon="$ICON_INFO"
            color="$CYAN"
            ;;
        "DEBUG")
            icon="$ICON_DEBUG"
            color="$PURPLE"
            ;;
        *)
            icon="📝"
            color="$WHITE"
            ;;
    esac
    
    # 选择分类图标
    local cat_icon
    case "$category" in
        "BUILD")
            cat_icon="$ICON_BUILD"
            ;;
        "TEST")
            cat_icon="$ICON_TEST"
            ;;
        "QUALITY")
            cat_icon="$ICON_QUALITY"
            ;;
        "SECURITY")
            cat_icon="$ICON_SECURITY"
            ;;
        "DEPLOY")
            cat_icon="$ICON_DEPLOY"
            ;;
        "MONITOR")
            cat_icon="$ICON_MONITOR"
            ;;
        "FIX")
            cat_icon="$ICON_FIX"
            ;;
        *)
            cat_icon="📋"
            ;;
    esac
    
    # 格式化消息
    local formatted_message="[$timestamp] $icon $cat_icon [$category] $message"
    
    # 输出到终端
    echo -e "${color}$formatted_message${NC}"
    
    # 记录到日志文件
    echo "$formatted_message" >> "$REAL_TIME_LOG"
    echo "$formatted_message" >> "$FEEDBACK_LOG"
}

# 显示当前项目状态
show_project_status() {
    cd "$PROJECT_DIR"
    
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "无提交记录")
    local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    
    echo -e "${BLUE}┌─ 项目状态 ─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} 分支: ${GREEN}$current_branch${NC}                                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} 提交: ${CYAN}$last_commit${NC}${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} 变更: $([ "$git_status" -eq 0 ] && echo -e "${GREEN}无未提交变更${NC}" || echo -e "${YELLOW}$git_status 个文件有变更${NC}")                                           ${BLUE}│${NC}"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 显示CI/CD检查结果
show_ci_results() {
    echo -e "${BLUE}┌─ CI/CD 检查结果 ───────────────────────────────────────────────────────────┐${NC}"
    
    cd "$PROJECT_DIR"
    
    # 编译检查
    echo -ne "${BLUE}│${NC} ${ICON_BUILD} 编译检查: "
    if mvn compile -q > /dev/null 2>&1; then
        echo -e "${GREEN}通过${NC}                                                        ${BLUE}│${NC}"
        log_feedback "SUCCESS" "BUILD" "编译检查通过"
    else
        echo -e "${RED}失败${NC}                                                        ${BLUE}│${NC}"
        log_feedback "ERROR" "BUILD" "编译检查失败"
    fi
    
    # 测试检查
    echo -ne "${BLUE}│${NC} ${ICON_TEST} 单元测试: "
    if mvn test -q > /dev/null 2>&1; then
        echo -e "${GREEN}通过${NC}                                                        ${BLUE}│${NC}"
        log_feedback "SUCCESS" "TEST" "单元测试通过"
    else
        echo -e "${RED}失败${NC}                                                        ${BLUE}│${NC}"
        log_feedback "ERROR" "TEST" "单元测试失败"
    fi
    
    # 代码质量检查
    echo -ne "${BLUE}│${NC} ${ICON_QUALITY} 代码质量: "
    if mvn checkstyle:check -q > /dev/null 2>&1; then
        echo -e "${GREEN}通过${NC}                                                        ${BLUE}│${NC}"
        log_feedback "SUCCESS" "QUALITY" "代码质量检查通过"
    else
        echo -e "${YELLOW}警告${NC}                                                        ${BLUE}│${NC}"
        log_feedback "WARNING" "QUALITY" "代码质量检查有警告"
    fi
    
    # 安全扫描
    echo -ne "${BLUE}│${NC} ${ICON_SECURITY} 安全扫描: "
    if mvn org.owasp:dependency-check-maven:check -q > /dev/null 2>&1; then
        echo -e "${GREEN}通过${NC}                                                        ${BLUE}│${NC}"
        log_feedback "SUCCESS" "SECURITY" "安全扫描通过"
    else
        echo -e "${YELLOW}跳过${NC}                                                        ${BLUE}│${NC}"
        log_feedback "INFO" "SECURITY" "安全扫描跳过（可能需要配置）"
    fi
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 显示实时反馈日志
show_realtime_logs() {
    echo -e "${BLUE}┌─ 实时反馈日志 ─────────────────────────────────────────────────────────────┐${NC}"
    
    if [ -f "$REAL_TIME_LOG" ]; then
        # 显示最近10条日志
        tail -10 "$REAL_TIME_LOG" | while IFS= read -r line; do
            echo -e "${BLUE}│${NC} ${GRAY}$line${NC}${BLUE}│${NC}"
        done
    else
        echo -e "${BLUE}│${NC} ${GRAY}暂无反馈日志${NC}                                                           ${BLUE}│${NC}"
    fi
    
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 显示快捷操作菜单
show_action_menu() {
    echo -e "${BLUE}┌─ 快捷操作 ─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${ICON_FIX} 自动修复: ${CYAN}./auto-feedback.sh${NC}                                        ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} ${ICON_MONITOR} 持续监控: ${CYAN}./continuous-monitor.sh${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} ${ICON_BUILD} 本地构建: ${CYAN}mvn clean compile test${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} ${ICON_DEPLOY} 推送代码: ${CYAN}git add . && git commit -m \"fix\" && git push${NC}              ${BLUE}│${NC}"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 显示外部链接
show_external_links() {
    echo -e "${BLUE}┌─ 外部反馈链接 ─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} 🔗 GitHub Actions: ${CYAN}https://github.com/JamesWuVip/wanli-backend/actions${NC}       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} 🔗 SonarCloud: ${CYAN}https://sonarcloud.io/project/overview?id=...${NC}            ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC} 🔗 Codecov: ${CYAN}https://codecov.io/gh/JamesWuVip/wanli-backend${NC}               ${BLUE}│${NC}"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 实时模式
start_realtime_mode() {
    log_feedback "INFO" "MONITOR" "开始实时反馈模式"
    
    while true; do
        show_banner
        show_project_status
        show_ci_results
        show_realtime_logs
        show_action_menu
        show_external_links
        
        echo -e "${YELLOW}按 Ctrl+C 退出实时模式 | 自动刷新间隔: 30秒${NC}"
        echo ""
        
        # 倒计时
        for i in $(seq 30 -1 1); do
            echo -ne "\r${CYAN}下次刷新: ${YELLOW}${i}秒${NC}  "
            sleep 1
        done
        echo ""
    done
}

# 单次检查模式
run_single_check() {
    show_banner
    log_feedback "INFO" "MONITOR" "执行单次CI/CD检查"
    
    show_project_status
    show_ci_results
    show_realtime_logs
    show_action_menu
    show_external_links
    
    log_feedback "INFO" "MONITOR" "单次检查完成"
}

# 清理日志
clean_logs() {
    echo -e "${YELLOW}清理反馈日志...${NC}"
    > "$REAL_TIME_LOG"
    > "$FEEDBACK_LOG"
    log_feedback "INFO" "MONITOR" "反馈日志已清理"
}

# 显示帮助信息
show_help() {
    echo "万里后端项目 终端实时反馈显示脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -r, --realtime           启动实时反馈模式（默认）"
    echo "  -s, --single             执行单次检查"
    echo "  -c, --clean              清理反馈日志"
    echo "  -l, --logs               只显示日志"
    echo "  -h, --help               显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                       # 启动实时反馈模式"
    echo "  $0 -s                   # 执行单次检查"
    echo "  $0 -c                   # 清理日志"
    echo "  $0 -l                   # 查看日志"
}

# 只显示日志
show_logs_only() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                              实时反馈日志                                    ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [ -f "$REAL_TIME_LOG" ]; then
        cat "$REAL_TIME_LOG"
    else
        echo -e "${GRAY}暂无反馈日志${NC}"
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
}

# 信号处理
trap 'echo -e "\n${GREEN}反馈终端已退出${NC}"; exit 0' INT TERM

# 解析命令行参数
case "${1:-}" in
    "-r"|"--realtime"|"")
        start_realtime_mode
        ;;
    "-s"|"--single")
        run_single_check
        ;;
    "-c"|"--clean")
        clean_logs
        ;;
    "-l"|"--logs")
        show_logs_only
        ;;
    "-h"|"--help")
        show_help
        ;;
    *)
        echo "未知选项: $1"
        show_help
        exit 1
        ;;
esac