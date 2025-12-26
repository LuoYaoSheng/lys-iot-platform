# IoT SmartLink Hub - v0.1.0 Release

**发布日期**: 2025-12-19
**版本类型**: 首个稳定版本 (MVP)

---

## 📦 包含文件

| 文件名 | 大小 | SHA256 | 说明 |
|--------|------|--------|------|
| `iot-config-app-v0.1.0.apk` | 51.4 MB | - | Android 配网 APP |
| `esp32-firmware-v0.1.0.bin` | 1.7 MB | - | ESP32 主固件 |
| `bootloader.bin` | 18 KB | - | ESP32 引导程序 |
| `partitions.bin` | 3 KB | - | ESP32 分区表 |

---

## 📱 Android APP

### 功能特性

- ✅ BLE 蓝牙配网
- ✅ WiFi 参数配置
- ✅ 设备远程控制 (Toggle/Pulse 模式)
- ✅ 设备状态实时显示
- ✅ 多设备管理
- ✅ 自定义服务器地址

### 系统要求

- Android 7.0 (API 24) 及以上
- 支持蓝牙 4.0 (BLE)

### 安装方法

1. 下载 `iot-config-app-v0.1.0.apk`
2. 在手机上开启"允许安装未知来源应用"
3. 点击 APK 文件安装
4. 打开 APP,注册账号即可使用

---

## 🔌 ESP32 固件

### 硬件支持

- **芯片**: ESP32-WROOM-32E
- **控制器**: SG90 舵机 (180°/360°)
- **通信**: BLE + WiFi + MQTT

### 功能特性

- ✅ BLE 配网
- ✅ WiFi 连接管理
- ✅ MQTT 通信
- ✅ Toggle 模式 (位置切换)
- ✅ Pulse 模式 (脉冲触发,可配置延迟)
- ✅ 状态上报
- ✅ OTA 升级支持

### 烧录方法

#### 方法 1: 使用 ESP32 Flash Download Tools (Windows)

1. 下载烧录工具: https://www.espressif.com/en/support/download/other-tools
2. 打开工具,选择 ESP32 芯片
3. 配置烧录参数:
   ```
   bootloader.bin    --> 0x1000
   partitions.bin    --> 0x8000
   esp32-firmware-v0.1.0.bin --> 0x10000
   ```
4. 选择串口,波特率 115200
5. 点击"开始"烧录

#### 方法 2: 使用 esptool.py (跨平台)

```bash
# 安装 esptool
pip install esptool

# 烧录固件
esptool.py --chip esp32 --port COM3 --baud 115200 \
  --before default_reset --after hard_reset write_flash \
  -z --flash_mode dio --flash_freq 40m --flash_size detect \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 esp32-firmware-v0.1.0.bin
```

注意: 将 `COM3` 替换为你的实际串口号

---

## 🔗 相关链接

- **产品落地页**: [landing-page/index.html](../../landing-page/index.html)
- **视频教程**: [B站教程合集](https://space.bilibili.com/your-channel)
- **问题反馈**: https://gitee.com/luoyaosheng/iot-smartlink-hub/issues

---

## 🐛 已知问题

### APP

1. 部分 Android 12+ 设备配网时可能需要手动授权蓝牙权限
2. 首次配网可能需要重启 APP

### 固件

1. 配网失败后需手动重启设备
2. WiFi 密码错误不会自动提示

---

## 🔄 升级说明

### 从此版本升级

暂无,这是首个版本

---

## 📞 技术支持

遇到问题?
1. 查看[常见问题](../../README.md#常见问题)
2. 观看[视频教程](https://space.bilibili.com/your-channel)
3. [提交 Issue](https://gitee.com/luoyaosheng/iot-smartlink-hub/issues)

---

**作者**: 罗耀生
**发布时间**: 2025-12-19
