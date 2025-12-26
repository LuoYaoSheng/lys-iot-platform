/**
 * ESP32-S3 USB Wakeup Device - TEST MODE
 * 硬件: ESP32-S3-N16R8
 * 作者: 罗耀生
 * 日期: 2025-12-26
 */

#include <Arduino.h>

// ========== 配置 ==========
#define LED_BUILTIN     45
#define SERIAL_BAUD     115200
#define TEST_INTERVAL   10000  // 10秒

// ========== 简单版本 - 先用 Serial 测试 ==========
unsigned long lastTestTime = 0;

void setup() {
  // 初始化串口（使用硬件 UART，不依赖 USB CDC）
  Serial.begin(SERIAL_BAUD);
  delay(500);
  
  Serial.println("\n==============================");
  Serial.println("ESP32-S3 TEST - Serial Only");
  Serial.println("Waiting 5 seconds...");
  Serial.println("==============================\n");

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(500);
  digitalWrite(LED_BUILTIN, LOW);
  
  // 第一次测试在 5 秒后
  lastTestTime = millis() - TEST_INTERVAL + 5000;
}

void loop() {
  // 每隔10秒
  if (millis() - lastTestTime >= TEST_INTERVAL) {
    lastTestTime = millis();
    
    // LED 闪烁
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(100);
      digitalWrite(LED_BUILTIN, LOW);
      delay(100);
    }
    
    Serial.println("[TEST] 10 seconds passed! LED flashed!");
  }
  
  delay(100);
}
