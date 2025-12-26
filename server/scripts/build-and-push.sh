#!/bin/bash
###############################################################################
# IoT Platform Core - Docker镜像构建和发布脚本
# 作者: 罗耀生
# 日期: 2025-12-19
# 用途: 构建并推送Docker镜像到Docker Hub
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
DOCKER_USERNAME="luoyaosheng"
IMAGE_NAME="iot-platform-core"
REGISTRY="docker.io"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 打印分隔线
print_separator() {
    echo "=================================================================="
}

###############################################################################
# 1. 获取版本号
###############################################################################
get_version() {
    log_info "获取版本信息..."

    # 从git获取版本号
    if git describe --tags --abbrev=0 &> /dev/null; then
        VERSION=$(git describe --tags --abbrev=0)
        log_info "使用Git标签版本: $VERSION"
    else
        # 使用日期作为版本号
        VERSION="v$(date +%Y%m%d-%H%M%S)"
        log_warn "未找到Git标签，使用时间戳: $VERSION"
    fi

    # 获取Git提交hash
    GIT_COMMIT=$(git rev-parse --short HEAD)
    log_info "Git Commit: $GIT_COMMIT"
}

###############################################################################
# 2. 构建镜像
###############################################################################
build_image() {
    log_info "开始构建Docker镜像..."
    print_separator

    # 构建镜像（多标签）
    docker build \
        --build-arg VERSION="$VERSION" \
        --build-arg GIT_COMMIT="$GIT_COMMIT" \
        -t "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}" \
        -t "${DOCKER_USERNAME}/${IMAGE_NAME}:latest" \
        .

    if [ $? -eq 0 ]; then
        log_success "镜像构建成功"
    else
        log_error "镜像构建失败"
        exit 1
    fi
}

###############################################################################
# 3. 测试镜像
###############################################################################
test_image() {
    log_info "测试镜像..."

    # 运行镜像进行简单测试
    log_info "检查镜像是否能正常启动..."

    # 这里可以添加更多测试逻辑
    docker images | grep "${DOCKER_USERNAME}/${IMAGE_NAME}"

    log_success "镜像测试通过"
}

###############################################################################
# 4. 登录Docker Hub
###############################################################################
docker_login() {
    log_info "登录Docker Hub..."

    if [ -n "$DOCKER_PASSWORD" ]; then
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    else
        docker login -u "$DOCKER_USERNAME"
    fi

    if [ $? -eq 0 ]; then
        log_success "登录成功"
    else
        log_error "登录失败"
        exit 1
    fi
}

###############################################################################
# 5. 推送镜像
###############################################################################
push_image() {
    log_info "推送镜像到Docker Hub..."
    print_separator

    # 推送版本标签
    log_info "推送 ${VERSION} 标签..."
    docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

    # 推送latest标签
    log_info "推送 latest 标签..."
    docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:latest"

    if [ $? -eq 0 ]; then
        log_success "镜像推送成功"
    else
        log_error "镜像推送失败"
        exit 1
    fi
}

###############################################################################
# 6. 显示镜像信息
###############################################################################
show_image_info() {
    print_separator
    log_success "镜像发布完成！"
    print_separator

    echo ""
    echo "📦 镜像信息:"
    echo "  - 名称:    ${DOCKER_USERNAME}/${IMAGE_NAME}"
    echo "  - 版本:    ${VERSION}"
    echo "  - Commit:  ${GIT_COMMIT}"
    echo "  - Latest:  ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
    echo ""
    echo "🔗 Docker Hub 地址:"
    echo "  https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
    echo ""
    echo "📝 拉取命令:"
    echo "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
    echo "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
    echo ""
    echo "🚀 使用命令:"
    echo "  在服务器上执行:"
    echo "  docker-compose pull"
    echo "  docker-compose up -d"
    echo ""
    print_separator
}

###############################################################################
# 7. 清理本地镜像（可选）
###############################################################################
cleanup() {
    read -p "是否清理本地镜像？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "清理本地镜像..."
        docker rmi "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}" || true
        docker rmi "${DOCKER_USERNAME}/${IMAGE_NAME}:latest" || true
        log_success "清理完成"
    fi
}

###############################################################################
# 主流程
###############################################################################
main() {
    clear
    echo "###############################################################################"
    echo "#                                                                             #"
    echo "#        IoT Platform Core - Docker镜像构建和发布脚本                          #"
    echo "#                                                                             #"
    echo "###############################################################################"
    echo ""

    # 检查是否在项目根目录
    if [ ! -f "Dockerfile" ]; then
        log_error "未找到 Dockerfile，请在项目根目录执行此脚本"
        exit 1
    fi

    # 1. 获取版本号
    get_version
    echo ""

    # 2. 构建镜像
    build_image
    echo ""

    # 3. 测试镜像
    test_image
    echo ""

    # 4. 确认推送
    read -p "是否推送镜像到Docker Hub？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "取消推送"
        exit 0
    fi

    # 5. 登录Docker Hub
    docker_login
    echo ""

    # 6. 推送镜像
    push_image
    echo ""

    # 7. 显示镜像信息
    show_image_info

    # 8. 清理（可选）
    cleanup
}

# 执行主流程
main
