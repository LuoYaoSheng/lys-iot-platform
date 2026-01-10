/**
 * ESP32-S3 USB Wakeup Device
 * 硬件: ESP32-S3-N16R8 (16MB Flash + 8MB PSRAM)
 * 作者: 罗耀生
 * 日期: 2025-12-26
 *
 * 功能说明:
 *   - BLE 配网（使用手机 APP 配置 WiFi）
 *   - WiFi 连接 IoT 平台
 *   - 设备自动激活
 *   - MQTT 接收唤醒命令
 *   - USB HID 模拟键盘唤醒休眠电脑
 *
 * 硬件连接:
 *   - USB: 直接连接到电脑 (USB CDC + 可切换 HID)
 *   - LED: GPIO45 (板载 LED)
 *   - 按钮: GPIO0 (BOOT 按钮用于重置配置)
 *
 * LED 状态:
 *   常亮     = 启动/初始化
 *   五次快闪 = BLE 配网模式 (等待 APP 连接)
 *   三次快闪 = WiFi 连接中
 *   二次快闪 = API 激活/MQTT 连接中
 *   慢闪     = 正常运行
 *   极快闪   = 错误状态
 *
 * 重置: 长按 BOOT 键 3 秒
 *
 * 分时使用说明:
 *   - 配网阶段: 使用 BLE 进行 WiFi 配置
 *   - 运行阶段: BLE 停止，USB HID 就绪
 */

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <USB.h>
#include <USBHIDKeyboard.h>
#include "config.h"
#include "ble_config.h"
#include "nvs_storage.h"
#include "device_api.h"

// ========== 全局对象 ==========
NVSStorage storage;
BLEConfigManager bleConfig;
DeviceAPI deviceAPI;
USBHIDKeyboard Keyboard;

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

// ========== 状态变量 ==========
DeviceState currentState = STATE_BOOT;
unsigned long lastReportTime = 0, stateEnterTime = 0, buttonPressTime = 0;
bool resetTriggered = false;

// MQTT
String mqttServer, mqttUsername, mqttPassword, mqttClientId;
String topicPropertyPost, topicPropertySet, topicStatus;
int mqttPort;

// LED 状态
enum LEDPattern { LED_OFF, LED_ON, LED_CONFIG, LED_WIFI, LED_API, LED_MQTT, LED_ERR, LED_RESET };
LEDPattern ledPattern = LED_ON;
unsigned long ledTime = 0;
int ledStep = 0;
bool ledState = false;

// ========== USB HID 键盘 ==========

// 发送 USB HID 唤醒信号
void sendUSBWakeup() {
  // 发送 F13 功能键唤醒电脑（不影响正常使用）
  DEBUG_PRINTLN("[USB] Sending wakeup key...");
  Keyboard.write(KEY_F13);
  DEBUG_PRINTLN("[USB] Wakeup key sent!");
}

// ========== 函数声明 ==========
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
void sendWakeupSignal();
void reportStatus();
void blinkLED(int times = 1, int delayMs = 200);
void checkResetButton();
void setLED(LEDPattern p);
void updateLED();

// ========== LED 控制 ==========
void setLED(LEDPattern p) {
  if (ledPattern != p) {
    ledPattern = p;
    ledStep = 0;
    ledTime = millis();
    ledState = false;
  }
}

void updateLED() {
  unsigned long now = millis();
  switch (ledPattern) {
    case LED_OFF: digitalWrite(WAKEUP_LED_PIN, LOW); break;
    case LED_ON: digitalWrite(WAKEUP_LED_PIN, HIGH); break;
    case LED_CONFIG:
      // 五次快闪 + 暂停
      if (ledStep < 10) {
        if (now - ledTime >= 100) {
          ledState = !ledState;
          digitalWrite(WAKEUP_LED_PIN, ledState);
          ledTime = now;
          ledStep++;
        }
      } else {
        digitalWrite(WAKEUP_LED_PIN, LOW);
        if (now - ledTime >= 1000) {
          ledStep = 0;
          ledTime = now;
        }
      }
      break;
    case LED_WIFI:
      // 三次快闪 + 暂停
      if (ledStep < 6) {
        if (now - ledTime >= 150) {
          ledState = !ledState;
          digitalWrite(WAKEUP_LED_PIN, ledState);
          ledTime = now;
          ledStep++;
        }
      } else {
        digitalWrite(WAKEUP_LED_PIN, LOW);
        if (now - ledTime >= 1000) {
          ledStep = 0;
          ledTime = now;
        }
      }
      break;
    case LED_API:
      // 二次快闪 + 暂停
      if (ledStep < 4) {
        if (now - ledTime >= 150) {
          ledState = !ledState;
          digitalWrite(WAKEUP_LED_PIN, ledState);
          ledTime = now;
          ledStep++;
        }
      } else {
        digitalWrite(WAKEUP_LED_PIN, LOW);
        if (now - ledTime >= 1000) {
          ledStep = 0;
          ledTime = now;
        }
      }
      break;
    case LED_MQTT:
      // 二次快闪 + 暂停
      if (ledStep < 4) {
        if (now - ledTime >= 150) {
          ledState = !ledState;
          digitalWrite(WAKEUP_LED_PIN, ledState);
          ledTime = now;
          ledStep++;
        }
      } else {
        digitalWrite(WAKEUP_LED_PIN, LOW);
        if (now - ledTime >= 1000) {
          ledStep = 0;
          ledTime = now;
        }
      }
      break;
    case LED_ERR:
      if (now - ledTime >= 50) {
        ledState = !ledState;
        digitalWrite(WAKEUP_LED_PIN, ledState);
        ledTime = now;
      }
      break;
    case LED_RESET:
      digitalWrite(WAKEUP_LED_PIN, LOW);
      break;
  }
}

