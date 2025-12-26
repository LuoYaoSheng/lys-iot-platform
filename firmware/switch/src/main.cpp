/**
 * ESP32 智能开关主程序
 * 作者: 罗耀生
 * 日期: 2025-12-13
 * 更新: 2025-12-15 - LED状态指示优化
 *
 * LED 状态:
 *   快闪5次+暂停 = 配网模式 (APP连接)
 *   双闪+暂停    = WiFi连接中
 *   三闪+暂停    = API激活中
 *   慢闪         = MQTT连接中
 *   常亮         = 正常运行
 *   极快闪       = 错误
 * 重置: 长按BOOT键3秒
 */

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>
#include "config.h"
#include "nvs_storage.h"
#include "ble_config.h"
#include "device_api.h"

// LED 状态
enum LEDPattern { LED_OFF, LED_ON, LED_CONFIG, LED_WIFI, LED_API, LED_MQTT, LED_ERR, LED_RESET };
LEDPattern ledPattern = LED_OFF;
unsigned long ledTime = 0;
int ledStep = 0;
bool ledState = false;

// 全局对象
NVSStorage storage;
BLEConfigManager bleConfig;
DeviceAPI deviceAPI;
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);
Servo servo;

// 状态变量
DeviceState currentState = STATE_BOOT;
String currentPosition = "middle";  // 当前位置：up/middle/down
unsigned long lastReportTime = 0, stateEnterTime = 0, buttonPressTime = 0;
bool resetTriggered = false;

// MQTT
String mqttServer, mqttUsername, mqttPassword, mqttClientId;
String topicPropertyPost, topicPropertySet, topicStatus;
int mqttPort;

// 函数声明
void changeState(DeviceState s);
void handleStateBoot();
void handleStateCheckConfig();
void handleStateBLEConfig();
void handleStateWiFiConnecting();
void handleStateActivating();
void handleStateMQTTConnecting();
void handleStateRunning();
void handleStateError();
void mqttCallback(char* topic, byte* payload, unsigned int length);
void processCommand(JsonDocument& doc);
void togglePosition(String position);
void pulseAction(int duration);
void reportStatus();
void blinkLED(int times = 1, int delayMs = 200);
void checkResetButton();
void setLED(LEDPattern p);
void updateLED();

void setLED(LEDPattern p) {
  if (ledPattern != p) {
    ledPattern = p; ledStep = 0; ledTime = millis(); ledState = false;
    const char* names[] = {"off","on","config","wifi","api","mqtt","err","reset"};
    Serial.printf("[LED] %s\n", names[p]);
  }
}

void updateLED() {
  unsigned long now = millis();
  switch (ledPattern) {
    case LED_OFF: digitalWrite(LED_BUILTIN, LOW); break;
    case LED_ON: digitalWrite(LED_BUILTIN, HIGH); break;
    case LED_CONFIG:
      if (ledStep < 10) { if (now - ledTime >= 100) { ledState = !ledState; digitalWrite(LED_BUILTIN, ledState); ledTime = now; ledStep++; } }
      else { digitalWrite(LED_BUILTIN, LOW); if (now - ledTime >= 1000) { ledStep = 0; ledTime = now; } }
      break;
    case LED_WIFI:
      if (ledStep < 4) { if (now - ledTime >= 150) { ledState = !ledState; digitalWrite(LED_BUILTIN, ledState); ledTime = now; ledStep++; } }
      else { digitalWrite(LED_BUILTIN, LOW); if (now - ledTime >= 1000) { ledStep = 0; ledTime = now; } }
      break;
    case LED_API:
      if (ledStep < 6) { if (now - ledTime >= 150) { ledState = !ledState; digitalWrite(LED_BUILTIN, ledState); ledTime = now; ledStep++; } }
      else { digitalWrite(LED_BUILTIN, LOW); if (now - ledTime >= 1000) { ledStep = 0; ledTime = now; } }
      break;
    case LED_MQTT:
      if (now - ledTime >= 500) { ledState = !ledState; digitalWrite(LED_BUILTIN, ledState); ledTime = now; }
      break;
    case LED_ERR:
      if (now - ledTime >= 50) { ledState = !ledState; digitalWrite(LED_BUILTIN, ledState); ledTime = now; }
      break;
    case LED_RESET: digitalWrite(LED_BUILTIN, LOW); break;
  }
}

const char* stateName(DeviceState s) {
  const char* n[] = {"BOOT","CHECK","BLE","WIFI","API","MQTT","RUN","ERR"};
  return n[s];
}

