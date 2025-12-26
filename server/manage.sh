#!/bin/bash

# ========================================
# IoT Platform Core - 运维管理脚本
# 作者: 罗耀生
# 日期: 2025-12-18
# ========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_menu() {
    clear
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  IoT Platform 运维管理${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "1. 查看服务状态"
    echo "2. 启动服务"
    echo "3. 停止服务"
    echo "4. 重启服务"
    echo "5. 查看日志"
    echo "6. 查看实时日志"
    echo "7. 数据库备份"
    echo "8. 清理日志和数据"
    echo "9. 更新服务"
    echo "0. 退出"
    echo ""
    echo -e "${GREEN}========================================${NC}"
}

# 查看服务状态
check_status() {
    echo -e "${BLUE}[服务状态]${NC}"
    docker compose ps
    echo ""

    echo -e "${BLUE}[资源使用]${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    echo ""

    echo -e "${BLUE}[磁盘使用]${NC}"
    df -h | grep -E "Filesystem|/dev/"

    read -p "按回车键继续..."
}

# 启动服务
start_services() {
    echo -e "${GREEN}正在启动服务...${NC}"
    docker compose up -d
    sleep 5
    docker compose ps
    read -p "按回车键继续..."
}

# 停止服务
stop_services() {
    echo -e "${YELLOW}警告: 即将停止所有服务${NC}"
    read -p "确认停止? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down
        echo -e "${GREEN}服务已停止${NC}"
    fi
    read -p "按回车键继续..."
}

# 重启服务
restart_services() {
    echo -e "${BLUE}请选择重启方式:${NC}"
    echo "1. 重启所有服务"
    echo "2. 重启 iot-platform-core"
    echo "3. 重启 MySQL"
    echo "4. 重启 Redis"
    echo "5. 重启 EMQX"
    read -p "请选择 (1-5): " choice

    case $choice in
        1) docker compose restart ;;
        2) docker compose restart iot-platform-core ;;
        3) docker compose restart mysql ;;
        4) docker compose restart redis ;;
        5) docker compose restart emqx ;;
        *) echo "无效选择" ;;
    esac

    read -p "按回车键继续..."
}

# 查看日志
view_logs() {
    echo -e "${BLUE}请选择查看的服务:${NC}"
    echo "1. 所有服务"
    echo "2. iot-platform-core"
    echo "3. MySQL"
    echo "4. Redis"
    echo "5. EMQX"
    read -p "请选择 (1-5): " choice

    case $choice in
        1) docker compose logs --tail 100 ;;
        2) docker compose logs --tail 100 iot-platform-core ;;
        3) docker compose logs --tail 100 mysql ;;
        4) docker compose logs --tail 100 redis ;;
        5) docker compose logs --tail 100 emqx ;;
        *) echo "无效选择" ;;
    esac

    read -p "按回车键继续..."
}

# 查看实时日志
view_live_logs() {
    echo -e "${BLUE}请选择查看的服务:${NC}"
    echo "1. 所有服务"
    echo "2. iot-platform-core"
    echo "3. MySQL"
    echo "4. Redis"
    echo "5. EMQX"
    read -p "请选择 (1-5): " choice

    echo "按 Ctrl+C 退出实时日志"
    sleep 2

    case $choice in
        1) docker compose logs -f ;;
        2) docker compose logs -f iot-platform-core ;;
        3) docker compose logs -f mysql ;;
        4) docker compose logs -f redis ;;
        5) docker compose logs -f emqx ;;
        *) echo "无效选择" ;;
    esac
}

# 数据库备份
backup_database() {
    echo -e "${GREEN}开始数据库备份...${NC}"

    BACKUP_DIR="./backups"
    mkdir -p $BACKUP_DIR

    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"

    # 从 .env 读取数据库密码
    DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d'=' -f2)

    docker exec iot-platform_mysql mysqldump -uiot_user -p$DB_PASSWORD iot_platform > $BACKUP_FILE

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}备份成功: $BACKUP_FILE${NC}"

        # 显示备份文件大小
        BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)
        echo "备份大小: $BACKUP_SIZE"

        # 清理7天前的备份
        find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
        echo "已清理7天前的旧备份"
    else
        echo -e "${RED}备份失败${NC}"
    fi

    read -p "按回车键继续..."
}

# 清理日志和数据
cleanup() {
    echo -e "${YELLOW}警告: 即将清理未使用的 Docker 资源${NC}"
    echo "这将删除:"
    echo "- 停止的容器"
    echo "- 未使用的网络"
    echo "- 悬空的镜像"
    echo "- 构建缓存"

    read -p "确认清理? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -a
        echo -e "${GREEN}清理完成${NC}"
    fi

    read -p "按回车键继续..."
}

# 更新服务
update_services() {
    echo -e "${GREEN}开始更新服务...${NC}"

    echo "1. 拉取最新代码"
    if [ -d .git ]; then
        git pull
    else
        echo "未检测到 Git 仓库，跳过代码更新"
    fi

    echo "2. 拉取最新镜像"
    docker compose pull

    echo "3. 重新启动服务"
    docker compose up -d

    echo "4. 清理旧镜像"
    docker image prune -f

    echo -e "${GREEN}更新完成${NC}"

    read -p "按回车键继续..."
}

# 主循环
while true; do
    print_menu
    read -p "请选择操作 (0-9): " choice

    case $choice in
        1) check_status ;;
        2) start_services ;;
        3) stop_services ;;
        4) restart_services ;;
        5) view_logs ;;
        6) view_live_logs ;;
        7) backup_database ;;
        8) cleanup ;;
        9) update_services ;;
        0)
            echo -e "${GREEN}再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            ;;
    esac
done
