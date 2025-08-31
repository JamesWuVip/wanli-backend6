#!/bin/bash

# 万里后端项目监控服务配置脚本
# 用于配置 Codecov 和 Sentry 服务

set -e

echo "🚀 开始配置万里后端项目监控服务..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查必要的工具
check_tools() {
    echo -e "${BLUE}📋 检查必要工具...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git 未安装，请先安装 Git${NC}"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        echo -e "${RED}❌ Maven 未安装，请先安装 Maven${NC}"
        exit 1
    fi
    
    if ! command -v codecov &> /dev/null; then
        echo -e "${YELLOW}⚠️  Codecov CLI 未安装，正在安装...${NC}"
        if command -v pipx &> /dev/null; then
            pipx install codecov
            pipx ensurepath
            # 重新加载PATH
            export PATH="$HOME/.local/bin:$PATH"
        else
            echo -e "${RED}❌ 请先安装 pipx: brew install pipx${NC}"
            exit 1
        fi
    fi
    
    if ! command -v sentry-cli &> /dev/null; then
        echo -e "${YELLOW}⚠️  Sentry CLI 未安装，正在安装...${NC}"
        if command -v npm &> /dev/null; then
            npm install -g @sentry/cli
        elif command -v brew &> /dev/null; then
            brew install getsentry/tools/sentry-cli
        else
            echo -e "${RED}❌ 请先安装 npm 或 brew${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ 工具检查完成${NC}"
}

# 配置 Codecov
setup_codecov() {
    echo -e "${BLUE}🔧 配置 Codecov...${NC}"
    
    # 检查是否已有有效的 token
    if grep -q "CODECOV_TOKEN=your-codecov-token-here" .env 2>/dev/null; then
        echo -e "${YELLOW}⚠️  需要配置 Codecov token${NC}"
        echo -e "${BLUE}请按以下步骤获取 Codecov token:${NC}"
        echo "1. 访问 https://codecov.io"
        echo "2. 使用 GitHub 账号登录"
        echo "3. 点击 'Add new repository'"
        echo "4. 选择你的 wanli-backend 仓库"
        echo "5. 复制 'Repository Upload Token'"
        echo ""
        
        read -p "请输入你的 Codecov token (或按回车跳过): " codecov_token
        
        if [ ! -z "$codecov_token" ]; then
            # 更新 .env 文件中的 token
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/CODECOV_TOKEN=your-codecov-token-here/CODECOV_TOKEN=$codecov_token/" .env
            else
                sed -i "s/CODECOV_TOKEN=your-codecov-token-here/CODECOV_TOKEN=$codecov_token/" .env
            fi
            echo -e "${GREEN}✅ Codecov token 已更新${NC}"
        else
            echo -e "${YELLOW}⚠️  跳过 Codecov token 配置${NC}"
        fi
    fi
    
    # 生成测试覆盖率报告
    echo -e "${BLUE}📊 生成测试覆盖率报告...${NC}"
    if mvn clean test jacoco:report; then
        echo -e "${GREEN}✅ 覆盖率报告生成成功${NC}"
        
        # 测试 Codecov 上传（dry run）
        echo -e "${BLUE}🧪 测试 Codecov 配置...${NC}"
        if [ -f "target/site/jacoco/jacoco.xml" ]; then
            # 如果有token，尝试实际上传；否则只做dry run
            if ! grep -q "CODECOV_TOKEN=your-codecov-token-here" .env 2>/dev/null; then
                source .env
                export CODECOV_TOKEN
                if codecov -f target/site/jacoco/jacoco.xml; then
                    echo -e "${GREEN}✅ Codecov 上传成功${NC}"
                else
                    echo -e "${YELLOW}⚠️  Codecov 上传失败，请检查 token${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️  未配置 Codecov token，跳过上传测试${NC}"
            fi
        else
            echo -e "${RED}❌ 未找到覆盖率报告文件${NC}"
        fi
    else
        echo -e "${RED}❌ 测试或覆盖率报告生成失败${NC}"
        return 1
    fi
}