void changeState(DeviceState s) {
  Serial.printf("\n==== %s -> %s ====\n", stateName(currentState), stateName(s));
  currentState = s; stateEnterTime = millis();
  LEDPattern leds[] = {LED_ON,LED_ON,LED_CONFIG,LED_WIFI,LED_API,LED_MQTT,LED_ON,LED_ERR};
  setLED(leds[s]);
}

void setup() {
  Serial.begin(SERIAL_BAUD);
  delay(100);
  Serial.println("\n==============================");
  Serial.println("ESP32 IoT Switch v" FIRMWARE_VERSION);
  Serial.println("Product: " PRODUCT_KEY);
  Serial.println("LED: 5x=config, 2x=wifi, 3x=api, slow=mqtt");
  Serial.println("Reset: hold BOOT 3s");
  Serial.println("==============================\n");
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(CONFIG_BUTTON, INPUT_PULLUP);
  digitalWrite(LED_BUILTIN, HIGH);
  ESP32PWM::allocateTimer(0);
  servo.setPeriodHertz(50);
  servo.attach(SERVO_PIN, 500, 2400);
  servo.write(SERVO_ANGLE_MIN);
  delay(500);
  Serial.printf("[INIT] Servo GPIO%d\n", SERVO_PIN);
  if (!storage.begin()) { Serial.println("[ERR] NVS"); changeState(STATE_ERROR); return; }
  Serial.println("[INIT] NVS ok");
  storage.printConfig();
  changeState(STATE_BOOT);
}

void loop() {
  updateLED();
  checkResetButton();
  switch (currentState) {
    case STATE_BOOT: handleStateBoot(); break;
    case STATE_CHECK_CONFIG: handleStateCheckConfig(); break;
    case STATE_BLE_CONFIG: handleStateBLEConfig(); break;
    case STATE_WIFI_CONNECTING: handleStateWiFiConnecting(); break;
    case STATE_ACTIVATING: handleStateActivating(); break;
    case STATE_MQTT_CONNECTING: handleStateMQTTConnecting(); break;
    case STATE_RUNNING: handleStateRunning(); break;
    case STATE_ERROR: handleStateError(); break;
  }
  delay(10);
}

void handleStateBoot() { if (millis() - stateEnterTime > 1000) changeState(STATE_CHECK_CONFIG); }

void handleStateCheckConfig() {
  Serial.printf("[CHK] wifi=%d act=%d\n", storage.hasWiFiConfig(), storage.isActivated());
  if (!storage.hasWiFiConfig()) { changeState(STATE_BLE_CONFIG); return; }
  changeState(STATE_WIFI_CONNECTING);
}

void handleStateBLEConfig() {
  static bool started = false;
  static unsigned long lastPrint = 0;
  if (!started) {
    String sn = deviceAPI.getDeviceSN();
    bleConfig.begin(sn);
    started = true;
    Serial.printf("\n[BLE] Device: IoT-Switch-%s\n[BLE] Waiting APP...\n", sn.c_str());
  }
  if (millis() - lastPrint > 10000) { Serial.printf("[BLE] wait %lus\n", (millis()-stateEnterTime)/1000); lastPrint = millis(); }
  if (bleConfig.hasConfig()) {
    String ssid = bleConfig.getSSID();
    Serial.printf("[BLE] Got: %s\n", ssid.c_str());
    storage.saveWiFiConfig(ssid, bleConfig.getPassword());
    bleConfig.notifyStatus("connecting", "WiFi...");
    started = false;
    changeState(STATE_WIFI_CONNECTING);
  }
}

void handleStateWiFiConnecting() {
  static bool conn = false;
  static unsigned long start = 0, lastP = 0;
  if (!conn) {
    String ssid = storage.getWiFiSSID();
    Serial.printf("[WIFI] %s\n", ssid.c_str());
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid.c_str(), storage.getWiFiPassword().c_str());
    conn = true; start = millis();
  }
  if (millis() - lastP > 2000) { Serial.printf("[WIFI] st=%d %lus\n", WiFi.status(), (millis()-start)/1000); lastP = millis(); }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("[WIFI] OK %s RSSI=%d\n", WiFi.localIP().toString().c_str(), WiFi.RSSI());
    bleConfig.notifyConnected(WiFi.localIP().toString());
    conn = false;
    if (storage.isActivated()) {
      mqttServer = storage.getMQTTServer(); mqttPort = storage.getMQTTPort();
      mqttUsername = storage.getMQTTUsername(); mqttPassword = storage.getMQTTPassword();
      String did = storage.getDeviceId();
      topicPropertyPost = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/thing/event/property/post";
      topicPropertySet = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/thing/service/property/set";
      topicStatus = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/status";
      mqttClientId = String(PRODUCT_KEY) + "&" + did;
      changeState(STATE_MQTT_CONNECTING);
    } else changeState(STATE_ACTIVATING);
    return;
  }
  if (millis() - start > WIFI_CONNECT_TIMEOUT) {
    Serial.println("[WIFI] Timeout - Retry in 5s");
    bleConfig.notifyStatus("error", "Timeout");
    conn = false; // WiFi配置保留，不自动清除
    delay(5000); changeState(STATE_WIFI_CONNECTING); // 5秒后重试
  }
}

