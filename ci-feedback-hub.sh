#!/bin/bash

# 万里后端项目 CI/CD 反馈中心
# 集成所有CI/CD反馈和自动化功能的统一入口

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
PROJECT_DIR="/Users/wujames/Documents/wanli-backend6"
REPO_OWNER="JamesWuVip"
REPO_NAME="wanli-backend"

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${WHITE}万里后端 CI/CD 反馈中心${NC}                        ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}                   ${CYAN}满足您的所有CI/CD反馈需求${NC}                   ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}请选择功能:${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} 🖥️  ${CYAN}实时反馈终端${NC}     - 在终端中实时显示所有CI/CD反馈"
    echo -e "${GREEN}2.${NC} 👁️  ${CYAN}持续监控模式${NC}     - 自动监控CI/CD状态并触发修复"
    echo -e "${GREEN}3.${NC} 🔧 ${CYAN}自动修复工具${NC}     - 根据问题类型自动修复代码"
    echo -e "${GREEN}4.${NC} 📊 ${CYAN}状态检查工具${NC}     - 检查GitHub Actions和CI/CD状态"
    echo -e "${GREEN}5.${NC} 🚀 ${CYAN}一键部署流程${NC}     - 自动化代码提交和部署"
    echo -e "${GREEN}6.${NC} 📋 ${CYAN}查看反馈日志${NC}     - 查看所有历史反馈记录"
    echo -e "${GREEN}7.${NC} ⚙️  ${CYAN}配置管理${NC}        - 管理CI/CD配置和环境设置"
    echo -e "${GREEN}8.${NC} 🔗 ${CYAN}外部链接${NC}        - 快速访问GitHub、SonarCloud等"
    echo -e "${GREEN}9.${NC} 🧹 ${CYAN}清理工具${NC}        - 清理日志和临时文件"
    echo -e "${GREEN}0.${NC} ❌ ${CYAN}退出${NC}            - 退出反馈中心"
    echo ""
    echo -e "${YELLOW}输入选项 (0-9):${NC} "
}

# 实时反馈终端
start_realtime_feedback() {
    echo -e "${CYAN}启动实时反馈终端...${NC}"
    ./terminal-feedback.sh
}

# 持续监控模式
start_continuous_monitor() {
    echo -e "${CYAN}启动持续监控模式...${NC}"
    echo -e "${YELLOW}提示: 按 Ctrl+C 可以停止监控${NC}"
    echo ""
    ./continuous-monitor.sh
}

# 自动修复工具
start_auto_fix() {
    echo -e "${CYAN}自动修复工具${NC}"
    echo ""
    echo "请选择修复类型:"
    echo "1. 编译错误修复"
    echo "2. 测试失败修复"
    echo "3. 代码质量修复"
    echo "4. 安全漏洞修复"
    echo "5. 部署问题修复"
    echo "6. 全部修复"
    echo ""
    read -p "输入选项 (1-6): " fix_choice
    
    case $fix_choice in
        1) ./auto-feedback.sh compile ;;
        2) ./auto-feedback.sh test ;;
        3) ./auto-feedback.sh quality ;;
        4) ./auto-feedback.sh security ;;
        5) ./auto-feedback.sh deploy ;;
        6) ./auto-feedback.sh all ;;
        *) echo -e "${RED}无效选项${NC}" ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
}

# 状态检查工具
run_status_check() {
    echo -e "${CYAN}执行状态检查...${NC}"
    ./monitor-ci-status.sh -d
    echo ""
    read -p "按回车键继续..."
}

