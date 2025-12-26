/**
 * ESP32-S3 USB Wakeup Device - TEST MODE
 * 硬件: ESP32-S3-N16R8
 * 作者: 罗耀生
 * 日期: 2025-12-26
 *
 * 测试模式：每隔10秒自动输入数字1
 */

#include <Arduino.h>
#include <USB.h>
#include <USBHIDKeyboard.h>
#include <USBCDC.h>

// ========== 配置 ==========
#define LED_BUILTIN     45
#define SERIAL_BAUD     115200
#define TEST_INTERVAL   10000  // 10秒

// ========== 全局对象 ==========
USBHIDKeyboard usbKeyboard;
USBCDC usbSerial;

// ========== 变量 ==========
unsigned long lastTestTime = 0;

// ========== USB 事件回调 ==========
void usbEventCallback(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) {
  if (event_base == ARDUINO_USB_EVENTS) {
    arduino_usb_event_data_t* data = (arduino_usb_event_data_t*)event_data;
    switch (event_id) {
      case ARDUINO_USB_STARTED_EVENT:
        usbSerial.println("[USB] PLUGGED");
        break;
      case ARDUINO_USB_STOPPED_EVENT:
        usbSerial.println("[USB] UNPLUGGED");
        break;
      case ARDUINO_USB_SUSPEND_EVENT:
        usbSerial.println("[USB] SUSPENDED");
        break;
      case ARDUINO_USB_RESUME_EVENT:
        usbSerial.println("[USB] RESUMED");
        break;
    }
  }
}

// ========== 主函数 ==========
void setup() {
  Serial.begin(SERIAL_BAUD);
  delay(100);
  Serial.println("\n==============================");
  Serial.println("ESP32-S3 USB Wakeup - TEST MODE");
  Serial.println("Interval: 10 seconds");
  Serial.println("Pressing: '1'");
  Serial.println("==============================\n");
  
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);

  // 初始化 USB HID
  USB.onEvent(usbEventCallback);
  usbKeyboard.onEvent(usbEventCallback);
  usbSerial.onEvent(usbEventCallback);

  usbKeyboard.begin();
  usbSerial.begin(115200);
  USB.manufacturerName("Luo Yaosheng");
  USB.productName("ESP32-Test");
  USB.begin();

  Serial.println("[INIT] USB HID ready");
  Serial.println("[TEST] Starting in 3 seconds...");
  
  digitalWrite(LED_BUILTIN, LOW);
  delay(3000);
}

void loop() {
  // 每隔10秒输入数字1
  if (millis() - lastTestTime >= TEST_INTERVAL) {
    lastTestTime = millis();
    
    // LED 闪烁提示
    digitalWrite(LED_BUILTIN, HIGH);
    delay(100);
    digitalWrite(LED_BUILTIN, LOW);
    
    // 发送按键
    Serial.println("[TEST] Pressing key '1'...");
    usbKeyboard.write('1');
  }
  
  delay(100);
}