void handleStateActivating() {
  Serial.println("[API] Activating...");
  if (bleConfig.hasApiUrl()) deviceAPI.setBaseUrl(bleConfig.getApiUrl());
  ActivationResult r = deviceAPI.activate();
  if (!r.success) { Serial.printf("[API] Fail: %s\n", r.errorMessage.c_str()); bleConfig.notifyStatus("error", r.errorMessage); delay(5000); return; }
  Serial.printf("[API] OK %s\n", r.deviceId.c_str());
  storage.saveDeviceConfig(r.deviceId, r.deviceSecret);
  storage.saveMQTTConfig(r.mqttServer, r.mqttPort, r.mqttUsername, r.mqttPassword);
  mqttServer = r.mqttServer; mqttPort = r.mqttPort; mqttUsername = r.mqttUsername; mqttPassword = r.mqttPassword;
  mqttClientId = r.mqttClientId; topicPropertyPost = r.topicPropertyPost; topicPropertySet = r.topicPropertySet; topicStatus = r.topicStatus;
  bleConfig.notifyActivated(r.deviceId);
  delay(1000); bleConfig.stop();
  changeState(STATE_MQTT_CONNECTING);
}

void handleStateMQTTConnecting() {
  static bool conn = false;
  static unsigned long lastA = 0;
  static int retry = 1000, cnt = 0;
  if (!conn) {
    Serial.printf("[MQTT] %s:%d\n", mqttServer.c_str(), mqttPort);
    mqttClient.setServer(mqttServer.c_str(), mqttPort);
    mqttClient.setCallback(mqttCallback);
    mqttClient.setKeepAlive(MQTT_KEEP_ALIVE);
    conn = true; cnt = 0;
  }
  if (millis() - lastA < (unsigned long)retry) return;
  lastA = millis(); cnt++;
  Serial.printf("[MQTT] #%d...\n", cnt);
  if (mqttClient.connect(mqttClientId.c_str(), mqttUsername.c_str(), mqttPassword.c_str())) {
    Serial.println("[MQTT] OK");
    mqttClient.subscribe(topicPropertySet.c_str());
    mqttClient.publish(topicStatus.c_str(), "{\"status\":\"online\"}");
    conn = false; retry = 1000;
    changeState(STATE_RUNNING);
    blinkLED(3, 100);
  } else {
    Serial.printf("[MQTT] Fail: %d\n", mqttClient.state());
    retry = min(retry * 2, 60000);
  }
}

void handleStateRunning() {
  static unsigned long hb = 0;
  if (WiFi.status() != WL_CONNECTED) { changeState(STATE_WIFI_CONNECTING); return; }
  if (!mqttClient.connected()) { changeState(STATE_MQTT_CONNECTING); return; }
  mqttClient.loop();
  if (millis() - lastReportTime > STATUS_REPORT_INTERVAL) { reportStatus(); lastReportTime = millis(); }
  if (millis() - hb > 60000) { Serial.printf("[RUN] RSSI=%d up=%lus\n", WiFi.RSSI(), millis()/1000); hb = millis(); }
}

void handleStateError() {
  static unsigned long lp = 0;
  if (millis() - lp > 5000) { Serial.println("[ERR] Hold BOOT 3s"); lp = millis(); }
}

