# IoT SmartLink Hub v0.2.0 发布

## 📦 下载文件

### Android APP
- **文件**: iot-config-app-v0.2.0.apk
- **大小**: 97 MB
- **下载**: [smartlink-hub/releases/v0.2.0/iot-config-app-v0.2.0.apk](https://gitee.com/luoyaosheng/open-iot-platform/raw/feature/embedded-mqtt/smartlink-hub/releases/v0.2.0/iot-config-app-v0.2.0.apk)

### ESP32 舵机开关固件
- **芯片**: ESP32-WROOM-32E
- **固件**: esp32-servo-firmware-v0.2.0.bin (1.64 MB)
- **引导**: bootloader-esp32.bin (17 KB)
- **分区**: partitions-esp32.bin (3 KB)

### ESP32-S3 USB 唤醒固件
- **芯片**: ESP32-S3-N16R8
- **固件**: esp32s3-wakeup-firmware-v0.2.0.bin (1.46 MB)
- **引导**: bootloader-esp32s3.bin (15 KB)
- **分区**: partitions-esp32s3.bin (3 KB)

---

## ✨ 更新内容

### 新增
- 🆕 支持 ESP32-S3 USB 唤醒设备
- 🎨 APP 新增 USB 唤醒专用控制面板

### 修复
- 🐛 修复舵机启动大幅度旋转问题
- 🐛 修复设备列表加载类型转换错误
- 🐛 修复 USB HID 初始化问题

### 服务端
- 集成 Redis 实现设备在线状态实时管理
- 内置 MQTT Broker 替代 EMQX

---

## 📖 快速开始

### 1. 安装 APP
下载 APK 安装到 Android 手机

### 2. 烧写固件
使用 Flash Download Tool 烧写对应固件

### 3. BLE 配网
打开 APP 添加设备，输入 WiFi 密码完成配网

---

## 📂 完整文件列表

访问 [smartlink-hub/releases/v0.2.0/](https://gitee.com/luoyaosheng/open-iot-platform/tree/feature/embedded-mqtt/smartlink-hub/releases/v0.2.0/) 下载所有文件
