#!/bin/bash

# 万里后端项目 CI/CD 持续监控脚本
# 实时监控CI/CD状态，自动触发反馈和修复

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 项目配置
REPO_OWNER="JamesWuVip"
REPO_NAME="wanli-backend"
PROJECT_DIR="/Users/wujames/Documents/wanli-backend6"
MONITOR_INTERVAL=30  # 监控间隔（秒）

# 状态文件
STATUS_FILE="${PROJECT_DIR}/.ci-status"
LAST_RUN_FILE="${PROJECT_DIR}/.last-run-id"
MONITOR_LOG="${PROJECT_DIR}/monitor.log"

# 监控状态
MONITORING=true
AUTO_FIX=true
NOTIFICATION=true

# 记录监控日志
log_monitor() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$MONITOR_LOG"
    
    case "$level" in
        "SUCCESS")
            echo -e "${GREEN}✅ [$timestamp]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}❌ [$timestamp]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  [$timestamp]${NC} $message"
            ;;
        "INFO")
            echo -e "${CYAN}ℹ️  [$timestamp]${NC} $message"
            ;;
        "DEBUG")
            echo -e "${PURPLE}🔍 [$timestamp]${NC} $message"
            ;;
        *)
            echo -e "${WHITE}📝 [$timestamp]${NC} $message"
            ;;
    esac
}

# 显示监控状态面板
show_status_panel() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                    ${WHITE}万里后端 CI/CD 实时监控${NC}                    ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} 项目: ${CYAN}$REPO_NAME${NC}                                           ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 监控间隔: ${YELLOW}${MONITOR_INTERVAL}秒${NC}                                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 自动修复: $([ "$AUTO_FIX" = true ] && echo -e "${GREEN}启用${NC}" || echo -e "${RED}禁用${NC}")                                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 通知提醒: $([ "$NOTIFICATION" = true ] && echo -e "${GREEN}启用${NC}" || echo -e "${RED}禁用${NC}")                                        ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    # 显示当前分支状态
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "无提交记录")
    
    echo -e "${BLUE}║${NC} 当前分支: ${GREEN}$current_branch${NC}                                     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 最新提交: ${CYAN}$last_commit${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    # 显示CI/CD状态
    if [ -f "$STATUS_FILE" ]; then
        local status_info=$(cat "$STATUS_FILE")
        echo -e "${BLUE}║${NC} CI/CD状态: $status_info                                    ${BLUE}║${NC}"
    else
        echo -e "${BLUE}║${NC} CI/CD状态: ${YELLOW}等待检查...${NC}                                   ${BLUE}║${NC}"
    fi
    
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} 快捷链接:                                                   ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} • GitHub Actions: ${CYAN}https://github.com/$REPO_OWNER/$REPO_NAME/actions${NC}  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} • SonarCloud: ${CYAN}https://sonarcloud.io/project/overview?id=...${NC}      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} • Codecov: ${CYAN}https://codecov.io/gh/$REPO_OWNER/$REPO_NAME${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}按 Ctrl+C 停止监控${NC}"
    echo ""
}

# 检查本地代码状态
check_local_status() {
    cd "$PROJECT_DIR"
    
    # 检查是否有未提交的更改
    if ! git diff --quiet; then
        log_monitor "WARNING" "检测到未提交的本地更改"
        return 1
    fi
    
    # 检查是否有未推送的提交
    local unpushed=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
    if [ "$unpushed" -gt 0 ]; then
        log_monitor "WARNING" "有 $unpushed 个未推送的提交"
        return 1
    fi
    
    return 0
}

