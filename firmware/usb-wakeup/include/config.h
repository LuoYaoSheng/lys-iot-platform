/**
 * ESP32-S3 USB 唤醒设备配置文件
 * 硬件: ESP32-S3-N16R8
 * 作者: 罗耀生
 * 日期: 2025-12-26
 */

#ifndef CONFIG_H
#define CONFIG_H

// ==================== 产品信息 ====================
#define PRODUCT_KEY         "USB-WAKEUP-S3"     // 产品标识
#define FIRMWARE_VERSION    "1.0.0"             // 固件版本
#define CHIP_MODEL          "ESP32-S3-N16R8"    // 芯片型号

// ==================== 平台 API ====================
#define API_BASE_URL        "http://192.168.1.100:48080"  // 平台API地址（需修改为实际地址）
#define API_ACTIVATE_PATH   "/api/v1/devices/activate"    // 激活接口
#define API_TIMEOUT         10000                         // API超时（毫秒）

// ==================== GPIO 配置 (ESP32-S3-DevKitC-1) ====================
#define LED_BUILTIN         45    // 板载 RGB LED
#define CONFIG_BUTTON       0     // BOOT 按钮

// ==================== BLE 配网配置 ====================
#define BLE_DEVICE_PREFIX   "IoT-Wakeup-"       // BLE设备名前缀
#define BLE_SERVICE_UUID    "0000FFE0-0000-1000-8000-00805F9B34FB"
#define BLE_CHAR_WIFI_UUID  "0000FFE1-0000-1000-8000-00805F9B34FB"
#define BLE_CHAR_STATUS_UUID "0000FFE2-0000-1000-8000-00805F9B34FB"

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

// ==================== 系统配置 ====================
#define SERIAL_BAUD         115200  // 串口波特率
#define WIFI_CONNECT_TIMEOUT 30000  // WiFi连接超时（毫秒）
#define MQTT_KEEP_ALIVE     60      // MQTT心跳（秒）
#define STATUS_REPORT_INTERVAL 60000 // 状态上报间隔（毫秒）

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
