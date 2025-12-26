# iot-device/firmware-switch

> ESP32 智能开关固件 - 使用 SG90 舵机物理模拟开关控制

**作者**: 罗耀生
**硬件**: ESP32-WROOM-32E (38引脚模块) + SG90 舵机
**开发环境**: PlatformIO
**创建时间**: 2025-12-13

---

## 📋 项目概述

使用 ESP32-WROOM-32E Wi-Fi 模块和 SG90 舵机，通过物理按压墙壁开关的方式实现远程控制灯光。

**核心功能**:
- ✅ 连接 Wi-Fi
- ✅ 连接 IoT 平台 (MQTT)
- ✅ 接收开关指令
- ✅ 控制舵机按压开关
- ✅ 上报设备状态

---

## 🔌 硬件配置

### 硬件清单

| 组件 | 型号/规格 | 数量 | 说明 |
|------|----------|------|------|
| **Wi-Fi 模块** | ESP32-WROOM-32E | 1 | 核心控制器（25+个可用GPIO） |
| **舵机** | SG90 | 1 | 物理按压执行器 |
| **电源** | 5V/2A USB充电器 | 1 | 供电 |
| **连接线** | 杜邦线 | 若干 | - |

### ESP32-WROOM-32E 引脚配置

```
推荐 GPIO 配置:
  GPIO18 → SG90 PWM 信号（推荐⭐⭐⭐⭐⭐，无启动限制）
  GPIO2  → 板载 LED 状态指示
  GPIO0  → SmartConfig 配网按键（BOOT键）

禁止使用的引脚:
  GPIO6-11  → 连接内置 SPI Flash，禁止使用！
  GPIO34-39 → 仅输入，无内部上拉/下拉

启动有限制的引脚 (Strapping Pins):
  GPIO0, 2, 5, 12, 15 → 启动时电平有要求

详细引脚说明请参考: docs/ESP32-GPIO-Guide.md
```

### 电路连接图

```
USB 5V 充电器
    │
    ├──→ ESP32 VIN (5V输入)
    ├──→ SG90 VCC (红线)
    └──→ GND (共地)
             ├──→ ESP32 GND
             └──→ SG90 GND (棕线)

ESP32 GPIO18 ──→ SG90 Signal (橙线)
ESP32 GPIO2  ──→ 板载 LED（状态指示）
ESP32 GPIO0  ──→ BOOT按键（配网）
```

### ⚠️ 重要提示

1. **GPIO 选择**: 使用 **GPIO18** 作为舵机控制引脚（无启动限制，最安全）
2. **供电方案**: ESP32 开发板通常有板载稳压，直接 USB 5V 供电即可
3. **舵机供电**: SG90 峰值电流 500mA，从 5V 电源直接供电，确保与 ESP32 共地
4. **信号兼容**: ESP32 输出 3.3V PWM，SG90 可以识别（兼容 3.3V/5V）
5. **BOOT按键配网**: 长按 BOOT 按键 3 秒进入 SmartConfig 配网模式

---

## 🏗️ 固件架构

### 目录结构

```
iot-device/firmware-switch/
├── README.md                   # 本文件
├── docs/                       # 文档
│   ├── ESP32-GPIO-Guide.md     # ESP32 GPIO 使用指南
│   ├── hardware-design.md      # 硬件设计文档
│   └── protocol.md             # 通信协议
├── include/                    # 头文件
│   └── config.h                # 配置文件
├── src/                        # 源代码
│   └── main.cpp                # 主程序
└── platformio.ini              # PlatformIO 配置
```

---

## 🔧 开发环境配置

### PlatformIO (推荐)

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino

lib_deps =
    knolleary/PubSubClient @ ^2.8
    bblanchon/ArduinoJson @ ^6.21.3
    madhephaestus/ESP32Servo @ ^1.1.1

upload_speed = 921600
monitor_speed = 115200
```

---

## 💻 核心代码示例

### 舵机控制 (ESP32)

```cpp
#include <ESP32Servo.h>

#define SERVO_PIN 18  // GPIO18（推荐）

Servo servo;

void setup() {
  ESP32PWM::allocateTimer(0);
  servo.setPeriodHertz(50);
  servo.attach(SERVO_PIN, 500, 2400);
  servo.write(0);  // 初始位置
}

// 模拟按压开关
void pressSwitch() {
  servo.write(90);   // 按下
  delay(500);
  servo.write(0);    // 回位
  delay(500);
}
```

### MQTT 连接 (ESP32)

```cpp
#include <PubSubClient.h>
#include <WiFi.h>

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

void setup() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  mqttClient.setServer(MQTT_SERVER, MQTT_PORT);
  mqttClient.setCallback(mqttCallback);
}
```

---

## 📊 ESP32 vs ESP8266 对比

| 特性 | ESP32-WROOM-32E | ESP8266 (ESP-01) |
|------|-----------------|------------------|
| **可用 GPIO** | 25+ 个 | 2 个 |
| **CPU** | 双核 240MHz | 单核 80MHz |
| **内存** | 520KB SRAM | 64KB |
| **Flash** | 4MB+ | 1MB |
| **蓝牙** | ✅ BLE 4.2 | ❌ |
| **舵机限制** | 无 | 有启动限制 |

---

## 🚀 快速开始

1. **克隆项目**
   ```bash
   git clone https://gitee.com/luoyaosheng/iot-device/firmware-switch.git
   ```

2. **修改配置** (`include/config.h`)
   ```cpp
   #define WIFI_SSID        "your-wifi-ssid"
   #define WIFI_PASSWORD    "your-wifi-password"
   #define MQTT_SERVER      "mqtt.yourplatform.com"
   ```

3. **编译烧录**
   ```bash
   pio run -t upload
   ```

4. **监控串口**
   ```bash
   pio device monitor
   ```

---

## 📄 参考资料

- [ESP32-WROOM-32E Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_en.pdf)
- [ESP32 Pinout Reference](https://randomnerdtutorials.com/esp32-pinout-reference-gpios/)
- [ESP32Servo Library](https://github.com/madhephaestus/ESP32Servo)

---

## 📞 技术支持

**作者**: 罗耀生
**项目地址**: https://gitee.com/luoyaosheng/iot-device/firmware-switch

---

**让我们开始构建第一个智能设备！** 🎉
