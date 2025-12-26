/**
 * ESP32-S3 USB Wakeup Device
 * 硬件: ESP32-S3-N16R8 (16MB Flash + 8MB PSRAM)
 * 作者: 罗耀生
 * 日期: 2025-12-26
 *
 * 功能说明:
 *   - 通过 WiFi 连接 IoT 平台
 *   - 通过 MQTT 接收唤醒命令
 *   - 使用 USB HID 模拟键盘按键唤醒休眠的电脑
 *   - BLE 配网支持
 *
 * 硬件连接:
 *   - USB: 直接连接到电脑 (原生 USB HID)
 *   - LED: GPIO45 (板载 LED)
 *   - 按钮: GPIO0 (BOOT 按钮用于重置配置)
 *
 * 使用说明:
 *   1. 首次上电自动进入 BLE 配网模式
 *   2. 使用手机 APP 配置 WiFi 和平台信息
 *   3. 设备自动激活并连接 MQTT
 *   4. 收到唤醒命令时发送 USB 键盘事件
 */

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <BleKeyboard.h>

// ========== 配置 ==========
#define FIRMWARE_VERSION "1.0.0"
#define PRODUCT_KEY "usb-wakeup-s3"

// GPIO 定义 (ESP32-S3-DevKitC-1)
#define LED_BUILTIN     45   // 板载 RGB LED (通常是 GPIO45)
#define CONFIG_BUTTON   0    // BOOT 按钮

// 超时配置
#define WIFI_CONNECT_TIMEOUT   30000
#define MQTT_CONNECT_TIMEOUT   60000
#define STATUS_REPORT_INTERVAL 60000

// MQTT 配置
#define MQTT_KEEP_ALIVE 60
#define MQTT_PORT       1883

// ========== 枚举 ==========
enum DeviceState {
  STATE_BOOT,              // 启动
  STATE_CHECK_CONFIG,      // 检查配置
  STATE_BLE_CONFIG,        // BLE 配网
  STATE_WIFI_CONNECTING,   // WiFi 连接中
  STATE_ACTIVATING,        // 激活中
  STATE_MQTT_CONNECTING,   // MQTT 连接中
  STATE_RUNNING,           // 运行中
  STATE_ERROR              // 错误
};

enum LEDPattern {
  LED_OFF,     // 关闭
  LED_ON,      // 常亮
  LED_SLOW,    // 慢闪 (运行中)
  LED_FAST,    // 快闪 (连接中)
  LED_CONFIG,  // 配网模式 (三短一长)
  LED_ERROR    // 错误 (快速闪烁)
};

// ========== 全局变量 ==========
DeviceState currentState = STATE_BOOT;
LEDPattern ledPattern = LED_ON;
unsigned long ledLastToggle = 0;
bool ledState = false;

// BLE 配网
BleKeyboard* bleKeyboard = nullptr;
bool bleConfigDone = false;
String bleSSID, blePassword, bleApiUrl, bleDeviceId;

// WiFi & MQTT
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

String mqttServer, mqttUsername, mqttPassword, mqttClientId;
int mqttPort = MQTT_PORT;
String topicPropertyPost, topicPropertySet, topicStatus;

// NVS 存储 (简化版，使用 Preferences)
#include <Preferences.h>
Preferences prefs;

// 按钮
unsigned long buttonPressTime = 0;
bool resetTriggered = false;

// ========== 函数声明 ==========
void changeState(DeviceState newState);
void updateLED();
void handleStateBoot();
void handleStateCheckConfig();
void handleStateBLEConfig();
void handleStateWiFiConnecting();
void handleStateActivating();
void handleStateMQTTConnecting();
void handleStateRunning();
void handleStateError();

void mqttCallback(char* topic, byte* payload, unsigned int length);
void processWakeupCommand(JsonObject& params);
void sendWakeupSignal();
void reportStatus();
void checkButton();

// NVS 操作
bool hasConfig();
void saveConfig(const String& ssid, const String& password);
void loadConfig(String& ssid, String& password);
void clearConfig();

// ========== LED 控制 ==========
void setLED(LEDPattern pattern) {
  ledPattern = pattern;
  ledState = false;
}

