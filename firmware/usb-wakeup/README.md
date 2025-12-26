# ESP32-S3 USB Wakeup Device

ESP32-S3 USB 键盘模拟器 - 用于远程唤醒休眠的电脑

## 功能说明

- 通过 MQTT 接收唤醒命令
- 使用 USB HID 模拟键盘按键唤醒电脑
- BLE 配网支持
- 设备自动注册和激活

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
| 慢闪 (1秒) | 正常运行 |
| 快闪 (200ms) | WiFi/MQTT 连接中 |
| 快闪 (50ms) | 错误状态 |

## 编译和上传

```bash
cd firmware/usb-wakeup
pio run
pio run --target upload
pio device monitor
```

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

发送指定按键:

```json
{
  "method": "thing.service.property.set",
  "id": "123",
  "params": {
    "key": "SPACE"
  }
}
```

发送组合键:

```json
{
  "method": "thing.service.property.set",
  "id": "123",
  "params": {
    "key_combo": "CTRL+SHIFT+ESC"
  }
}
```

## 重置配置

长按 BOOT 按钮 3 秒，LED 快速闪烁后重置所有配置。

## 开发状态

- [x] 基础框架
- [x] USB HID 键盘
- [x] MQTT 连接
- [x] 状态机管理
- [ ] BLE 配网 (TODO)
- [ ] 设备激活 (TODO)
- [ ] 完整按键支持 (TODO)

## 作者

罗耀生

## 许可证

GPL v3
