/**
 * ESP32 USB Wakeup Device
 * 作者: 罗耀生
 * 日期: 2025-12-26
 *
 * 功能说明:
 *   - 通过 MQTT 接收唤醒命令
 *   - 使用 USB HID 模拟键盘按键唤醒电脑
 *   - 适用于 ESP32-S2/S3 等原生 USB 支持的芯片
 *
 * 硬件: ESP32-S3
 *
 * 开发状态: 待完成
 */

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>

// TODO: 添加 USB HID 库支持
// #include <USBHIDKeyboard.h>

// 配置
#define FIRMWARE_VERSION "0.1.0"
#define PRODUCT_KEY "usb wakeup device"  // 待配置

// GPIO
#define LED_BUILTIN 2
#define CONFIG_BUTTON 0

// WiFi 配置
#define WIFI_CONNECT_TIMEOUT 30000

// MQTT 配置
#define MQTT_KEEP_ALIVE 60
#define STATUS_REPORT_INTERVAL 60000

// 状态
enum DeviceState {
  STATE_BOOT,
  STATE_CHECK_CONFIG,
  STATE_BLE_CONFIG,
  STATE_WIFI_CONNECTING,
  STATE_ACTIVATING,
  STATE_MQTT_CONNECTING,
  STATE_RUNNING,
  STATE_ERROR
};

// 全局变量
DeviceState currentState = STATE_BOOT;
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

String mqttServer, mqttUsername, mqttPassword, mqttClientId;
String topicPropertyPost, topicPropertySet, topicStatus;
int mqttPort;

// 函数声明
void changeState(DeviceState s);
void handleStateBoot();
void handleStateCheckConfig();
void handleStateWiFiConnecting();
void handleStateMQTTConnecting();
void handleStateRunning();
void mqttCallback(char* topic, byte* payload, unsigned int length);
void processWakeupCommand();
void reportStatus();

const char* stateName(DeviceState s) {
  const char* n[] = {"BOOT", "CHECK", "BLE", "WIFI", "API", "MQTT", "RUN", "ERR"};
  return n[s];
}

void changeState(DeviceState s) {
  Serial.printf("\n==== %s -> %s ====\n", stateName(currentState), stateName(s));
  currentState = s;
}

void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("\n==============================");
  Serial.println("ESP32 USB Wakeup Device v" FIRMWARE_VERSION);
  Serial.println("==============================\n");

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(CONFIG_BUTTON, INPUT_PULLUP);
  digitalWrite(LED_BUILTIN, HIGH);

  // TODO: 初始化 USB HID 键盘
  // Keyboard.begin();

  changeState(STATE_BOOT);
}

void loop() {
  switch (currentState) {
    case STATE_BOOT:
      handleStateBoot();
      break;
    case STATE_CHECK_CONFIG:
      handleStateCheckConfig();
      break;
    case STATE_WIFI_CONNECTING:
      handleStateWiFiConnecting();
      break;
    case STATE_MQTT_CONNECTING:
      handleStateMQTTConnecting();
      break;
    case STATE_RUNNING:
      handleStateRunning();
      break;
    default:
      break;
  }
  delay(10);
}

void handleStateBoot() {
  delay(1000);
  changeState(STATE_CHECK_CONFIG);
}

void handleStateCheckConfig() {
  // TODO: 检查配置
  // 暂时跳到 WiFi 连接
  changeState(STATE_WIFI_CONNECTING);
}

void handleStateWiFiConnecting() {
  Serial.println("[WIFI] Connecting...");
  // TODO: 实现 WiFi 连接
  delay(1000);
}

void handleStateMQTTConnecting() {
  Serial.println("[MQTT] Connecting...");
  // TODO: 实现 MQTT 连接
  delay(1000);
}

void handleStateRunning() {
  if (!mqttClient.connected()) {
    changeState(STATE_MQTT_CONNECTING);
    return;
  }
  mqttClient.loop();

  static unsigned long lastReport = 0;
  if (millis() - lastReport > STATUS_REPORT_INTERVAL) {
    reportStatus();
    lastReport = millis();
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.printf("[MQTT] %s\n", topic);

  StaticJsonDocument<512> doc;
  if (deserializeJson(doc, payload, length)) {
    Serial.println("[MQTT] JSON parse error");
    return;
  }

  // 处理唤醒命令
  const char* method = doc["method"];
  if (method && strcmp(method, "thing.service.property.set") == 0) {
    JsonObject params = doc["params"];
    if (params.containsKey("wakeup")) {
      processWakeupCommand();
    }
  }
}

void processWakeupCommand() {
  Serial.println("[WAKEUP] Sending keyboard wakeup...");

  // TODO: 发送 USB 键盘按键唤醒电脑
  // 示例: 发送空格键或任意键
  // Keyboard.press(KEY_SPACE);
  // delay(100);
  // Keyboard.releaseAll();

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
  JsonObject params = doc.createNestedObject("params");
  params["wifi_rssi"] = WiFi.RSSI();
  params["uptime"] = millis() / 1000;

  char buffer[256];
  serializeJson(doc, buffer);
  mqttClient.publish(topicPropertyPost.c_str(), buffer);
}