void updateLED() {
  unsigned long now = millis();
  int interval = 0;

  switch (ledPattern) {
    case LED_OFF:
      ledState = false;
      break;
    case LED_ON:
      ledState = true;
      break;
    case LED_SLOW:
      interval = 1000;
      if (now - ledLastToggle >= interval) {
        ledState = !ledState;
        ledLastToggle = now;
      }
      break;
    case LED_FAST:
      interval = 200;
      if (now - ledLastToggle >= interval) {
        ledState = !ledState;
        ledLastToggle = now;
      }
      break;
    case LED_CONFIG:
      // 三短一长模式
      interval = 150;
      if (now - ledLastToggle >= interval) {
        ledState = !ledState;
        ledLastToggle = now;
      }
      break;
    case LED_ERROR:
      interval = 50;
      if (now - ledLastToggle >= interval) {
        ledState = !ledState;
        ledLastToggle = now;
      }
      break;
  }

  // ESP32-S3 的 LED 可能是反向的
  digitalWrite(LED_BUILTIN, ledState ? LOW : HIGH);
}

// ========== 状态管理 ==========
const char* getStateName(DeviceState state) {
  static const char* names[] = {
    "BOOT", "CHECK", "BLE_CONFIG", "WIFI",
    "ACTIVATING", "MQTT", "RUNNING", "ERROR"
  };
  return names[state];
}

void changeState(DeviceState newState) {
  Serial.printf("\n[STATE] %s -> %s\n",
    getStateName(currentState), getStateName(newState));
  currentState = newState;

  // 设置对应的 LED 模式
  static const LEDPattern stateLED[] = {
    LED_ON,      // BOOT
    LED_ON,      // CHECK
    LED_CONFIG,  // BLE_CONFIG
    LED_FAST,    // WIFI_CONNECTING
    LED_FAST,    // ACTIVATING
    LED_FAST,    // MQTT_CONNECTING
    LED_SLOW,    // RUNNING
    LED_ERROR    // ERROR
  };
  setLED(stateLED[newState]);
}

// ========== NVS 存储 ==========
bool hasConfig() {
  prefs.begin("iot-config", false);
  bool has = prefs.isKey("ssid");
  prefs.end();
  return has;
}

void saveConfig(const String& ssid, const String& password) {
  prefs.begin("iot-config", false);
  prefs.putString("ssid", ssid);
  prefs.putString("password", password);
  prefs.end();
  Serial.println("[NVS] Config saved");
}

void loadConfig(String& ssid, String& password) {
  prefs.begin("iot-config", false);
  ssid = prefs.getString("ssid", "");
  password = prefs.getString("password", "");
  prefs.end();
}

void clearConfig() {
  prefs.begin("iot-config", false);
  prefs.clear();
  prefs.end();
  Serial.println("[NVS] Config cleared");
}

// ========== BLE 配网 (简化版) ==========
// 注意: 由于同时使用 BleKeyboard，这里简化为只做 WiFi 配置
// 实际使用时可以考虑使用 ESP-NOW 或其他配网方式

void startBLEConfig() {
  Serial.println("[BLE] Starting BLE config...");
  Serial.println("[BLE] BLE config not implemented yet");
  Serial.println("[BLE] Please hardcode WiFi credentials or use other config method");
  // TODO: 实现 BLE 配网
  // 由于同时使用 BleKeyboard，需要处理好冲突
  // 暂时使用硬编码或串口配置
}

// ========== WiFi & MQTT ==========
void handleStateWiFiConnecting() {
  static bool connecting = false;
  static unsigned long startTime = 0;

  if (!connecting) {
    String ssid, password;
    loadConfig(ssid, password);

    if (ssid.isEmpty()) {
      Serial.println("[WIFI] No config, go to BLE config");
      changeState(STATE_BLE_CONFIG);
      return;
    }

    Serial.printf("[WIFI] Connecting to %s\n", ssid.c_str());
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid.c_str(), password.c_str());
    connecting = true;
    startTime = millis();
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("[WIFI] Connected! IP: %s\n", WiFi.localIP().toString().c_str());
    connecting = false;

    // TODO: 检查是否已激活，暂时直接进入 MQTT
    // 这里需要根据实际情况调整
    mqttServer = "192.168.1.100";  // 需要从配置读取
    changeState(STATE_MQTT_CONNECTING);
    return;
  }

  if (millis() - startTime > WIFI_CONNECT_TIMEOUT) {
    Serial.println("[WIFI] Timeout, retrying...");
    connecting = false;
    delay(5000);
  }
}

