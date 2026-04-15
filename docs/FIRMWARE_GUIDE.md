# 固件开发指南

> Open IoT Platform 支持 ESP32 和 ESP32-S3 两种硬件平台，提供智能开关和 USB 唤醒两种固件。

## 支持的硬件

| 芯片 | 开发板 | Flash | PSRAM | 用途 |
|------|-------|-------|-------|------|
| ESP32-WROOM-32E | ESP32-DevKitC | 4MB | 520KB SRAM | 智能开关（舵机控制） |
| ESP32-S3-N16R8 | ESP32-S3-DevKitC-1 | 16MB | 8MB | USB HID 键盘唤醒 |

## 开发环境搭建

### 安装 PlatformIO

1. 安装 [VS Code](https://code.visualstudio.com/)
2. 安装 [PlatformIO IDE 插件](https://platformio.org/install/ide?install=vscode)
3. 安装完成后再终端可用 `pio` 命令

### 验证安装

```bash
pio --version
# PlatformIO Core, version 6.x
```

## 两种固件概述

### 1. 智能开关固件 (`firmware/switch/`)

使用 SG90 舵机物理按压墙壁开关，实现灯光远程控制。

**核心功能**：
- WiFi 连接 + MQTT 通信
- 接收开关指令 → 控制舵机按压
- 上报设备状态
- BLE 配网支持

**硬件清单**：

| 组件 | 型号 | 说明 |
|------|------|------|
| Wi-Fi 模块 | ESP32-WROOM-32E | 核心控制器 |
| 舵机 | SG90 | 物理按压执行器 |
| 电源 | 5V/2A USB 充电器 | 供电 |

### 2. USB 唤醒固件 (`firmware/usb-wakeup/`)

ESP32-S3 模拟 USB HID 键盘，通过 MQTT 命令远程唤醒休眠的电脑。

**核心功能**：
- USB HID 键盘模拟
- BLE 配网
- MQTT 命令接收
- 状态机管理

**硬件特点**：
- ESP32-S3 原生 USB 支持（无需额外芯片）
- 16MB Flash + 8MB PSRAM

## BLE 配网协议

### 蓝牙广播

设备上电后自动进入配网模式（LED 五次快闪），广播名称格式：

```
IoT-Switch-XXXX   (智能开关)
IoT-Wakeup-XXXX   (USB 唤醒)
```

其中 `XXXX` 为设备 MAC 后四位。

### 配网数据格式

通过 BLE GATT 写入的 JSON 数据：

```json
{
  "ssid": "YourWiFi",
  "password": "YourPassword",
  "apiUrl": "http://192.168.1.100:48080"
}
```

### 配网流程

```
APP                          ESP32 设备
 │                              │
 │── BLE 扫描 ─────────────────→│ 广播: IoT-Switch-XXXX
 │── BLE 连接 ─────────────────→│ 建立 GATT 连接
 │── 写入 WiFi 信息 ───────────→│ {ssid, password, apiUrl}
 │                              │── 连接 WiFi
 │                              │── 注册到服务端
 │                              │── 连接 MQTT Broker
 │←── 配网完成通知 ─────────────│ 设备上线
```

## MQTT 通信协议

### Topic 规范

| Topic | 方向 | 说明 |
|-------|------|------|
| `device/{productKey}/{deviceId}/data/up` | 设备 → 服务端 | 属性上报 |
| `device/{productKey}/{deviceId}/cmd/down` | 服务端 → 设备 | 指令下发 |

### 连接凭证

```
username: {productKey}&{deviceId}
password: {deviceSecret}
```

### 控制指令格式

服务端下发的控制指令：

```json
{
  "method": "thing.service.property.set",
  "id": "123",
  "params": {
    "wakeup": true
  }
}
```

### 状态上报格式

设备上报的属性数据：

```json
{
  "id": "123",
  "params": {
    "position": 90,
    "status": "on"
  },
  "timestamp": 1705312000000
}
```

## GPIO 引脚定义

### ESP32 智能开关

| GPIO | 功能 | 说明 |
|------|------|------|
| GPIO18 | 舵机 PWM 信号 | ⭐ 推荐，无启动限制 |
| GPIO2 | 板载 LED | 状态指示 |
| GPIO0 | BOOT 按键 | 长按 3 秒重置配网 |

**禁止使用的引脚**：
- GPIO6-11：连接内置 SPI Flash
- GPIO34-39：仅输入，无内部上拉

**启动有限制的引脚（Strapping Pins）**：
- GPIO0, 2, 5, 12, 15：启动时电平有要求

### ESP32-S3 USB 唤醒

| GPIO | 功能 | 说明 |
|------|------|------|
| GPIO45 | 板载 RGB LED | 状态指示 |
| GPIO0 | BOOT 按钮 | 长按 3 秒重置 |
| USB | 原生 USB | HID 键盘通信 |

### LED 状态码

| 模式 | 含义 |
|------|------|
| 常亮 | 启动/初始化中 |
| 五次快闪 | BLE 配网模式 |
| 三次快闪 | WiFi 连接中 |
| 二次快闪 | API 激活/MQTT 连接中 |
| 慢闪（1秒） | 正常运行 |
| 极快闪（50ms） | 错误状态 |

## 烧写指南

### PlatformIO 烧写

```bash
# 智能开关
cd firmware/switch
pio run -t upload
pio device monitor    # 查看串口日志

# USB 唤醒
cd firmware/usb-wakeup
pio run -t upload
```

### ESP Flash Download Tool 烧写

使用 [Flash Download Tool](https://www.espressif.com/zh-hans/support/download/other-tools)：

| 文件 | 芯片 | 烧写地址 |
|------|------|---------|
| esp32-servo-firmware.bin | ESP32 | 0x10000 |
| bootloader-esp32.bin | ESP32 | 0x1000 |
| partitions-esp32.bin | ESP32 | 0x8000 |
| esp32s3-wakeup-firmware.bin | ESP32-S3 | 0x10000 |
| bootloader-esp32s3.bin | ESP32-S3 | 0x1000 |
| partitions-esp32s3.bin | ESP32-S3 | 0x8000 |

### 首次使用建议

```bash
# 清除 NVS（推荐首次烧写前执行）
esptool --chip esp32 erase-flash
# 或指定端口
esptool --chip esp32 --port /dev/ttyUSB0 erase-flash
```

## 依赖库

### 智能开关

```ini
lib_deps =
    knolleary/PubSubClient @ ^2.8       # MQTT 客户端
    bblanchon/ArduinoJson @ ^6.21.3     # JSON 解析
    madhephaestus/ESP32Servo @ ^1.1.1   # 舵机控制
```

### USB 唤醒

```ini
lib_deps =
    knolleary/PubSubClient @ ^2.8
    bblanchon/ArduinoJson @ ^6.21.3
```

## 注意事项

1. **ESP32-S3 USB 唤醒设备**：USB HID 模式下无法使用 USB 串口，请使用硬件串口查看日志
2. **首次使用**：建议先 `esptool --erase-flash` 清除 NVS 后重新配网
3. **舵机供电**：SG90 峰值电流 500mA，确保与 ESP32 共地，从 5V 电源直接供电
4. **GPIO18**：推荐作为舵机 PWM 引脚，无启动限制

## 相关文档

- [设备统一规范](/DEVICE_UNIFIED_SPEC) — 设备接入标准
- [配置链路](/CONFIGURATION_CHAIN) — 从固件到服务端的完整配置链
- [数据流架构](/ARCHITECTURE_DATA_FLOW) — 全链路数据流说明
- [移动端配网指南](/MOBILE_APP_GUIDE) — APP 配网操作说明
