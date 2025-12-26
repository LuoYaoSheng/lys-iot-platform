#!/bin/bash
###############################################################################
# Docker 镜像推送重试脚本
# 作者: 罗耀生
# 日期: 2025-12-19
# 用途: 网络不稳定时自动重试推送
###############################################################################

set +e  # 允许命令失败

IMAGE_NAME="luoyaosheng/iot-platform-core"
VERSION_TAG="v20251219-095250"
MAX_RETRIES=5

echo "========================================="
echo "Docker 镜像推送重试脚本"
echo "========================================="
echo ""

# 推送函数
push_with_retry() {
    local tag=$1
    local retries=0

    while [ $retries -lt $MAX_RETRIES ]; do
        echo "尝试推送 ${IMAGE_NAME}:${tag} (第 $((retries+1)) 次)..."

        if docker push ${IMAGE_NAME}:${tag}; then
            echo "✅ ${tag} 推送成功！"
            return 0
        else
            retries=$((retries+1))
            if [ $retries -lt $MAX_RETRIES ]; then
                echo "❌ 推送失败，10秒后重试..."
                sleep 10
            fi
        fi
    done

    echo "❌ ${tag} 推送失败，已达到最大重试次数"
    return 1
}

# 推送版本标签
push_with_retry ${VERSION_TAG}

# 推送 latest 标签
push_with_retry "latest"

echo ""
echo "========================================="
echo "推送完成！"
echo "========================================="
