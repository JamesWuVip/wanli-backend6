#!/bin/bash

# 万里后端项目 GitHub 配置脚本
# 使用方法: ./setup-github.sh <GitHub仓库URL>

set -e

if [ $# -eq 0 ]; then
    echo "❌ 请提供GitHub仓库URL"
    echo "使用方法: ./setup-github.sh https://github.com/用户名/仓库名.git"
    echo ""
    echo "📝 创建GitHub仓库步骤:"
    echo "1. 访问 https://github.com/new"
    echo "2. 仓库名称建议: wanli-backend"
    echo "3. 不要初始化README、.gitignore或LICENSE"
    echo "4. 复制仓库URL并运行此脚本"
    exit 1
fi

REPO_URL=$1

echo "🚀 开始配置GitHub远程仓库..."
echo "仓库URL: $REPO_URL"
echo ""

# 检查是否已有远程仓库
if git remote get-url origin 2>/dev/null; then
    echo "⚠️  检测到已有远程仓库，将更新为新URL"
    git remote set-url origin "$REPO_URL"
else
    echo "➕ 添加远程仓库"
    git remote add origin "$REPO_URL"
fi

# 确保在dev分支
echo "🔄 确保在dev分支"
git checkout dev

# 推送代码
echo "📤 推送代码到GitHub..."
git push -u origin dev

echo ""
echo "✅ 配置完成！"
echo ""
echo "🎉 CI/CD流程已触发，请访问以下链接查看:"
echo "GitHub仓库: ${REPO_URL%.git}"
echo "Actions页面: ${REPO_URL%.git}/actions"
echo ""
echo "📊 您将看到以下自动化检查:"
echo "- ✅ 代码编译和测试"
echo "- 🔒 安全漏洞扫描"
echo "- 📈 代码质量分析"
echo "- 🚀 自动部署到开发环境"
echo ""
echo "⏱️  整个流程大约需要5-10分钟完成"