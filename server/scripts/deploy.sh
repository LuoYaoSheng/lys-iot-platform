#!/bin/bash
###############################################################################
# IoT Platform Core - 自动化部署脚本
# 作者: 罗耀生
# 日期: 2025-12-19
# 用途: 一键部署并自动检查数据库初始化
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
# 1. 环境检查
###############################################################################
check_environment() {
    log_info "检查部署环境..."

    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    log_success "Docker 已安装: $(docker --version)"

    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
    log_success "Docker Compose 已安装: $(docker-compose --version)"

    # 检查 .env 文件
    if [ ! -f .env ]; then
        log_warn ".env 文件不存在，从模板复制"
        if [ -f .env.example ]; then
            cp .env.example .env
            log_warn "请编辑 .env 文件配置环境变量！"
            exit 1
        else
            log_error ".env.example 文件不存在"
            exit 1
        fi
    fi
    log_success ".env 文件存在"
}

###############################################################################
# 2. 构建和启动服务
###############################################################################
deploy_services() {
    log_info "开始部署服务..."
    print_separator

    # 拉取最新镜像
    log_info "拉取最新镜像..."
    docker-compose pull

    # 构建并启动服务
    log_info "启动服务..."
    docker-compose up -d

    log_success "服务启动命令已执行"
}

###############################################################################
# 3. 等待服务就绪
###############################################################################
wait_for_service() {
    local service_name=$1
    local max_wait=$2
    local waited=0

    log_info "等待 $service_name 就绪..."

    while [ $waited -lt $max_wait ]; do
        if docker-compose ps | grep $service_name | grep -q "healthy\|Up"; then
            log_success "$service_name 已就绪"
            return 0
        fi
        sleep 2
        waited=$((waited + 2))
        echo -n "."
    done

    echo ""
    log_error "$service_name 启动超时"
    return 1
}

wait_for_all_services() {
    log_info "等待所有服务就绪..."
    print_separator

    wait_for_service "mysql" 60
    wait_for_service "redis" 30
    wait_for_service "iot-platform-core" 60
    wait_for_service "emqx" 60

    log_success "所有服务已就绪"
}

