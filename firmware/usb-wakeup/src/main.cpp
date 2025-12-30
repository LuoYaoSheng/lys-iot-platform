/**
 * ESP32-S3 USB Wakeup Device - USB HID Keyboard Test
 * 硬件: ESP32-S3-N16R8
 * 功能: 每10秒通过 USB HID 输入 "1"
 * 作者: 罗耀生
 * 日期: 2025-12-30
 */

#include <Arduino.h>
#include "USB.h"
#include "USBHIDKeyboard.h"

// ========== 配置 ==========
#define LED_BUILTIN     45
#define SERIAL_BAUD     115200
#define TEST_INTERVAL   10000  // 10秒

// ========== USB HID 键盘 ==========
USBHIDKeyboard Keyboard;

// ========== 状态变量 ==========
unsigned long lastTestTime = 0;
bool usbReady = false;

// ========== USB 事件回调 ==========
static void usbEventCallback(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) {
  if (event_base == ARDUINO_USB_EVENTS) {
    switch (event_id) {
      case ARDUINO_USB_STARTED_EVENT:
        Serial.println("[USB] Started");
        usbReady = true;
        break;
      case ARDUINO_USB_STOPPED_EVENT:
        Serial.println("[USB] Stopped");
        usbReady = false;
        break;
      case ARDUINO_USB_SUSPEND_EVENT:
        Serial.println("[USB] Suspended");
        break;
      case ARDUINO_USB_RESUME_EVENT:
        Serial.println("[USB] Resumed");
        break;
      default:
        break;
    }
  }
}

void setup() {
  // 初始化串口
  Serial.begin(SERIAL_BAUD);
  delay(1000);

  Serial.println("\n==============================");
  Serial.println("ESP32-S3 USB HID Keyboard Test");
  Serial.println("Will type '1' every 10 seconds");
  Serial.println("==============================\n");

  // 初始化 LED
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(200);
  digitalWrite(LED_BUILTIN, LOW);

  // 注册 USB 事件回调
  USB.onEvent(usbEventCallback);

  // 初始化 USB HID 键盘
  Keyboard.begin();
  USB.begin();

  Serial.println("[SETUP] USB HID Keyboard initialized");
  Serial.println("[SETUP] Waiting for USB connection...");

  // 等待 USB 连接（最多5秒）
  unsigned long startWait = millis();
  while (!usbReady && (millis() - startWait < 5000)) {
    delay(100);
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
  }
  digitalWrite(LED_BUILTIN, LOW);

  if (usbReady) {
    Serial.println("[SETUP] USB Ready! Starting test in 5 seconds...");
  } else {
    Serial.println("[SETUP] USB not ready, will retry when connected...");
  }

  // 第一次测试在 5 秒后
  lastTestTime = millis() - TEST_INTERVAL + 5000;
}

void loop() {
  // 每隔10秒
  if (millis() - lastTestTime >= TEST_INTERVAL) {
    lastTestTime = millis();

    // LED 闪烁表示即将输入
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(100);
      digitalWrite(LED_BUILTIN, LOW);
      delay(100);
    }

    if (usbReady) {
      // 通过 USB HID 键盘输入 "1"
      Serial.println("[TEST] Sending key '1' via USB HID...");
      Keyboard.press('1');
      delay(50);
      Keyboard.release('1');
      Serial.println("[TEST] Key sent successfully!");
    } else {
      Serial.println("[TEST] USB not ready, skipping key press...");
    }
  }

  delay(100);
}