# 一键部署流程
run_deployment_flow() {
    echo -e "${CYAN}一键部署流程${NC}"
    echo ""
    
    cd "$PROJECT_DIR"
    
    # 检查是否有未提交的更改
    if ! git diff --quiet; then
        echo -e "${YELLOW}检测到未提交的更改${NC}"
        git status --short
        echo ""
        read -p "是否提交这些更改? (y/n): " commit_choice
        
        if [ "$commit_choice" = "y" ] || [ "$commit_choice" = "Y" ]; then
            read -p "请输入提交信息: " commit_message
            git add .
            git commit -m "$commit_message"
            echo -e "${GREEN}代码已提交${NC}"
        else
            echo -e "${RED}部署已取消${NC}"
            return
        fi
    fi
    
    # 推送到远程仓库
    echo -e "${CYAN}推送代码到远程仓库...${NC}"
    if git push; then
        echo -e "${GREEN}代码推送成功${NC}"
        echo -e "${CYAN}CI/CD流水线将自动触发${NC}"
        
        # 启动监控
        echo ""
        read -p "是否启动实时监控? (y/n): " monitor_choice
        if [ "$monitor_choice" = "y" ] || [ "$monitor_choice" = "Y" ]; then
            ./continuous-monitor.sh
        fi
    else
        echo -e "${RED}代码推送失败${NC}"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 查看反馈日志
view_feedback_logs() {
    echo -e "${CYAN}反馈日志查看器${NC}"
    echo ""
    echo "请选择日志类型:"
    echo "1. 实时反馈日志"
    echo "2. 监控日志"
    echo "3. CI修复日志"
    echo "4. 所有日志"
    echo ""
    read -p "输入选项 (1-4): " log_choice
    
    case $log_choice in
        1)
            if [ -f "${PROJECT_DIR}/realtime-feedback.log" ]; then
                less "${PROJECT_DIR}/realtime-feedback.log"
            else
                echo -e "${YELLOW}实时反馈日志不存在${NC}"
            fi
            ;;
        2)
            if [ -f "${PROJECT_DIR}/monitor.log" ]; then
                less "${PROJECT_DIR}/monitor.log"
            else
                echo -e "${YELLOW}监控日志不存在${NC}"
            fi
            ;;
        3)
            if [ -f "${PROJECT_DIR}/ci-feedback.log" ]; then
                less "${PROJECT_DIR}/ci-feedback.log"
            else
                echo -e "${YELLOW}CI修复日志不存在${NC}"
            fi
            ;;
        4)
            echo -e "${CYAN}所有日志文件:${NC}"
            find "$PROJECT_DIR" -name "*.log" -type f | while read -r logfile; do
                echo -e "${GREEN}=== $(basename "$logfile") ===${NC}"
                tail -20 "$logfile"
                echo ""
            done | less
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
}

# 配置管理
manage_configuration() {
    echo -e "${CYAN}配置管理${NC}"
    echo ""
    echo "请选择配置操作:"
    echo "1. 查看当前配置"
    echo "2. 编辑CI/CD配置"
    echo "3. 查看环境变量"
    echo "4. 检查依赖配置"
    echo ""
    read -p "输入选项 (1-4): " config_choice
    
    cd "$PROJECT_DIR"
    
    case $config_choice in
        1)
            echo -e "${CYAN}当前配置信息:${NC}"
            echo ""
            echo -e "${GREEN}Git配置:${NC}"
            git config --list | grep -E "user\.|remote\." | head -10
            echo ""
            echo -e "${GREEN}Maven配置:${NC}"
            if [ -f "pom.xml" ]; then
                echo "pom.xml 存在"
                grep -E "<groupId>|<artifactId>|<version>" pom.xml | head -6
            fi
            echo ""
            echo -e "${GREEN}应用配置:${NC}"
            ls -la src/main/resources/application*.yml 2>/dev/null || echo "未找到应用配置文件"
            ;;
        2)
            echo -e "${CYAN}编辑CI/CD配置文件:${NC}"
            if [ -f ".github/workflows/ci-cd.yml" ]; then
                ${EDITOR:-nano} ".github/workflows/ci-cd.yml"
            else
                echo -e "${RED}CI/CD配置文件不存在${NC}"
            fi
            ;;
        3)
            echo -e "${CYAN}环境变量:${NC}"
            env | grep -E "JAVA_HOME|MAVEN_HOME|PATH" | head -10
            ;;
        4)
            echo -e "${CYAN}检查依赖配置:${NC}"
            mvn dependency:tree | head -20
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
}

# 外部链接
open_external_links() {
    echo -e "${CYAN}外部链接${NC}"
    echo ""
    echo "请选择要打开的链接:"
    echo "1. GitHub Actions"
    echo "2. GitHub 仓库"
    echo "3. SonarCloud"
    echo "4. Codecov"
    echo "5. 显示所有链接"
    echo ""
    read -p "输入选项 (1-5): " link_choice
    
    case $link_choice in
        1)
            echo -e "${GREEN}GitHub Actions:${NC} https://github.com/$REPO_OWNER/$REPO_NAME/actions"
            ;;
        2)
            echo -e "${GREEN}GitHub 仓库:${NC} https://github.com/$REPO_OWNER/$REPO_NAME"
            ;;
        3)
            echo -e "${GREEN}SonarCloud:${NC} https://sonarcloud.io/project/overview?id=..."
            ;;
        4)
            echo -e "${GREEN}Codecov:${NC} https://codecov.io/gh/$REPO_OWNER/$REPO_NAME"
            ;;
        5)
            echo -e "${GREEN}所有外部链接:${NC}"
            echo "• GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
            echo "• GitHub 仓库: https://github.com/$REPO_OWNER/$REPO_NAME"
            echo "• SonarCloud: https://sonarcloud.io/project/overview?id=..."
            echo "• Codecov: https://codecov.io/gh/$REPO_OWNER/$REPO_NAME"
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
}