###############################################################################
# 4. 数据库初始化检查（关键）
###############################################################################
check_and_init_database() {
    log_info "检查数据库初始化状态..."
    print_separator

    # 等待 MySQL 完全启动
    sleep 5

    # 检查产品表是否有数据
    log_info "检查产品数据..."
    PRODUCT_COUNT=$(docker-compose exec -T mysql mysql -uroot -proot123456 iot_platform -sN -e "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "0")

    if [ "$PRODUCT_COUNT" -eq 0 ]; then
        log_warn "产品表为空，执行初始化..."

        # 执行产品数据初始化
        docker-compose exec -T mysql mysql -uroot -proot123456 iot_platform <<EOF
INSERT INTO products (product_key, name, description, category, status) VALUES
('SW-SERVO-001', '智能开关(舵机版)', 'ESP32智能舵机开关，支持BLE配网和MQTT控制', 'switch', 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    category = VALUES(category),
    status = VALUES(status);
EOF

        if [ $? -eq 0 ]; then
            log_success "产品数据初始化成功"
        else
            log_error "产品数据初始化失败"
            return 1
        fi

        # 再次检查
        PRODUCT_COUNT=$(docker-compose exec -T mysql mysql -uroot -proot123456 iot_platform -sN -e "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "0")
    fi

    if [ "$PRODUCT_COUNT" -gt 0 ]; then
        log_success "产品数据完整 ($PRODUCT_COUNT 个产品)"

        # 显示产品列表
        echo ""
        log_info "当前产品列表:"
        docker-compose exec -T mysql mysql -uroot -proot123456 iot_platform -e "
SELECT product_key, name, category, status
FROM products
ORDER BY created_at;
" 2>/dev/null
        echo ""
    else
        log_error "产品数据检查失败"
        return 1
    fi
}

###############################################################################
# 5. 健康检查
###############################################################################
health_check() {
    log_info "执行健康检查..."
    print_separator

    # 检查 API 健康
    log_info "检查 API 服务..."
    API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:48080/health 2>/dev/null || echo "000")

    if [ "$API_STATUS" == "200" ]; then
        log_success "API 服务健康 (HTTP $API_STATUS)"
    else
        log_warn "API 服务异常 (HTTP $API_STATUS)"
    fi

    # 检查 EMQX Dashboard
    log_info "检查 EMQX Dashboard..."
    EMQX_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:48884 2>/dev/null || echo "000")

    if [ "$EMQX_STATUS" == "200" ] || [ "$EMQX_STATUS" == "302" ]; then
        log_success "EMQX Dashboard 正常 (HTTP $EMQX_STATUS)"
    else
        log_warn "EMQX Dashboard 异常 (HTTP $EMQX_STATUS)"
    fi

    # 检查 Docker 容器状态
    echo ""
    log_info "Docker 容器状态:"
    docker-compose ps
    echo ""
}

###############################################################################
# 6. 测试设备激活接口
###############################################################################
test_device_activation() {
    log_info "测试设备激活接口..."
    print_separator

    TEST_RESPONSE=$(curl -s -X POST http://localhost:48080/api/v1/devices/activate \
        -H "Content-Type: application/json" \
        -d '{
            "productKey": "SW-SERVO-001",
            "deviceSN": "TEST-DEPLOY-'"$(date +%s)"'",
            "firmwareVersion": "1.0.0",
            "chipModel": "ESP32-WROOM-32E"
        }' 2>/dev/null)

    if echo "$TEST_RESPONSE" | grep -q '"code":0'; then
        log_success "设备激活接口正常"
        echo "$TEST_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$TEST_RESPONSE"
    elif echo "$TEST_RESPONSE" | grep -q 'already_activated'; then
        log_success "设备激活接口正常（设备已存在）"
    else
        log_warn "设备激活接口响应异常"
        echo "$TEST_RESPONSE"
    fi
    echo ""
}

###############################################################################
# 7. 显示部署信息
###############################################################################
show_deployment_info() {
    print_separator
    log_success "部署完成！"
    print_separator

    echo ""
    echo "📋 服务访问地址:"
    echo "  - API 服务:        http://localhost:48080"
    echo "  - API 文档:        http://localhost:48080/swagger/index.html"
    echo "  - EMQX Dashboard:  http://localhost:48884"
    echo "  - EMQX 默认账号:   admin / public"
    echo ""
    echo "🔌 端口映射:"
    echo "  - MySQL:    48306"
    echo "  - Redis:    48379"
    echo "  - MQTT:     48883"
    echo "  - API:      48080"
    echo "  - EMQX WS:  48803"
    echo "  - EMQX UI:  48884"
    echo ""
    echo "📝 常用命令:"
    echo "  - 查看日志:    docker-compose logs -f"
    echo "  - 查看状态:    docker-compose ps"
    echo "  - 重启服务:    docker-compose restart"
    echo "  - 停止服务:    docker-compose down"
    echo ""
    echo "⚠️  下一步操作:"
    echo "  1. 访问 EMQX Dashboard 修改默认密码"
    echo "  2. 创建管理员账号"
    echo "  3. 配置 EMQX HTTP Auth（参考文档）"
    echo "  4. 配置防火墙规则"
    echo ""
    print_separator
}

###############################################################################
# 主流程
###############################################################################
main() {
    clear
    echo "###############################################################################"
    echo "#                                                                             #"
    echo "#              IoT Platform Core - 自动化部署脚本                              #"
    echo "#                                                                             #"
    echo "###############################################################################"
    echo ""

    # 1. 环境检查
    check_environment
    echo ""

    # 2. 部署服务
    deploy_services
    echo ""

    # 3. 等待服务就绪
    wait_for_all_services
    echo ""

    # 4. 数据库初始化检查（最关键）
    check_and_init_database
    echo ""

    # 5. 健康检查
    health_check
    echo ""

    # 6. 测试设备激活
    test_device_activation
    echo ""

    # 7. 显示部署信息
    show_deployment_info
}

# 执行主流程
main
