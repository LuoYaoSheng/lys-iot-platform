# IoT SmartLink Hub v0.2.0 发布

**发布日期**: 2026-01-10

## 📦 下载文件

| 文件 | 大小 | 说明 |
|------|------|------|
| **iot-config-app-v0.2.0.apk** | 97 MB | Android 配网控制 APP |
| **esp32-servo-firmware-v0.2.0.bin** | 1.64 MB | ESP32 舵机开关固件 |
| **esp32s3-wakeup-firmware-v0.2.0.bin** | 1.46 MB | ESP32-S3 USB唤醒固件 |
| **bootloader-esp32.bin** | 17 KB | ESP32 引导程序 |
| **bootloader-esp32s3.bin** | 15 KB | ESP32-S3 引导程序 |
| **partitions-esp32.bin** | 3 KB | ESP32 分区表 |
| **partitions-esp32s3.bin** | 3 KB | ESP32-S3 分区表 |

---

## 🎯 支持的设备

### 1. ESP32 舵机开关
- **芯片**: ESP32-WROOM-32E
- **功能**: 舵机控制、三位置开关（上/中/下）
- **配网**: BLE WiFi 配网

### 2. ESP32-S3 USB 唤醒设备
- **芯片**: ESP32-S3-N16R8 (16MB Flash + 8MB PSRAM)
- **功能**: USB HID 键盘唤醒电脑
- **配网**: BLE WiFi 配网

---

## ✨ v0.2.0 更新内容

### APP
- 新增 USB 唤醒设备专用控制面板
- 设备列表位置字段仅对舵机设备显示
- 修复设备列表加载类型转换错误

### 固件
- **舵机设备**: 启动时舵机归位到中间位置，避免大幅度旋转
- **USB唤醒设备**: 修复 USB HID 初始化问题，使用 F13 功能键唤醒

### 服务端
- 集成 Redis 实现设备在线状态实时管理
- 内置 MQTT Broker 替代 EMQX

---

## 📖 快速开始

### 1. 安装 APP
直接下载 `iot-config-app-v0.2.0.apk` 安装到 Android 手机

### 2. 烧写固件

**ESP32 舵机开关**:
- 使用 Flash Download Tool 烧写
- 固件地址: 0x10000
- bootloader: 0x1000
- partitions: 0x8000

**ESP32-S3 USB 唤醒**:
- 使用 Flash Download Tool 烧写
- 固件地址: 0x10000
- bootloader: 0x1000
- partitions: 0x8000

### 3. BLE 配网
1. 打开 APP，点击"添加设备"
2. 选择设备进行配网
3. 输入 WiFi 密码
4. 等待配网成功

---

## ⚠️ 注意事项

1. **ESP32-S3 USB 唤醒设备**: USB HID 模式下无法使用 USB 串口，请使用硬件串口 (GPIO43/44) 查看日志
2. **首次使用**: 建议先清除 NVS (`esptool --erase-flash`) 重新配网
3. **APK 安装**: 如安装失败，请先卸载旧版本

---

**作者**: 罗耀生
**更新**: 2026-01-10
