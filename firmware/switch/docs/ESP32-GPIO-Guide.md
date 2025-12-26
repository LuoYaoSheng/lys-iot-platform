# ESP32-WROOM-32E GPIO 使用指南

**芯片型号**: ESP32-WROOM-32E
**可用 GPIO**: 25+ 个
**作者**: 罗耀生
**日期**: 2025-12-13

**参考资料**:
- [ESP32-WROOM-32E Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_en.pdf)
- [Random Nerd Tutorials - ESP32 Pinout](https://randomnerdtutorials.com/esp32-pinout-reference-gpios/)

---

## 📋 引脚功能总览

### 推荐用于舵机的 GPIO

根据官方文档和社区最佳实践，以下引脚推荐用于舵机 PWM 控制：

```
推荐引脚: 2, 4, 12-19, 21-23, 25-27, 32-33

⭐⭐⭐⭐⭐ 最佳选择:
  GPIO18 - 无启动限制，支持 PWM，本项目使用
  GPIO13 - 常用于教程示例
  GPIO26 - 另一个常用选择
```

---

## ✅ 推荐使用的 GPIO

### GPIO18 (本项目使用 ⭐⭐⭐⭐⭐)

**特性**:
- ✅ 启动时无特殊要求
- ✅ 支持 PWM (LEDC)
- ✅ 支持中断
- ✅ 无任何限制

**推荐用途**: **舵机 PWM 控制**（最佳选择）

```cpp
#define SERVO_PIN 18
ESP32PWM::allocateTimer(0);
servo.setPeriodHertz(50);
servo.attach(SERVO_PIN, 500, 2400);
```

### GPIO4, GPIO13, GPIO14, GPIO16, GPIO17, GPIO19, GPIO21-23, GPIO25-27, GPIO32-33

**特性**:
- ✅ 启动时无特殊要求
- ✅ 支持 PWM
- ✅ 支持中断
- ✅ 通用 I/O

---

## ⚠️ 需要注意的 GPIO (Strapping Pins)

### GPIO0 (BOOT 引脚)

**启动模式**:
- **高电平** → 正常运行 (SPI Boot)
- **低电平** → 下载模式 (UART Download)

**特性**:
- ⚠️ 启动时必须为高电平
- ⚠️ 通常连接到 BOOT 按键
- ✅ 启动后可正常使用

**推荐用途**: **SmartConfig 配网按键**

```cpp
#define CONFIG_BUTTON 0
pinMode(CONFIG_BUTTON, INPUT_PULLUP);
```

### GPIO2 (启动模式 + LED)

**特性**:
- ⚠️ 启动时必须为低电平或悬空
- ⚠️ 通常连接到板载 LED
- ✅ 启动后可正常使用

**推荐用途**: **状态指示 LED**

```cpp
#define LED_BUILTIN 2
pinMode(LED_BUILTIN, OUTPUT);
```

### GPIO5 (启动模式)

**特性**:
- ⚠️ 启动时必须为高电平
- ⚠️ 控制 SDIO 时序
- ✅ 启动后可正常使用

### GPIO12 (MTDI - 启动模式)

**特性**:
- ⚠️ 启动时必须为低电平
- ⚠️ 控制 VDD_SDIO 电压
- ⚠️ 高电平会导致 Flash 供电错误

**不推荐用于外部上拉的输入**

### GPIO15 (MTDO - 启动模式)

**特性**:
- ⚠️ 启动时必须为高电平
- ⚠️ 控制调试日志输出
- ✅ 启动后可正常使用

---

## ❌ 禁止使用的 GPIO

### GPIO6, 7, 8, 9, 10, 11 (SPI Flash 接口)

**原因**:
- ❌ 这些引脚连接到内置 SPI Flash
- ❌ 使用会导致程序崩溃或无法启动

**标识**: SCK, SDO, SDI, SHD, SWP, SCS

**严禁使用**❗

---

## 📥 仅输入的 GPIO

### GPIO34, 35, 36 (VP), 39 (VN)

**特性**:
- ❌ 只能做输入，不能做输出
- ❌ 无内部上拉/下拉电阻
- ✅ 可用于 ADC 输入
- ✅ 可用于外部中断

**适用场景**: 传感器输入、按键检测（需外部上拉）

---

## 🎯 智能开关项目 GPIO 配置

### 当前配置方案

```cpp
// 主要功能
#define SERVO_PIN        18   // 舵机 PWM 控制（推荐）
#define LED_BUILTIN      2    // 状态指示 LED
#define CONFIG_BUTTON    0    // SmartConfig 配网按键 (BOOT)

// 扩展功能（预留）
#define SERVO2_PIN       19   // 第二个舵机（可选）
#define SENSOR_PIN       32   // 温湿度传感器
#define RELAY_PIN        33   // 继电器控制
```

### 完整接线图

```
ESP32-WROOM-32E 开发板
┌────────────────────────────────┐
│  3.3V   GND   VIN              │
│                                │
│  GPIO18 ────────→ SG90 Signal  │  舵机控制
│  GPIO2  ←──────── 板载 LED      │  状态指示
│  GPIO0  ←──────── BOOT 按键     │  配网按键
│                                │
│  GPIO19 ────────→ (预留)       │  扩展
│  GPIO32 ────────→ (预留)       │  传感器
│  GPIO33 ────────→ (预留)       │  继电器
└────────────────────────────────┘

SG90 舵机
┌──────────┐
│ VCC  ←─── 5V 独立供电 (红线)
│ GND  ←─── GND 共地 (棕线)
│ Signal ← GPIO18 (橙线)
└──────────┘
```

---

## 🔧 ESP32Servo 库使用

### 初始化配置

```cpp
#include <ESP32Servo.h>

Servo myServo;

void setup() {
  // 分配定时器（ESP32 有 4 个定时器可用）
  ESP32PWM::allocateTimer(0);
  
  // 设置 PWM 频率（舵机标准 50Hz）
  myServo.setPeriodHertz(50);
  
  // 连接舵机，设置脉宽范围
  myServo.attach(18, 500, 2400);  // GPIO18, 500-2400μs
  
  myServo.write(0);  // 初始位置
}
```

### 舵机控制

```cpp
void pressSwitch() {
  myServo.write(90);  // 按下
  delay(500);
  myServo.write(0);   // 回位
  delay(500);
}
```

---

## ⚡ 电气特性

### 输出特性

- **最大输出电流**: 40mA (单个引脚，绝对最大值)
- **推荐输出电流**: 20mA (单个引脚)
- **总输出电流**: 不超过 1200mA
- **输出电压**: 3.3V
- **不能直接驱动**: 大功率负载（需要三极管/MOS管驱动）

### PWM 特性

```cpp
// ESP32 LEDC (PWM) 参数
// 分辨率: 1-16 位
// 频率: 取决于分辨率

// 舵机控制使用 ESP32Servo 库
// 库会自动配置正确的 PWM 参数
```

---

## 🔍 常见问题

### Q1: 为什么选择 GPIO18 而不是其他引脚？

**原因**:
- GPIO18 没有任何启动限制
- 不是 Strapping Pin
- 完全支持 PWM 输出
- 社区广泛使用，兼容性好

### Q2: ESP32 的 PWM 和 ESP8266 有什么区别？

| 特性 | ESP32 | ESP8266 |
|------|-------|---------|
| PWM 通道 | 16 个 (LEDC) | 软件实现 |
| 分辨率 | 最高 16 位 | 10 位 |
| 频率控制 | 灵活配置 | 固定 1kHz |
| 库 | ESP32Servo | Servo |

### Q3: 为什么要独立供电舵机？

**原因**:
- SG90 峰值电流可达 500mA
- ESP32 3.3V 引脚电流有限
- 避免电压波动影响 ESP32 稳定性
- 舵机需要 5V 供电才能达到最大力矩

---

## 📄 参考资料

- [ESP32-WROOM-32E Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_en.pdf)
- [ESP32 Pinout Reference](https://randomnerdtutorials.com/esp32-pinout-reference-gpios/)
- [ESP32Servo Library](https://github.com/madhephaestus/ESP32Servo)
- [Last Minute Engineers - ESP32 Servo](https://lastminuteengineers.com/esp32-servo-motor-tutorial/)

---

**GPIO 配置完成，开始硬件连接！** 🚀
