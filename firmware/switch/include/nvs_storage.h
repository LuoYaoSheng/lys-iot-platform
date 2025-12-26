/**
 * NVS 存储模块 - 配置持久化
 * 作者: 罗耀生
 * 日期: 2025-12-13
 */

#ifndef NVS_STORAGE_H
#define NVS_STORAGE_H

#include <Preferences.h>
#include "config.h"

class NVSStorage {
private:
  Preferences preferences;

public:
  // 初始化
  bool begin() {
    return preferences.begin(NVS_NAMESPACE, false);
  }

  void end() {
    preferences.end();
  }

  // ==================== WiFi 配置 ====================
  void saveWiFiConfig(const String& ssid, const String& password) {
    preferences.putString(NVS_KEY_WIFI_SSID, ssid);
    preferences.putString(NVS_KEY_WIFI_PASS, password);
    DEBUG_PRINTLN("NVS: WiFi config saved");
  }

  String getWiFiSSID() {
    return preferences.getString(NVS_KEY_WIFI_SSID, "");
  }

  String getWiFiPassword() {
    return preferences.getString(NVS_KEY_WIFI_PASS, "");
  }

  bool hasWiFiConfig() {
    return getWiFiSSID().length() > 0;
  }

  // ==================== 设备配置 ====================
  void saveDeviceConfig(const String& deviceId, const String& deviceSecret) {
    preferences.putString(NVS_KEY_DEVICE_ID, deviceId);
    preferences.putString(NVS_KEY_DEVICE_SEC, deviceSecret);
    preferences.putBool(NVS_KEY_ACTIVATED, true);
    DEBUG_PRINTLN("NVS: Device config saved");
  }

  String getDeviceId() {
    return preferences.getString(NVS_KEY_DEVICE_ID, "");
  }

  String getDeviceSecret() {
    return preferences.getString(NVS_KEY_DEVICE_SEC, "");
  }

  bool isActivated() {
    return preferences.getBool(NVS_KEY_ACTIVATED, false);
  }

  // ==================== MQTT 配置 ====================
  void saveMQTTConfig(const String& server, int port, 
                      const String& username, const String& password) {
    preferences.putString(NVS_KEY_MQTT_SERVER, server);
    preferences.putInt(NVS_KEY_MQTT_PORT, port);
    preferences.putString(NVS_KEY_MQTT_USER, username);
    preferences.putString(NVS_KEY_MQTT_PASS, password);
    DEBUG_PRINTLN("NVS: MQTT config saved");
  }

  String getMQTTServer() {
    return preferences.getString(NVS_KEY_MQTT_SERVER, "");
  }

  int getMQTTPort() {
    return preferences.getInt(NVS_KEY_MQTT_PORT, 1883);
  }

  String getMQTTUsername() {
    return preferences.getString(NVS_KEY_MQTT_USER, "");
  }

  String getMQTTPassword() {
    return preferences.getString(NVS_KEY_MQTT_PASS, "");
  }

  bool hasMQTTConfig() {
    return getMQTTServer().length() > 0;
  }

  // ==================== 清除配置 ====================
  void clearAll() {
    preferences.clear();
    DEBUG_PRINTLN("NVS: All config cleared");
  }

  void clearWiFiConfig() {
    preferences.remove(NVS_KEY_WIFI_SSID);
    preferences.remove(NVS_KEY_WIFI_PASS);
    DEBUG_PRINTLN("NVS: WiFi config cleared");
  }

  void clearDeviceConfig() {
    preferences.remove(NVS_KEY_DEVICE_ID);
    preferences.remove(NVS_KEY_DEVICE_SEC);
    preferences.remove(NVS_KEY_MQTT_SERVER);
    preferences.remove(NVS_KEY_MQTT_PORT);
    preferences.remove(NVS_KEY_MQTT_USER);
    preferences.remove(NVS_KEY_MQTT_PASS);
    preferences.remove(NVS_KEY_ACTIVATED);
    DEBUG_PRINTLN("NVS: Device config cleared");
  }

  // ==================== 调试输出 ====================
  void printConfig() {
    DEBUG_PRINTLN("\n=== NVS Config ===");
    DEBUG_PRINT("WiFi SSID: "); DEBUG_PRINTLN(getWiFiSSID());
    DEBUG_PRINT("WiFi Pass: "); DEBUG_PRINTLN(getWiFiPassword().length() > 0 ? "***" : "(empty)");
    DEBUG_PRINT("Activated: "); DEBUG_PRINTLN(isActivated() ? "Yes" : "No");
    DEBUG_PRINT("Device ID: "); DEBUG_PRINTLN(getDeviceId());
    DEBUG_PRINT("MQTT Server: "); DEBUG_PRINTLN(getMQTTServer());
    DEBUG_PRINT("MQTT Port: "); DEBUG_PRINTLN(getMQTTPort());
    DEBUG_PRINTLN("==================\n");
  }
};

#endif // NVS_STORAGE_H
