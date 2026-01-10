# Open IoT Platform - 发布指南

**作者**: 罗耀生
**日期**: 2026-01-10
**版本**: v1.0

---

## 📦 Release 包含内容

### 1. 固件文件

| 文件 | 说明 | 芯片 |
|------|------|------|
| esp32-servo-firmware-{version}.bin | ESP32 舵机开关固件 | ESP32-WROOM-32E |
| bootloader-esp32.bin | ESP32 引导程序 | ESP32 |
| partitions-esp32.bin | ESP32 分区表 | ESP32 |
| esp32s3-wakeup-firmware-{version}.bin | ESP32-S3 USB 唤醒固件 | ESP32-S3-N16R8 |
| bootloader-esp32s3.bin | ESP32-S3 引导程序 | ESP32-S3 |
| partitions-esp32s3.bin | ESP32-S3 分区表 | ESP32-S3 |

### 2. 移动端 APP

| 文件 | 说明 |
|------|------|
| iot-config-app-{version}.apk | Android 配网控制 APP |

### 3. 服务端部署文件

| 文件 | 说明 |
|------|------|
| docker-compose.yml | Docker Compose 配置 |
| init.sql | 数据库初始化脚本 |

---

## 🚀 打包步骤

### 1. 编译固件

```bash
# ESP32 舵机开关
cd firmware/switch
pio run

# ESP32-S3 USB 唤醒
cd ../usb-wakeup
pio run
```

### 2. 编译 APP

```bash
cd mobile-app
flutter build apk --release
```

### 3. 运行打包脚本

```bash
cd /path/to/open-iot-platform
./release.sh v0.3.0
```

脚本会自动：
- 收集固件文件到 `releases/v0.3.0/firmware/`
- 收集 APK 文件到 `releases/v0.3.0/`
- 收集服务端文件到 `releases/v0.3.0/server/`
- 生成 SHA256 校验和
- 生成发布说明 README

---

## 📤 发布到 GitHub/Gitee

### 方式一：通过网页上传

1. 访问 [GitHub Releases](https://github.com/LuoYaoSheng/open-iot-platform/releases)
2. 点击 "Draft a new release"
3. 填写标签版本 (如 `v0.3.0`)
4. 上传 `releases/v0.3.0/` 目录下的所有文件
5. 发布

### 方式二：使用 gh 命令行工具

```bash
# 安装 gh cli 后
gh release create v0.3.0 releases/v0.3.0/* \
  --title "v0.3.0" \
  --notes "Release notes here"
```

---

## 📋 Release 检查清单

发布前确认：

- [ ] 固件已更新版本号
- [ ] APP 版本号已更新
- [ ] 固件编译成功
- [ ] APP 编译成功
- [ ] SHA256 校验和已生成
- [ ] README 说明已更新
- [ ] 测试所有功能正常

---

## 🔗 相关链接

- GitHub Releases: https://github.com/LuoYaoSheng/open-iot-platform/releases
- Gitee Releases: https://gitee.com/luoyaosheng/open-iot-platform/releases

---

## 📝 版本历史

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-01-10 | v0.3.0 | 内置 MQTT Broker，动态控制面板 |
| 2026-01-07 | v0.2.0 | 新增 USB 唤醒设备 |
| 2025-12-20 | v0.1.0 | 初始版本 |
