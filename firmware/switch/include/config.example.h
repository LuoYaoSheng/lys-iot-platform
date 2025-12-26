/**
 * ========================================
 * ESP32 智能开关配置文件示例
 * 作者: 罗耀生
 * 日期: 2025-12-16
 * ========================================
 *
 * 使用说明:
 * 1. 复制此文件为 config.h
 * 2. 根据实际环境修改配置值
 * 3. 开发时建议使用 Natapp 内网穿透
 *
 * 支持: BLE配网 + API激活 + MQTT通信
 * 芯片: ESP32-WROOM-32E
 *
 * ========================================
 */

#ifndef CONFIG_H
#define CONFIG_H

// ==================== 产品信息（出厂预置）====================
#define PRODUCT_KEY         "SW-SERVO-001"      // 产品标识（必须与平台创建的产品一致）
#define FIRMWARE_VERSION    "1.0.0"             // 固件版本
#define CHIP_MODEL          "ESP32-WROOM-32E"   // 芯片型号

// ==================== 平台 API ====================
// 注意: 固件不能用 localhost，需要使用开发机器的局域网 IP 或公网地址
//
// 开发环境配置方案:
// 方案1: 使用局域网IP（ESP32和电脑在同一WiFi下）
//        #define API_BASE_URL "http://192.168.1.100:48080"
//
// 方案2: 使用Natapp内网穿透（推荐）
//        #define API_BASE_URL "http://i2kai.mynatapp.cc"
//        运行: natapp -authtoken=your_token -subdomain=i2kai
//
// 生产环境:
//        #define API_BASE_URL "http://your-domain.com"

#define API_BASE_URL        "http://i2kai.mynatapp.cc"    // ⚠️ 修改为实际地址
#define API_ACTIVATE_PATH   "/api/v1/devices/activate"    // 激活接口路径
#define API_TIMEOUT         10000                          // API超时（毫秒）

// ==================== GPIO 配置 ====================
#define SERVO_PIN           18    // 舵机PWM控制引脚
#define LED_BUILTIN         2     // 板载LED状态指示
#define CONFIG_BUTTON       0     // 配网按键（BOOT键）

// ==================== BLE 配网配置 ====================
#define BLE_DEVICE_PREFIX   "IoT-Switch-"                  // BLE设备名前缀（实际名称: IoT-Switch-XXXX）
#define BLE_SERVICE_UUID    "0000FFE0-0000-1000-8000-00805F9B34FB"
#define BLE_CHAR_WIFI_UUID  "0000FFE1-0000-1000-8000-00805F9B34FB"  // WiFi配置特征值
#define BLE_CHAR_STATUS_UUID "0000FFE2-0000-1000-8000-00805F9B34FB" // 状态通知特征值

// ==================== NVS 存储 Key ====================
#define NVS_NAMESPACE       "iot_config"
#define NVS_KEY_WIFI_SSID   "wifi_ssid"
#define NVS_KEY_WIFI_PASS   "wifi_pass"
#define NVS_KEY_DEVICE_ID   "device_id"
#define NVS_KEY_DEVICE_SEC  "device_secret"
#define NVS_KEY_MQTT_SERVER "mqtt_server"
#define NVS_KEY_MQTT_PORT   "mqtt_port"
#define NVS_KEY_MQTT_USER   "mqtt_user"
#define NVS_KEY_MQTT_PASS   "mqtt_pass"
#define NVS_KEY_ACTIVATED   "activated"

// ==================== 舵机配置 ====================
#define SERVO_ANGLE_MIN     0       // 最小角度
#define SERVO_ANGLE_MAX     180     // 最大角度
#define SERVO_ANGLE_PRESS   0       // 按压角度（pulse模式，按下位置）
#define SERVO_PRESS_DELAY   500     // 按压延时（毫秒）

// 舵机位置定义（toggle模式）
// ⚠️ 根据实际安装情况调整角度
#define SERVO_POS_DOWN      0       // 下位置（关）
#define SERVO_POS_MIDDLE    90      // 中间位置（默认）
#define SERVO_POS_UP        180     // 上位置（开）

// ==================== 系统配置 ====================
#define SERIAL_BAUD         115200  // 串口波特率
#define WIFI_CONNECT_TIMEOUT 15000  // WiFi连接超时（毫秒）
#define MQTT_KEEP_ALIVE     60      // MQTT心跳（秒）
#define STATUS_REPORT_INTERVAL 30000 // 状态上报间隔（毫秒）

// ==================== 设备状态枚举 ====================
enum DeviceState {
  STATE_BOOT,           // 启动
  STATE_CHECK_CONFIG,   // 检查配置
  STATE_BLE_CONFIG,     // BLE配网模式
  STATE_WIFI_CONNECTING,// WiFi连接中
  STATE_ACTIVATING,     // 设备激活中
  STATE_MQTT_CONNECTING,// MQTT连接中
  STATE_RUNNING,        // 正常运行
  STATE_ERROR           // 错误状态
};

// ==================== 调试开关 ====================
#define DEBUG_ENABLED       true

#if DEBUG_ENABLED
  #define DEBUG_PRINT(x)    Serial.print(x)
  #define DEBUG_PRINTLN(x)  Serial.println(x)
  #define DEBUG_PRINTF(...) Serial.printf(__VA_ARGS__)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
  #define DEBUG_PRINTF(...)
#endif

#endif // CONFIG_H

// ========================================
// 配置检查清单
// ========================================
//
// 烧录前必须检查:
// ✓ PRODUCT_KEY 与平台创建的产品一致
// ✓ API_BASE_URL 能从ESP32网络访问
// ✓ SERVO_POS_* 根据实际安装调整
//
// 常见问题:
// Q: 设备无法连接平台？
// A: 检查 API_BASE_URL 是否可访问，尝试使用 ping 测试
//
// Q: 舵机角度不对？
// A: 调整 SERVO_POS_* 的值，范围 0-180
//
// Q: 配网失败？
// A: 确保手机蓝牙已打开，设备进入配网模式（LED快闪）
//
// ========================================
