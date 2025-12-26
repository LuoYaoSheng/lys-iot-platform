#!/bin/bash
# ========================================
# IoT 平台 - Docker 镜像发布脚本
# 作者: 罗耀生
# ========================================

DOCKER_USER="luoyaosheng"
IMAGE_NAME="iot-platform-core"
VERSION=$(date +%Y%m%d-%H%M%S)

echo "========================================="
echo "Docker 镜像发布"
echo "========================================="
echo ""
echo "镜像名称: $DOCKER_USER/$IMAGE_NAME"
echo "版本标签: $VERSION"
echo ""

# 检查是否已登录 Docker Hub
if ! docker info | grep -q "Username"; then
    echo "❌ 请先登录 Docker Hub:"
    echo "   docker login"
    exit 1
fi

# 构建镜像
echo "🔨 正在构建镜像..."
docker build -t $DOCKER_USER/$IMAGE_NAME:latest .

if [ $? -ne 0 ]; then
    echo "❌ 构建失败!"
    exit 1
fi

# 打版本标签
echo ""
echo "🏷️  正在打标签..."
docker tag $DOCKER_USER/$IMAGE_NAME:latest $DOCKER_USER/$IMAGE_NAME:$VERSION

# 推送镜像
echo ""
echo "📤 正在推送镜像到 Docker Hub..."
docker push $DOCKER_USER/$IMAGE_NAME:latest
docker push $DOCKER_USER/$IMAGE_NAME:$VERSION

echo ""
echo "========================================="
echo "✅ 发布完成!"
echo "========================================="
echo ""
echo "镜像地址:"
echo "  最新版: $DOCKER_USER/$IMAGE_NAME:latest"
echo "  版本号: $DOCKER_USER/$IMAGE_NAME:$VERSION"
echo ""
echo "团队成员可以使用:"
echo "  docker pull $DOCKER_USER/$IMAGE_NAME:latest"
echo ""
echo "========================================="