# 配置 Sentry
setup_sentry() {
    echo -e "${BLUE}🔧 配置 Sentry...${NC}"
    
    # 检查是否已有 DSN
    if grep -q "SENTRY_DSN=your-sentry-dsn-here" .env 2>/dev/null; then
        echo -e "${YELLOW}⚠️  需要配置 Sentry DSN${NC}"
        echo -e "${BLUE}请按以下步骤获取 Sentry DSN:${NC}"
        echo "1. 访问 https://sentry.io"
        echo "2. 使用 GitHub 账号登录或注册"
        echo "3. 创建新项目，选择 'Java' 平台"
        echo "4. 在项目设置中找到 'Client Keys (DSN)'"
        echo "5. 复制 DSN URL"
        echo ""
        
        read -p "请输入你的 Sentry DSN (或按回车跳过): " sentry_dsn
        
        if [ ! -z "$sentry_dsn" ]; then
            # 更新 .env 文件中的 DSN
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|SENTRY_DSN=your-sentry-dsn-here|SENTRY_DSN=$sentry_dsn|" .env
            else
                sed -i "s|SENTRY_DSN=your-sentry-dsn-here|SENTRY_DSN=$sentry_dsn|" .env
            fi
            echo -e "${GREEN}✅ Sentry DSN 已更新${NC}"
            
            # 测试 Sentry 连接
            echo -e "${BLUE}🧪 测试 Sentry 连接...${NC}"
            source .env
            export SENTRY_DSN
            if sentry-cli info 2>/dev/null; then
                echo -e "${GREEN}✅ Sentry 连接测试成功${NC}"
            else
                echo -e "${YELLOW}⚠️  Sentry 连接测试失败，但 DSN 已配置${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  跳过 Sentry DSN 配置${NC}"
        fi
    else
        echo -e "${GREEN}✅ Sentry DSN 已配置${NC}"
        
        # 测试现有配置
        echo -e "${BLUE}🧪 测试 Sentry 连接...${NC}"
        source .env
        export SENTRY_DSN
        if sentry-cli info 2>/dev/null; then
            echo -e "${GREEN}✅ Sentry 连接正常${NC}"
        else
            echo -e "${YELLOW}⚠️  Sentry 连接测试失败${NC}"
        fi
    fi
}

# 验证配置
verify_setup() {
    echo -e "${BLUE}验证配置...${NC}"
    
    # 检查环境变量文件
    if [ -f ".env" ]; then
        echo -e "${GREEN}✓ .env 文件存在${NC}"
        
        # 检查关键配置
        if ! grep -q "your-codecov-token-here" .env; then
            echo -e "${GREEN}✓ Codecov token 已配置${NC}"
        else
            echo -e "${YELLOW}⚠ Codecov token 仍需配置${NC}"
        fi
        
        if ! grep -q "your-sentry-dsn-here" .env; then
            echo -e "${GREEN}✓ Sentry DSN 已配置${NC}"
        else
            echo -e "${YELLOW}⚠ Sentry DSN 仍需配置${NC}"
        fi
    else
        echo -e "${RED}✗ .env 文件不存在${NC}"
    fi
}

# 生成测试覆盖率报告
generate_coverage() {
    echo -e "${BLUE}生成测试覆盖率报告...${NC}"
    
    if [ -f "pom.xml" ]; then
        echo "运行测试并生成覆盖率报告..."
        mvn clean test jacoco:report
        
        if [ -f "target/site/jacoco/jacoco.xml" ]; then
            echo -e "${GREEN}✓ 覆盖率报告已生成${NC}"
            
            # 如果 Codecov token 已配置，尝试上传
            if ! grep -q "your-codecov-token-here" .env; then
                echo "上传覆盖率报告到 Codecov..."
                ./codecov upload-coverage --file target/site/jacoco/jacoco.xml
            fi
        else
            echo -e "${YELLOW}⚠ 覆盖率报告生成失败${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ 未找到 pom.xml，跳过测试${NC}"
    fi
}

# 主函数
main() {
    echo -e "${GREEN}=== 万里后端监控服务配置脚本 ===${NC}"
    echo ""
    
    check_tools
    echo ""
    
    setup_codecov
    echo ""
    
    setup_sentry
    echo ""
    
    verify_setup
    echo ""
    
    read -p "是否生成测试覆盖率报告? (y/N): " generate_test
    if [[ $generate_test =~ ^[Yy]$ ]]; then
        generate_coverage
    fi
    
    echo ""
    echo -e "${GREEN}🎉 监控服务配置完成！${NC}"
    echo ""
    echo "下一步:"
    echo "1. 如果还有未配置的服务，请按照提示完成配置"
    echo "2. 重启应用以加载新的环境变量"
    echo "3. 运行测试验证集成是否正常工作"
    echo ""
    echo "相关文档:"
    echo "- CLI配置总结: CLI_CONFIGURATION_SUMMARY.md"
    echo "- 环境变量指南: ENVIRONMENT_VARIABLES_SETUP_GUIDE.md"
}

# 运行主函数
main "$@"