const char* stateName(DeviceState s) {
  const char* n[] = {"BOOT","CHECK","BLE","WIFI","API","MQTT","RUN","ERR"};
  return n[s];
}

void changeState(DeviceState s) {
  Serial.printf("\n==== %s -> %s ====\n", stateName(currentState), stateName(s));
  currentState = s;
  stateEnterTime = millis();
  LEDPattern leds[] = {LED_ON,LED_ON,LED_CONFIG,LED_WIFI,LED_API,LED_MQTT,LED_ON,LED_ERR};
  setLED(leds[s]);
}

void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(WAKEUP_LED_PIN, HIGH);
    delay(delayMs);
    digitalWrite(WAKEUP_LED_PIN, LOW);
    delay(delayMs);
  }
}

// ========== 主函数 ==========
void setup() {
  Serial.begin(SERIAL_BAUD);
  delay(100);
  Serial.println("\n==============================");
  Serial.println("ESP32-S3 USB Wakeup Device v" FIRMWARE_VERSION);
  Serial.println("Product: " PRODUCT_KEY);
  Serial.println("LED: 5x=BLE, 3x=Wifi, 2x=API/MQTT");
  Serial.println("Reset: hold BOOT 3s");
  Serial.println("==============================\n");
  pinMode(WAKEUP_LED_PIN, OUTPUT);
  pinMode(CONFIG_BUTTON, INPUT_PULLUP);
  digitalWrite(WAKEUP_LED_PIN, HIGH);

  // 初始化 USB HID
  USB.onEvent([](void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) {
    if (event_base == ARDUINO_USB_EVENTS) {
      if (event_id == ARDUINO_USB_STARTED_EVENT) {
        Serial.println("[USB] HID started");
      }
    }
  });
  Keyboard.begin();
  USB.begin();
  Serial.println("[INIT] USB HID ready");

  // 初始化存储
  if (!storage.begin()) {
    Serial.println("[ERR] NVS init failed");
    changeState(STATE_ERROR);
    return;
  }
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

void handleStateBoot() {
  if (millis() - stateEnterTime > 1000) changeState(STATE_CHECK_CONFIG);
}

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
    Serial.printf("\n[BLE] Device: IoT-Wakeup-%s\n[BLE] Waiting APP...\n", sn.c_str());
  }
  if (millis() - lastPrint > 10000) {
    Serial.printf("[BLE] wait %lus\n", (millis()-stateEnterTime)/1000);
    lastPrint = millis();
  }
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
    conn = true;
    start = millis();
  }
  if (millis() - lastP > 2000) {
    Serial.printf("[WIFI] st=%d %lus\n", WiFi.status(), (millis()-start)/1000);
    lastP = millis();
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("[WIFI] OK %s RSSI=%d\n", WiFi.localIP().toString().c_str(), WiFi.RSSI());
    bleConfig.notifyConnected(WiFi.localIP().toString());
    conn = false;
    if (storage.isActivated()) {
      mqttServer = storage.getMQTTServer();
      mqttPort = storage.getMQTTPort();
      mqttUsername = storage.getMQTTUsername();
      mqttPassword = storage.getMQTTPassword();
      String did = storage.getDeviceId();
      topicPropertyPost = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/thing/event/property/post";
      topicPropertySet = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/thing/service/property/set";
      topicStatus = "/sys/" + String(PRODUCT_KEY) + "/" + did + "/status";
      mqttClientId = String(PRODUCT_KEY) + "&" + did;
      changeState(STATE_MQTT_CONNECTING);
    } else {
      changeState(STATE_ACTIVATING);
    }
    return;
  }
  if (millis() - start > WIFI_CONNECT_TIMEOUT) {
    Serial.println("[WIFI] Timeout - Retry in 5s");
    bleConfig.notifyStatus("error", "Timeout");
    conn = false;
    start = millis();  // 非阻塞：重置计时器，下次 loop 继续
  }
}

