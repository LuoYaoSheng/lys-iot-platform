#!/bin/bash
# 从SVG生成不同颜色的PNG图标
# 需要安装ImageMagick

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TABBAR_DIR="$SCRIPT_DIR"

# 颜色配置
NORMAL_COLOR='#C7C7CC'
ACTIVE_COLOR='#007AFF'

# 清理旧图标
rm -f "$TABBAR_DIR"/{device,profile,device-active,profile-active}.png

# 设备图标 - 灰色 (未选中)
convert -background none -fill "$NORMAL_COLOR" \
    "$TABBAR_DIR/device.svg" \
    -resize 48x48 "$TABBAR_DIR/device.png"

# 设备图标 - 蓝色 (选中)
convert -background none -fill "$ACTIVE_COLOR" \
    "$TABBAR_DIR/device.svg" \
    -resize 48x48 "$TABBAR_DIR/device-active.png"

# 我的图标 - 灰色 (未选中)
convert -background none -fill "$NORMAL_COLOR" \
    "$TABBAR_DIR/profile.svg" \
    -resize 48x48 "$TABBAR_DIR/profile.png"

# 我的图标 - 蓝色 (选中)
convert -background none -fill "$ACTIVE_COLOR" \
    "$TABBAR_DIR/profile.svg" \
    -resize 48x48 "$TABBAR_DIR/profile-active.png"

echo "✓ Tabbar icons created successfully"
echo "  - device.png (灰色)"
echo "  - device-active.png (蓝色)"
echo "  - profile.png (灰色)"
echo "  - profile-active.png (蓝色)"
