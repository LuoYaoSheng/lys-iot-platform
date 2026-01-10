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
       "$RELEASE_DIR/firmware/esp32-servo-firmware-$VERSION.bin"
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
       "$RELEASE_DIR/firmware/esp32s3-wakeup-firmware-$VERSION.bin"
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
    cp "$APK_FILE" "$RELEASE_DIR/iot-config-app-$VERSION.apk"
    echo -e "${GREEN}  ✓ 移动端 APK${NC}"
else
    echo -e "${RED}  ⚠ APK 文件未找到，请先构建: flutter build apk${NC}"
fi

# ========================================
# 3. 收集服务端部署文件
# ========================================
echo -e "${YELLOW}→ 收集服务端部署文件...${NC}"

# docker-compose (生产环境) - 需要修改 init.sql 路径
cp server/docker-compose.yml "$RELEASE_DIR/docker-compose.yml"
# 修改 docker-compose.yml 中的 init.sql 路径
sed -i 's|./scripts/init.sql:|./scripts/init.sql:|' "$RELEASE_DIR/docker-compose.yml"
echo -e "${GREEN}  ✓ docker-compose.yml${NC}"

# 数据库初始化脚本 - 放在 scripts/ 目录下
cp server/scripts/init.sql "$RELEASE_DIR/scripts/init.sql"
echo -e "${GREEN}  ✓ scripts/init.sql${NC}"

# ========================================
# 4. 生成 SHA256 校验和
# ========================================
echo -e "${YELLOW}→ 生成校验和...${NC}"
cd "$RELEASE_DIR"
sha256sum firmware/*.bin iot-config-app-*.apk docker-compose.yml scripts/*.sql 2>/dev/null > SHA256SUMS.txt || true
cd ../..
echo -e "${GREEN}  ✓ SHA256SUMS.txt${NC}"

# ========================================
# 5. 生成发布说明
# ========================================
echo -e "${YELLOW}→ 生成发布说明...${NC}"
cat > "$RELEASE_DIR/README.md" << EOF
# Open IoT Platform $VERSION 发布

**发布日期**: $(date +%Y-%m-%d)
**作者**: 罗耀生

---

## 📦 文件清单

### 固件文件
| 文件 | 说明 | 烧写地址 |
|------|------|----------|
| esp32-servo-firmware-$VERSION.bin | ESP32 舵机开关固件 | 0x10000 |
| bootloader-esp32.bin | ESP32 引导程序 | 0x1000 |
| partitions-esp32.bin | ESP32 分区表 | 0x8000 |
| esp32s3-wakeup-firmware-$VERSION.bin | ESP32-S3 USB 唤醒固件 | 0x10000 |
| bootloader-esp32s3.bin | ESP32-S3 引导程序 | 0x1000 |
| partitions-esp32s3.bin | ESP32-S3 分区表 | 0x8000 |

### 移动端
| 文件 | 说明 |
|------|------|
| iot-config-app-$VERSION.apk | Android 配网控制 APP |

### 服务端部署
| 文件 | 说明 |
|------|------|
| docker-compose.yml | Docker Compose 配置 |
| scripts/init.sql | 数据库初始化脚本 |

---

## 🚀 快速部署

### 1. 烧写固件
使用 Flash Download Tool 烧写对应固件

### 2. 安装 APP
直接安装 APK 到 Android 手机

### 3. 部署服务端
\\\`\\\`\\\`bash
# 上传以下文件到服务器:
# - docker-compose.yml
# - scripts/init.sql
#
# 然后执行:
docker compose up -d
\\\`\\\`\\\`

---

## 📖 详细文档

- [产品需求文档](../../docs/PRD.md)
- [API 接口文档](../../docs/API_REFERENCE.md)
- [设备统一规范](../../docs/DEVICE_UNIFIED_SPEC.md)

---

**仓库**: https://gitee.com/luoyaosheng/open-iot-platform
EOF
echo -e "${GREEN}  ✓ README.md${NC}"

# ========================================
# 完成
# ========================================
echo ""
echo "========================================"
echo -e "${GREEN}打包完成!${NC}"
echo "========================================"
echo ""
echo "📁 发布目录: $RELEASE_DIR"
echo ""
echo "📋 文件清单:"
ls -lh "$RELEASE_DIR"/{firmware,scripts} 2>/dev/null | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
ls -lh "$RELEASE_DIR"/{*.yml,*.apk,*.txt} 2>/dev/null | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "⚠️  提示:"
echo "  1. 检查 APK 文件是否存在"
echo "  2. 检查固件文件是否为最新版本"
echo "  3. 在 GitHub/Gitee Release 中上传这些文件"
echo ""