# 模拟检查CI/CD状态（由于无法直接访问GitHub API）
check_ci_status() {
    local branch=${1:-"dev"}
    
    # 检查本地构建状态
    cd "$PROJECT_DIR"
    
    log_monitor "INFO" "检查本地构建状态..."
    
    # 编译检查
    if mvn compile -q > /dev/null 2>&1; then
        log_monitor "SUCCESS" "编译检查通过"
        echo "${GREEN}编译: 通过${NC}" > "$STATUS_FILE"
    else
        log_monitor "ERROR" "编译检查失败"
        echo "${RED}编译: 失败${NC}" > "$STATUS_FILE"
        
        if [ "$AUTO_FIX" = true ]; then
            log_monitor "INFO" "自动触发编译错误修复..."
            ./auto-feedback.sh compile
        fi
        return 1
    fi
    
    # 测试检查
    if mvn test -q > /dev/null 2>&1; then
        log_monitor "SUCCESS" "测试检查通过"
        echo "${GREEN}编译: 通过${NC} | ${GREEN}测试: 通过${NC}" > "$STATUS_FILE"
    else
        log_monitor "ERROR" "测试检查失败"
        echo "${GREEN}编译: 通过${NC} | ${RED}测试: 失败${NC}" > "$STATUS_FILE"
        
        if [ "$AUTO_FIX" = true ]; then
            log_monitor "INFO" "自动触发测试失败修复..."
            ./auto-feedback.sh test
        fi
        return 1
    fi
    
    # 代码质量检查
    if mvn checkstyle:check -q > /dev/null 2>&1; then
        log_monitor "SUCCESS" "代码质量检查通过"
        echo "${GREEN}编译: 通过${NC} | ${GREEN}测试: 通过${NC} | ${GREEN}质量: 通过${NC}" > "$STATUS_FILE"
    else
        log_monitor "WARNING" "代码质量检查有问题"
        echo "${GREEN}编译: 通过${NC} | ${GREEN}测试: 通过${NC} | ${YELLOW}质量: 警告${NC}" > "$STATUS_FILE"
        
        if [ "$AUTO_FIX" = true ]; then
            log_monitor "INFO" "自动触发代码质量修复..."
            ./auto-feedback.sh quality
        fi
    fi
    
    return 0
}

# 发送通知
send_notification() {
    local type=$1
    local message=$2
    
    if [ "$NOTIFICATION" = true ]; then
        # macOS 通知
        if command -v osascript > /dev/null; then
            osascript -e "display notification \"$message\" with title \"万里后端 CI/CD\" subtitle \"$type\""
        fi
        
        # 终端铃声
        echo -e "\a"
    fi
}

# 主监控循环
start_monitoring() {
    log_monitor "INFO" "开始持续监控 CI/CD 状态..."
    
    # 设置信号处理
    trap 'stop_monitoring' INT TERM
    
    while [ "$MONITORING" = true ]; do
        show_status_panel
        
        # 检查本地状态
        if check_local_status; then
            log_monitor "DEBUG" "本地代码状态正常"
        fi
        
        # 检查CI/CD状态
        if check_ci_status; then
            log_monitor "SUCCESS" "CI/CD 检查全部通过"
            send_notification "成功" "所有检查都通过了！"
        else
            log_monitor "ERROR" "CI/CD 检查发现问题"
            send_notification "失败" "发现问题，正在自动修复..."
        fi
        
        # 等待下次检查
        for i in $(seq $MONITOR_INTERVAL -1 1); do
            if [ "$MONITORING" = false ]; then
                break
            fi
            echo -ne "\r${CYAN}下次检查倒计时: ${YELLOW}${i}秒${NC}  "
            sleep 1
        done
        echo ""
    done
}

# 停止监控
stop_monitoring() {
    MONITORING=false
    log_monitor "INFO" "停止 CI/CD 监控"
    echo -e "\n${GREEN}监控已停止${NC}"
    exit 0
}

# 显示帮助信息
show_help() {
    echo "万里后端项目 CI/CD 持续监控脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -i, --interval SECONDS    设置监控间隔（默认: 30秒）"
    echo "  -n, --no-autofix         禁用自动修复"
    echo "  -s, --silent             禁用通知提醒"
    echo "  -o, --once               只检查一次，不持续监控"
    echo "  -h, --help               显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                       # 开始持续监控"
    echo "  $0 -i 60                # 每60秒检查一次"
    echo "  $0 -n                   # 禁用自动修复"
    echo "  $0 -o                   # 只检查一次"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            MONITOR_INTERVAL="$2"
            shift 2
            ;;
        -n|--no-autofix)
            AUTO_FIX=false
            shift
            ;;
        -s|--silent)
            NOTIFICATION=false
            shift
            ;;
        -o|--once)
            MONITORING=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 创建必要的目录和文件
mkdir -p "$(dirname "$MONITOR_LOG")"
touch "$MONITOR_LOG"

# 开始监控
if [ "$MONITORING" = true ]; then
    start_monitoring
else
    # 单次检查模式
    show_status_panel
    check_local_status
    check_ci_status
    log_monitor "INFO" "单次检查完成"
fi