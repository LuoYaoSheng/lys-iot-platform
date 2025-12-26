#!/bin/bash
# ========================================
# IoT 平台 - 一键部署脚本
# 作者: 罗耀生
# ========================================

echo "========================================="
echo "IoT 平台 - 一键部署"
echo "========================================="
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未检测到 Docker，请先安装 Docker"
    exit 1
fi

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "📝 未找到 .env 文件，正在从模板创建..."
    cp .env.simple .env
    echo ""
    echo "⚠️  请先编辑 .env 文件，修改以下配置:"
    echo "   1. SERVER_IP - 改成你的服务器IP或域名"
    echo "   2. DB_PASSWORD - 改成你想要的数据库密码"
    echo ""
    echo "修改完成后，再次运行此脚本: bash deploy.sh"
    exit 0
fi

# 拉取最新镜像
echo "📦 正在拉取最新镜像..."
docker pull luoyaosheng/iot-platform-core:latest

# 启动服务
echo ""
echo "🚀 正在启动服务..."
docker compose -f docker-compose.simple.yml up -d

# 等待服务启动
echo ""
echo "⏳ 等待服务启动 (30秒)..."
sleep 30

# 检查服务状态
echo ""
echo "📊 服务状态:"
docker compose -f docker-compose.simple.yml ps

# 获取服务器IP
SERVER_IP=$(grep SERVER_IP .env | cut -d '=' -f2)

echo ""
echo "========================================="
echo "✅ 部署完成!"
echo "========================================="
echo ""
echo "访问地址:"
echo "  API服务: http://${SERVER_IP}:48080"
echo "  EMQX控制台: http://${SERVER_IP}:49084"
echo "  - 账号: admin"
echo "  - 密码: public"
echo ""
echo "常用命令:"
echo "  查看日志: docker compose -f docker-compose.simple.yml logs -f"
echo "  停止服务: docker compose -f docker-compose.simple.yml down"
echo "  重启服务: docker compose -f docker-compose.simple.yml restart"
echo ""
echo "========================================="
