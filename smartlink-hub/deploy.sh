#!/bin/bash

# ========================================
# IoT SmartLink Hub 部署脚本
# 作者: 罗耀生
# 日期: 2025-12-19
# 用途: 推送项目到 Gitee 并启用 Pages
# ========================================

set -e  # 遇到错误立即退出

echo "========================================"
echo "    IoT SmartLink Hub 部署工具         "
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 远程仓库地址
REMOTE_URL="https://gitee.com/luoyaosheng/iot-smartlink-hub.git"

# 1. 检查 Git 状态
echo -e "${YELLOW}→ 检查 Git 状态...${NC}"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: 当前目录不是 Git 仓库${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git 仓库正常${NC}"

# 2. 添加所有更改
echo -e "${YELLOW}→ 添加文件到 Git...${NC}"
git add .
echo -e "${GREEN}✓ 文件添加完成${NC}"

# 3. 提交更改
echo -e "${YELLOW}→ 提交更改...${NC}"
COMMIT_MSG="Lys $(date +%Y%m%d) 更新项目"
git commit -m "$COMMIT_MSG" || echo "没有新的更改需要提交"
echo -e "${GREEN}✓ 提交完成${NC}"

# 4. 检查远程仓库
if ! git remote get-url origin &> /dev/null; then
    echo -e "${YELLOW}→ 添加远程仓库...${NC}"
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}✓ 远程仓库添加完成${NC}"
else
    echo -e "${GREEN}✓ 远程仓库已存在${NC}"
    # 更新远程 URL(如果不同)
    CURRENT_URL=$(git remote get-url origin)
    if [ "$CURRENT_URL" != "$REMOTE_URL" ]; then
        echo -e "${YELLOW}→ 更新远程仓库 URL...${NC}"
        git remote set-url origin "$REMOTE_URL"
    fi
fi

# 5. 推送到远程仓库
echo -e "${YELLOW}→ 推送到 Gitee...${NC}"
git push -u origin master || git push -u origin main
echo -e "${GREEN}✓ 推送完成${NC}"

echo ""
echo "========================================"
echo -e "${GREEN}部署成功!${NC}"
echo "========================================"
echo ""
echo "📝 后续步骤:"
echo "1. 访问 Gitee 仓库: $REMOTE_URL"
echo "2. 进入 '服务' -> 'Gitee Pages'"
echo "3. 选择部署目录: landing-page"
echo "4. 点击 '启动' 按钮"
echo "5. 等待部署完成(约1-2分钟)"
echo "6. 访问你的落地页: https://luoyaosheng.gitee.io/iot-smartlink-hub/"
echo ""
echo "💡 提示:"
echo "- Gitee Pages 每次更新后需要手动点击 '更新' 按钮"
echo "- 首次部署可能需要实名认证"
echo "- 大文件(APK/固件)已包含在 releases 目录"
echo ""