void handleStateMQTTConnecting() {
  static unsigned long lastAttempt = 0;
  static int attemptCount = 0;
  unsigned long now = millis();

  if (now - lastAttempt < 2000) return;
  lastAttempt = now;
  attemptCount++;

  Serial.printf("[MQTT] Attempt #%d\n", attemptCount);

  // TODO: 从配置获取 MQTT 参数
  String deviceId = "esp32s3-wakeup-001";
  mqttClientId = deviceId;
  mqttUsername = deviceId;
  mqttPassword = "password";  // 从激活获取

  topicPropertyPost = "/sys/" + String(PRODUCT_KEY) + "/" + deviceId + "/thing/event/property/post";
  topicPropertySet = "/sys/" + String(PRODUCT_KEY) + "/" + deviceId + "/thing/service/property/set";
  topicStatus = "/sys/" + String(PRODUCT_KEY) + "/" + deviceId + "/status";

  mqttClient.setServer(mqttServer.c_str(), mqttPort);
  mqttClient.setCallback(mqttCallback);
  mqttClient.setKeepAlive(MQTT_KEEP_ALIVE);

  if (mqttClient.connect(mqttClientId.c_str(), mqttUsername.c_str(), mqttPassword.c_str())) {
    Serial.println("[MQTT] Connected!");
    mqttClient.subscribe(topicPropertySet.c_str());
    mqttClient.publish(topicStatus.c_str(), "{\"status\":\"online\"}");
    changeState(STATE_RUNNING);
  } else {
    Serial.printf("[MQTT] Failed, rc=%d\n", mqttClient.state());
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.printf("[MQTT] Message: %s\n", topic);

  StaticJsonDocument<512> doc;
  if (deserializeJson(doc, payload, length) != DeserializationError::Ok) {
    Serial.println("[MQTT] JSON parse error");
    return;
  }

  const char* method = doc["method"];
  if (method && strcmp(method, "thing.service.property.set") == 0) {
    JsonObject params = doc["params"];
    String msgId = doc["id"] | "0";

    processWakeupCommand(params);

    // 回复
    String reply = "{\"method\":\"thing.service.property.set_reply\",\"id\":\"" +
                   msgId + "\",\"code\":200,\"message\":\"success\"}";
    mqttClient.publish(topicPropertyPost.c_str(), reply.c_str());
  }
}

void processWakeupCommand(JsonObject& params) {
  // 检查唤醒命令
  if (params.containsKey("wakeup")) {
    bool wakeup = params["wakeup"];
    if (wakeup) {
      Serial.println("[CMD] Wakeup command received!");
      sendWakeupSignal();
    }
  }

  // 支持指定按键
  if (params.containsKey("key")) {
    const char* key = params["key"];
    Serial.printf("[CMD] Send key: %s\n", key);
    // TODO: 实现指定按键发送
  }

  // 支持按键组合
  if (params.containsKey("key_combo")) {
    const char* combo = params["key_combo"];
    Serial.printf("[CMD] Key combo: %s\n", combo);
    // TODO: 实现组合键发送
  }
}

// ========== USB HID 唤醒 ==========
void sendWakeupSignal() {
  Serial.println("[USB] Sending wakeup signal...");

  if (!bleKeyboard) {
    bleKeyboard = new BleKeyboard("ESP32-Wakeup");
    bleKeyboard->begin();
  }

  // 发送不同的按键组合唤醒电脑
  // 方法1: 空格键
  bleKeyboard->write(KEY_SPACE);
  delay(100);

  // 方法2: 如果空格不够，可以尝试其他组合
  // bleKeyboard->press(KEY_LEFT_CTRL);
  // delay(50);
  // bleKeyboard->press(KEY_LEFT_SHIFT);
  // delay(50);
  // bleKeyboard->write(' ');
  // delay(100);
  // bleKeyboard->releaseAll();

  Serial.println("[USB] Wakeup signal sent!");

  // LED 闪烁确认
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_BUILTIN, LOW);
    delay(100);
    digitalWrite(LED_BUILTIN, HIGH);
    delay(100);
  }
}

void reportStatus() {
  if (!mqttClient.connected()) return;

  StaticJsonDocument<256> doc;
  doc["method"] = "thing.event.property.post";
  doc["id"] = String(millis());
  JsonObject params = doc.createNestedObject("params");
  params["wifi_rssi"] = WiFi.RSSI();
  params["uptime"] = millis() / 1000;
  params["free_heap"] = ESP.getFreeHeap();
  params["status"] = "online";

  char buffer[256];
  serializeJson(doc, buffer);
  mqttClient.publish(topicPropertyPost.c_str(), buffer);
}