void handleStateActivating() {
  static unsigned long lastAttempt = 0;
  static bool attempted = false;

  // 非阻塞重试：每 5 秒尝试一次
  if (attempted && millis() - lastAttempt < 5000) return;

  Serial.println("[API] Activating...");
  if (bleConfig.hasApiUrl()) deviceAPI.setBaseUrl(bleConfig.getApiUrl());
  ActivationResult r = deviceAPI.activate();
  lastAttempt = millis();
  attempted = true;

  if (!r.success) {
    Serial.printf("[API] Fail: %s\n", r.errorMessage.c_str());
    bleConfig.notifyStatus("error", r.errorMessage);
    return;  // 非阻塞返回，下次 loop 会检查按钮
  }
  attempted = false;
  Serial.printf("[API] OK %s\n", r.deviceId.c_str());
  storage.saveDeviceConfig(r.deviceId, r.deviceSecret);
  storage.saveMQTTConfig(r.mqttServer, r.mqttPort, r.mqttUsername, r.mqttPassword);
  mqttServer = r.mqttServer;
  mqttPort = r.mqttPort;
  mqttUsername = r.mqttUsername;
  mqttPassword = r.mqttPassword;
  mqttClientId = r.mqttClientId;
  topicPropertyPost = r.topicPropertyPost;
  topicPropertySet = r.topicPropertySet;
  topicStatus = r.topicStatus;
  bleConfig.notifyActivated(r.deviceId);
  delay(1000);

  // 停止 BLE，释放资源
  Serial.println("[USB] Stopping BLE...");
  bleConfig.stop();
  delay(1000);
  Serial.println("[USB] BLE stopped, HID ready");

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
    conn = true;
    cnt = 0;
  }
  if (millis() - lastA < (unsigned long)retry) return;
  lastA = millis();
  cnt++;
  Serial.printf("[MQTT] #%d...\n", cnt);
  if (mqttClient.connect(mqttClientId.c_str(), mqttUsername.c_str(), mqttPassword.c_str())) {
    Serial.println("[MQTT] OK");
    mqttClient.subscribe(topicPropertySet.c_str());
    mqttClient.publish(topicStatus.c_str(), "{\"status\":\"online\"}");

    conn = false;
    retry = 1000;
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

  // LED 慢闪表示正常运行
  if (millis() - ledTime > 1000) {
    ledState = !ledState;
    digitalWrite(WAKEUP_LED_PIN, ledState);
    ledTime = millis();
  }
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
      for (int i = 0; i < 10; i++) { digitalWrite(WAKEUP_LED_PIN, HIGH); delay(50); digitalWrite(WAKEUP_LED_PIN, LOW); delay(50); }
      storage.clearAll();
      if (mqttClient.connected()) mqttClient.disconnect();
      WiFi.disconnect(true);
      delay(500);
      ESP.restart();
    }
  } else {
    if (buttonPressTime > 0 && !resetTriggered) changeState(currentState);
    buttonPressTime = 0;
    resetTriggered = false;
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

    if (p.containsKey("wakeup")) {
      bool wakeup = p["wakeup"];
      if (wakeup) {
        Serial.println("[CMD] wakeup!");
        sendWakeupSignal();
      }
    }

    mqttClient.publish(topicPropertyPost.c_str(), ("{\"method\":\"thing.service.property.set_reply\",\"id\":\"" + id + "\",\"code\":200}").c_str());
    reportStatus();
  }
}

void sendWakeupSignal() {
  Serial.println("[USB] Sending wakeup key...");
  sendUSBWakeup();
  Serial.println("[USB] Done!");
  blinkLED(2, 100);
}

void reportStatus() {
  if (!mqttClient.connected()) return;
  StaticJsonDocument<256> doc;
  doc["method"] = "thing.event.property.post";
  doc["id"] = String(millis());
  JsonObject p = doc.createNestedObject("params");
  p["wifi_rssi"] = WiFi.RSSI();
  p["uptime"] = millis()/1000;
  p["status"] = "online";
  char buf[256];
  serializeJson(doc, buf);
  mqttClient.publish(topicPropertyPost.c_str(), buf);
  Serial.printf("[REPORT] RSSI=%d\n", WiFi.RSSI());
}
