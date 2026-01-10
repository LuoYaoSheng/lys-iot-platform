#!/bin/bash

# ========================================
# Open IoT Platform - Release 打包脚本
# 作者: 罗耀生
# 日期: 2026-01-10
# 用途: 打包发布所需的文件
# ========================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 版本号
VERSION="${1:-v0.3.0}"
RELEASE_DIR="smartlink-hub/releases/$VERSION"
ZIP_FILE="smartlink-hub/releases/open-iot-platform-${VERSION}.zip"

echo "========================================"
echo "  Open IoT Platform - Release 打包工具 "
echo "  版本: $VERSION"
echo "========================================"
echo ""

# 清理并创建发布目录
echo -e "${YELLOW}→ 创建发布目录...${NC}"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"/{firmware,scripts}

# ========================================
# 1. 收集固件文件
# ========================================
echo -e "${YELLOW}→ 收集固件文件...${NC}"

# ESP32 舵机开关固件
if [ -f "firmware/switch/.pio/build/esp32dev/firmware.bin" ]; then
    cp firmware/switch/.pio/build/esp32dev/firmware.bin \
       "$RELEASE_DIR/firmware/esp32-servo-firmware.bin"
    echo -e "${GREEN}  ✓ ESP32 舵机开关固件${NC}"
fi
if [ -f "firmware/switch/.pio/build/esp32dev/bootloader.bin" ]; then
    cp firmware/switch/.pio/build/esp32dev/bootloader.bin \
       "$RELEASE_DIR/firmware/bootloader-esp32.bin"
fi
if [ -f "firmware/switch/.pio/build/esp32dev/partitions.bin" ]; then
    cp firmware/switch/.pio/build/esp32dev/partitions.bin \
       "$RELEASE_DIR/firmware/partitions-esp32.bin"
fi

# ESP32-S3 USB 唤醒固件
if [ -f "firmware/usb-wakeup/.pio/build/esp32s3/firmware.bin" ]; then
    cp firmware/usb-wakeup/.pio/build/esp32s3/firmware.bin \
       "$RELEASE_DIR/firmware/esp32s3-wakeup-firmware.bin"
    echo -e "${GREEN}  ✓ ESP32-S3 USB 唤醒固件${NC}"
fi
if [ -f "firmware/usb-wakeup/.pio/build/esp32s3/bootloader.bin" ]; then
    cp firmware/usb-wakeup/.pio/build/esp32s3/bootloader.bin \
       "$RELEASE_DIR/firmware/bootloader-esp32s3.bin"
fi
if [ -f "firmware/usb-wakeup/.pio/build/esp32s3/partitions.bin" ]; then
    cp firmware/usb-wakeup/.pio/build/esp32s3/partitions.bin \
       "$RELEASE_DIR/firmware/partitions-esp32s3.bin"
fi

# ========================================
# 2. 收集移动端 APK
# ========================================
echo -e "${YELLOW}→ 收集移动端 APK...${NC}"

APK_FILE=$(find mobile-app/build/outputs/apk/release -name "*.apk" 2>/dev/null | head -1)
if [ -n "$APK_FILE" ]; then
    cp "$APK_FILE" "$RELEASE_DIR/iot-config-app.apk"
    echo -e "${GREEN}  ✓ 移动端 APK${NC}"
else
    echo -e "${RED}  ⚠ APK 文件未找到${NC}"
    echo -e "${YELLOW}  构建命令: cd mobile-app && flutter build apk${NC}"
fi

# ========================================
# 3. 收集服务端部署文件
# ========================================
echo -e "${YELLOW}→ 收集服务端部署文件...${NC}"

# docker-compose
cp server/docker-compose.yml "$RELEASE_DIR/docker-compose.yml"
echo -e "${GREEN}  ✓ docker-compose.yml${NC}"

# 数据库初始化脚本
cp server/scripts/init.sql "$RELEASE_DIR/scripts/init.sql"
echo -e "${GREEN}  ✓ scripts/init.sql${NC}"

# ========================================
# 4. 生成 SHA256 校验和
# ========================================
echo -e "${YELLOW}→ 生成校验和...${NC}"
cd "$RELEASE_DIR"
sha256sum firmware/*.bin *.apk docker-compose.yml scripts/*.sql 2>/dev/null > SHA256SUMS.txt || true
cd ../..
echo -e "${GREEN}  ✓ SHA256SUMS.txt${NC}"

# ========================================
# 5. 生成发布说明
# ========================================
echo -e "${YELLOW}→ 生成发布说明...${NC}"
cat > "$RELEASE_DIR/README.md" << 'EOF'
# Open IoT Platform Release

## 文件说明

### 固件 (firmware/)
- esp32-servo-firmware.bin - ESP32 舵机开关固件
- esp32s3-wakeup-firmware.bin - ESP32-S3 USB 唤醒固件
- bootloader-*.bin - 引导程序
- partitions-*.bin - 分区表

### 服务端部署
- docker-compose.yml - Docker Compose 配置
- scripts/init.sql - 数据库初始化脚本

### 移动端
- iot-config-app.apk - Android 配网控制 APP

## 部署步骤

1. 烧写固件到 ESP32/ESP32-S3
2. 安装 APK 到 Android 手机
3. 上传 docker-compose.yml 和 scripts/init.sql 到服务器
4. 运行 docker compose up -d

详细文档: https://gitee.com/luoyaosheng/open-iot-platform
EOF
echo -e "${GREEN}  ✓ README.md${NC}"

# ========================================
# 6. 打包成 ZIP
# ========================================
echo -e "${YELLOW}→ 打包 ZIP...${NC}"
cd smartlink-hub/releases
rm -f "open-iot-platform-${VERSION}.zip"
zip -r "open-iot-platform-${VERSION}.zip" "$VERSION/" > /dev/null
cd ../..
echo -e "${GREEN}  ✓ $(basename "$ZIP_FILE")${NC}"

# ========================================
# 完成
# ========================================
echo ""
echo "========================================"
echo -e "${GREEN}打包完成!${NC}"
echo "========================================"
echo ""
echo "📁 发布目录: $RELEASE_DIR"
echo "📦 压缩包: $ZIP_FILE"
echo ""
echo "📋 文件清单:"
ls -lh "$RELEASE_DIR"/{firmware,scripts} 2>/dev/null | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
ls -lh "$RELEASE_DIR"/{*.yml,*.apk,*.txt,*.md} 2>/dev/null | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "⚠️  上传 Release:"
echo "  直接上传: $ZIP_FILE"
echo ""