void checkResetButton() {
  if (digitalRead(CONFIG_BUTTON) == LOW) {
    if (buttonPressTime == 0) { buttonPressTime = millis(); Serial.println("[BTN] press"); }
    unsigned long h = millis() - buttonPressTime;
    if (h > 1000 && !resetTriggered) {
      setLED(LED_RESET);
      static unsigned long lp = 0;
      if (millis() - lp > 1000) { int r = 3 - h/1000; if (r > 0) Serial.printf("[BTN] %ds\n", r); lp = millis(); }
    }
    if (h > 3000 && !resetTriggered) {
      resetTriggered = true;
      Serial.println("[RESET]");
      for (int i = 0; i < 10; i++) { digitalWrite(LED_BUILTIN, HIGH); delay(50); digitalWrite(LED_BUILTIN, LOW); delay(50); }
      storage.clearAll();
      if (mqttClient.connected()) mqttClient.disconnect();
      WiFi.disconnect(true);
      delay(500);
      ESP.restart();
    }
  } else {
    if (buttonPressTime > 0 && !resetTriggered) changeState(currentState);
    buttonPressTime = 0; resetTriggered = false;
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.printf("[MQTT] %s\n", topic);
  StaticJsonDocument<512> doc;
  if (deserializeJson(doc, payload, length)) return;
  processCommand(doc);
}

void processCommand(JsonDocument& doc) {
  const char* m = doc["method"];
  if (!m) return;
  if (strcmp(m, "thing.service.property.set") == 0) {
    JsonObject p = doc["params"];
    String id = doc["id"] | "0";

    // 新协议：支持 action 参数
    if (p.containsKey("action")) {
      const char* action = p["action"];

      if (strcmp(action, "toggle") == 0 && p.containsKey("position")) {
        // toggle 模式：切换到指定位置并保持
        String pos = p["position"] | "middle";
        Serial.printf("[CMD] toggle pos=%s\n", pos.c_str());
        togglePosition(pos);
        mqttClient.publish(topicPropertyPost.c_str(), ("{\"method\":\"thing.service.property.set_reply\",\"id\":\"" + id + "\",\"code\":200}").c_str());
        reportStatus();
      }
      else if (strcmp(action, "pulse") == 0) {
        // pulse 模式：触发动作后自动恢复
        int duration = p["duration"] | 500;
        Serial.printf("[CMD] pulse dur=%d\n", duration);
        pulseAction(duration);
        mqttClient.publish(topicPropertyPost.c_str(), ("{\"method\":\"thing.service.property.set_reply\",\"id\":\"" + id + "\",\"code\":200}").c_str());
      }
    }
    // 兼容旧协议：switch 参数
    else if (p.containsKey("switch")) {
      bool s = p["switch"];
      Serial.printf("[CMD] sw=%d (legacy)\n", s);
      pulseAction(500);  // 兼容旧协议，使用pulse模式
      mqttClient.publish(topicPropertyPost.c_str(), ("{\"method\":\"thing.service.property.set_reply\",\"id\":\"" + id + "\",\"code\":200}").c_str());
    }
    // 直接角度控制（调试用）
    else if (p.containsKey("angle")) {
      int a = constrain((int)p["angle"], SERVO_ANGLE_MIN, SERVO_ANGLE_MAX);
      Serial.printf("[CMD] angle=%d\n", a);
      servo.write(a);
    }
  }
}

// toggle 模式：切换到指定位置并保持
void togglePosition(String position) {
  int angle = SERVO_POS_MIDDLE;
  if (position == "up") angle = SERVO_POS_UP;
  else if (position == "down") angle = SERVO_POS_DOWN;
  else if (position == "middle") angle = SERVO_POS_MIDDLE;

  Serial.printf("[SERVO] toggle -> %s (%d°)\n", position.c_str(), angle);
  servo.write(angle);
  currentPosition = position;
  blinkLED(1, 200);
}

// pulse 模式：触发动作后自动恢复
void pulseAction(int duration) {
  Serial.printf("[SERVO] pulse %dms\n", duration);
  servo.write(SERVO_ANGLE_PRESS);
  delay(duration);
  servo.write(SERVO_POS_MIDDLE);
  blinkLED(1, 300);
}

void reportStatus() {
  if (!mqttClient.connected()) return;
  StaticJsonDocument<256> doc;
  doc["method"] = "thing.event.property.post";
  doc["id"] = String(millis());
  JsonObject p = doc.createNestedObject("params");
  p["position"] = currentPosition;  // 上报当前位置
  p["angle"] = servo.read();
  p["wifi_rssi"] = WiFi.RSSI();
  p["uptime"] = millis()/1000;
  char buf[256]; serializeJson(doc, buf);
  mqttClient.publish(topicPropertyPost.c_str(), buf);
  Serial.printf("[REPORT] pos=%s\n", currentPosition.c_str());
}

void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) { digitalWrite(LED_BUILTIN, LOW); delay(delayMs); digitalWrite(LED_BUILTIN, HIGH); delay(delayMs); }
}
