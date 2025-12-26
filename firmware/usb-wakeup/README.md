# ESP32-S3 USB Wakeup Device

ESP32-S3 USB 键盘模拟器 - 用于远程唤醒休眠的电脑

## 功能说明

- **BLE 配网**: 使用手机 APP 配置 WiFi 和平台地址
- **设备激活**: 自动注册到 IoT 平台
- **MQTT 控制**: 通过 MQTT 接收唤醒命令
- **USB HID**: 模拟键盘按键唤醒休眠的电脑
- **状态指示**: LED 显示当前工作状态

## 硬件

- **芯片**: ESP32-S3-N16R8 (16MB Flash + 8MB PSRAM)
- **开发板**: ESP32-S3-DevKitC-1
- **USB**: 原生 USB HID 支持

## GPIO 引脚

| 功能 | GPIO | 说明 |
|------|------|------|
| LED | 45 | 板载 RGB LED |
| 按钮 | 0 | BOOT 按钮 (长按 3 秒重置) |
| USB | - | 原生 USB 口 |

## LED 状态

| 模式 | 说明 |
|------|------|
| 常亮 | 启动/初始化 |
| 五次快闪 | BLE 配网模式 (等待 APP 连接) |
| 三次快闪 | WiFi 连接中 |
| 二次快闪 | API 激活/MQTT 连接中 |
| 慢闪 (1秒) | 正常运行 |
| 极快闪 (50ms) | 错误状态 |

## 编译和上传

```bash
cd firmware/usb-wakeup
pio run
pio run --target upload
pio device monitor
```

## 使用流程

1. **上电**: 设备自动进入 BLE 配网模式 (LED 五次快闪)
2. **配网**: 使用手机 APP 连接 BLE 设备 "IoT-Wakeup-XXXX"
3. **激活**: 设备自动连接 WiFi 并激活到平台
4. **运行**: LED 慢闪，设备就绪
5. **唤醒**: 发送 MQTT 命令唤醒电脑

## MQTT 命令格式

发送唤醒命令:

```json
{
  "method": "thing.service.property.set",
  "id": "123",
  "params": {
    "wakeup": true
  }
}
```

## BLE 配网格式

```json
{
  "ssid": "YourWiFi",
  "password": "YourPassword",
  "apiUrl": "http://192.168.1.100:48080"
}
```

## 重置配置

长按 BOOT 按钮 3 秒，LED 快速闪烁后重置所有配置。

## 开发状态

- [x] BLE 配网
- [x] WiFi 连接
- [x] 设备激活
- [x] MQTT 通信
- [x] USB HID 键盘
- [x] 状态机管理
- [x] LED 状态指示

## 作者

罗耀生

## 许可证

GPL v3