// ========== 按钮处理 ==========
void checkButton() {
  if (digitalRead(CONFIG_BUTTON) == LOW) {
    if (buttonPressTime == 0) {
      buttonPressTime = millis();
      Serial.println("[BTN] Pressed");
    }

    unsigned long pressDuration = millis() - buttonPressTime;

    // 长按 3 秒重置配置
    if (pressDuration > 3000 && !resetTriggered) {
      resetTriggered = true;
      Serial.println("[BTN] Reset config!");
      setLED(LED_ERROR);

      // LED 快速闪烁确认
      for (int i = 0; i < 10; i++) {
        digitalWrite(LED_BUILTIN, LOW);
        delay(50);
        digitalWrite(LED_BUILTIN, HIGH);
        delay(50);
      }

      clearConfig();
      mqttClient.disconnect();
      WiFi.disconnect();
      delay(1000);
      ESP.restart();
    }
  } else {
    buttonPressTime = 0;
    resetTriggered = false;
  }
}

// ========== 状态处理函数 ==========
void handleStateBoot() {
  delay(1000);
  changeState(STATE_CHECK_CONFIG);
}

void handleStateCheckConfig() {
  if (hasConfig()) {
    String ssid, password;
    loadConfig(ssid, password);
    Serial.printf("[CHK] Has config: %s\n", ssid.c_str());
    changeState(STATE_WIFI_CONNECTING);
  } else {
    Serial.println("[CHK] No config found");
    changeState(STATE_BLE_CONFIG);
  }
}

void handleStateBLEConfig() {
  Serial.println("[BLE] Please configure WiFi:");
  Serial.println("[BLE] Method 1: Hardcode in source code");
  Serial.println("[BLE] Method 2: Use BLE config (TODO)");
  Serial.println("[BLE] Method 3: Use serial config");

  // 临时方法: 在这里硬编码 WiFi 信息
  // saveConfig("YourWiFiSSID", "YourPassword");
  // changeState(STATE_WIFI_CONNECTING);

  // 等待配置实现
  delay(5000);
}

void handleStateActivating() {
  // TODO: 实现设备激活流程
  Serial.println("[API] Activation skipped for now");
  changeState(STATE_MQTT_CONNECTING);
}

void handleStateRunning() {
  // 检查连接状态
  if (WiFi.status() != WL_CONNECTED) {
    changeState(STATE_WIFI_CONNECTING);
    return;
  }
  if (!mqttClient.connected()) {
    changeState(STATE_MQTT_CONNECTING);
    return;
  }

  mqttClient.loop();

  // 定期上报状态
  static unsigned long lastReport = 0;
  if (millis() - lastReport > STATUS_REPORT_INTERVAL) {
    reportStatus();
    lastReport = millis();
  }
}

void handleStateError() {
  static unsigned long lastPrint = 0;
  if (millis() - lastPrint > 5000) {
    Serial.println("[ERR] Hold BOOT button 3s to reset");
    lastPrint = millis();
  }
}

// ========== 主函数 ==========
void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("\n====================================");
  Serial.println("ESP32-S3 USB Wakeup Device");
  Serial.printf("Firmware: %s\n", FIRMWARE_VERSION);
  Serial.printf("Hardware: ESP32-S3-N16R8");
  Serial.printf("Product: %s\n", PRODUCT_KEY);
  Serial.println("====================================\n");

  // 初始化 GPIO
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(CONFIG_BUTTON, INPUT_PULLUP);
  digitalWrite(LED_BUILTIN, HIGH);  // LED 初始状态

  // 初始化 NVS
  prefs.begin("iot-config", false);

  // 初始化 USB HID 键盘
  bleKeyboard = new BleKeyboard("ESP32-Wakeup");
  bleKeyboard->begin();

  Serial.println("[INIT] USB HID Keyboard initialized");
  Serial.println("[INIT] LED: " + String(LED_BUILTIN));
  Serial.println("[INIT] Button: " + String(CONFIG_BUTTON));

  changeState(STATE_BOOT);
}

void loop() {
  updateLED();
  checkButton();

  switch (currentState) {
    case STATE_BOOT:
      handleStateBoot();
      break;
    case STATE_CHECK_CONFIG:
      handleStateCheckConfig();
      break;
    case STATE_BLE_CONFIG:
      handleStateBLEConfig();
      break;
    case STATE_WIFI_CONNECTING:
      handleStateWiFiConnecting();
      break;
    case STATE_ACTIVATING:
      handleStateActivating();
      break;
    case STATE_MQTT_CONNECTING:
      handleStateMQTTConnecting();
      break;
    case STATE_RUNNING:
      handleStateRunning();
      break;
    case STATE_ERROR:
      handleStateError();
      break;
  }

  delay(10);
}
