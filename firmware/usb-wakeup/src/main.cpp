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
bool usbReady = false;

// ========== USB 事件回调 ==========
void usbEventCallback(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) {
  if (event_base == ARDUINO_USB_EVENTS) {
    arduino_usb_event_data_t* data = (arduino_usb_event_data_t*)event_data;
    switch (event_id) {
      case ARDUINO_USB_STARTED_EVENT:
        usbSerial.println("[USB] STARTED - Ready!");
        usbReady = true;
        break;
      case ARDUINO_USB_STOPPED_EVENT:
        usbSerial.println("[USB] STOPPED");
        usbReady = false;
        break;
      case ARDUINO_USB_SUSPEND_EVENT:
        usbSerial.println("[USB] SUSPENDED");
        usbReady = false;
        break;
      case ARDUINO_USB_RESUME_EVENT:
        usbSerial.println("[USB] RESUMED");
        usbReady = true;
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

  // 初始化 USB HID - 必须在 USB.begin() 之前设置回调
  USB.onEvent(usbEventCallback);
  usbKeyboard.onEvent(usbEventCallback);
  usbSerial.onEvent(usbEventCallback);

  usbKeyboard.begin();
  usbSerial.begin(115200);

  // 设置 USB 设备信息
  USB.manufacturerName("Luo Yaosheng");
  USB.productName("ESP32-Test");

  // 启动 USB
  USB.begin();

  Serial.println("[INIT] USB initializing...");
  Serial.println("[INIT] Waiting for USB ready...");

  digitalWrite(LED_BUILTIN, LOW);

  // 等待 USB 初始化完成
  delay(2000);

  // 第一次测试时间设为当前时间 + 5秒，确保 USB 完全就绪
  lastTestTime = millis() - TEST_INTERVAL + 5000;

  Serial.println("[INIT] Ready! First test in 5 seconds...");
}

void loop() {
  // 只有 USB 就绪后才执行测试
  if (usbReady && (millis() - lastTestTime >= TEST_INTERVAL)) {
    lastTestTime = millis();

    // LED 闪烁提示
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);

    // 发送按键
    Serial.println("[TEST] Pressing key '1'...");
    usbKeyboard.write('1');
    Serial.println("[TEST] Done!");
  }

  delay(100);
}