# 清理工具
run_cleanup() {
    echo -e "${CYAN}清理工具${NC}"
    echo ""
    echo "请选择清理操作:"
    echo "1. 清理所有日志文件"
    echo "2. 清理Maven缓存"
    echo "3. 清理临时文件"
    echo "4. 全部清理"
    echo ""
    read -p "输入选项 (1-4): " cleanup_choice
    
    cd "$PROJECT_DIR"
    
    case $cleanup_choice in
        1)
            echo -e "${YELLOW}清理日志文件...${NC}"
            find . -name "*.log" -type f -delete
            echo -e "${GREEN}日志文件已清理${NC}"
            ;;
        2)
            echo -e "${YELLOW}清理Maven缓存...${NC}"
            mvn clean > /dev/null 2>&1
            echo -e "${GREEN}Maven缓存已清理${NC}"
            ;;
        3)
            echo -e "${YELLOW}清理临时文件...${NC}"
            find . -name "*.tmp" -o -name ".ci-status" -o -name ".last-run-id" | xargs rm -f
            echo -e "${GREEN}临时文件已清理${NC}"
            ;;
        4)
            echo -e "${YELLOW}执行全部清理...${NC}"
            find . -name "*.log" -type f -delete
            mvn clean > /dev/null 2>&1
            find . -name "*.tmp" -o -name ".ci-status" -o -name ".last-run-id" | xargs rm -f
            echo -e "${GREEN}全部清理完成${NC}"
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
}

# 主循环
main_loop() {
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1) start_realtime_feedback ;;
            2) start_continuous_monitor ;;
            3) start_auto_fix ;;
            4) run_status_check ;;
            5) run_deployment_flow ;;
            6) view_feedback_logs ;;
            7) manage_configuration ;;
            8) open_external_links ;;
            9) run_cleanup ;;
            0) 
                echo -e "${GREEN}感谢使用万里后端 CI/CD 反馈中心！${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}无效选项，请重新选择${NC}"
                sleep 2
                ;;
        esac
    done
}

# 检查依赖
check_dependencies() {
    local missing_deps=()
    
    # 检查必要的脚本文件
    local required_scripts=("terminal-feedback.sh" "continuous-monitor.sh" "auto-feedback.sh" "monitor-ci-status.sh")
    
    for script in "${required_scripts[@]}"; do
        if [ ! -f "$PROJECT_DIR/$script" ]; then
            missing_deps+=("$script")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}错误: 缺少必要的脚本文件:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "  ${YELLOW}• $dep${NC}"
        done
        echo ""
        echo -e "${CYAN}请确保所有脚本文件都在项目目录中${NC}"
        exit 1
    fi
}

# 初始化
init_feedback_hub() {
    cd "$PROJECT_DIR"
    
    # 检查依赖
    check_dependencies
    
    # 确保脚本有执行权限
    chmod +x *.sh 2>/dev/null || true
    
    # 创建必要的目录
    mkdir -p logs
    
    echo -e "${GREEN}万里后端 CI/CD 反馈中心已初始化${NC}"
    sleep 1
}

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                        ${WHITE}欢迎使用万里后端${NC}                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                      ${CYAN}CI/CD 反馈中心 v1.0${NC}                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}✅ 实时反馈${NC}    ${GREEN}✅ 自动修复${NC}    ${GREEN}✅ 持续监控${NC}    ${GREEN}✅ 一键部署${NC}  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}正在初始化...${NC}"
    sleep 2
}

# 主程序入口
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "万里后端项目 CI/CD 反馈中心"
    echo ""
    echo "这是一个集成所有CI/CD反馈和自动化功能的统一入口点"
    echo ""
    echo "功能包括:"
    echo "• 实时反馈终端"
    echo "• 持续监控模式"
    echo "• 自动修复工具"
    echo "• 状态检查工具"
    echo "• 一键部署流程"
    echo "• 反馈日志查看"
    echo "• 配置管理"
    echo "• 清理工具"
    echo ""
    echo "用法: $0"
    exit 0
fi

# 启动反馈中心
show_welcome
init_feedback_hub
main_loop