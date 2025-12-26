/**
 * NVS 存储管理模块
 * 作者: 罗耀生
 * 日期: 2025-12-26
 */

#ifndef NVS_STORAGE_H
#define NVS_STORAGE_H

#include <Preferences.h>
#include "config.h"

class NVSStorage {
private:
  Preferences prefs;
  bool initialized = false;

public:
  // 初始化
  bool begin() {
    if (initialized) return true;
    initialized = prefs.begin(NVS_NAMESPACE, false);
    return initialized;
  }

  // === WiFi 配置 ===
  bool hasWiFiConfig() {
    if (!begin()) return false;
    return prefs.isKey(NVS_KEY_WIFI_SSID);
  }

  void saveWiFiConfig(const String& ssid, const String& password) {
    if (!begin()) return;
    prefs.putString(NVS_KEY_WIFI_SSID, ssid);
    prefs.putString(NVS_KEY_WIFI_PASS, password);
    DEBUG_PRINTLN("[NVS] WiFi config saved");
  }

  String getWiFiSSID() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_WIFI_SSID, "");
  }

  String getWiFiPassword() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_WIFI_PASS, "");
  }

  // === 设备信息 ===
  bool isActivated() {
    if (!begin()) return false;
    return prefs.getBool(NVS_KEY_ACTIVATED, false);
  }

  void setActivated(bool activated) {
    if (!begin()) return;
    prefs.putBool(NVS_KEY_ACTIVATED, activated);
  }

  void saveDeviceConfig(const String& deviceId, const String& deviceSecret) {
    if (!begin()) return;
    prefs.putString(NVS_KEY_DEVICE_ID, deviceId);
    prefs.putString(NVS_KEY_DEVICE_SEC, deviceSecret);
    prefs.putBool(NVS_KEY_ACTIVATED, true);
    DEBUG_PRINTLN("[NVS] Device config saved");
  }

  String getDeviceId() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_DEVICE_ID, "");
  }

  String getDeviceSecret() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_DEVICE_SEC, "");
  }

  // === MQTT 配置 ===
  void saveMQTTConfig(const String& server, int port, const String& username, const String& password) {
    if (!begin()) return;
    prefs.putString(NVS_KEY_MQTT_SERVER, server);
    prefs.putInt(NVS_KEY_MQTT_PORT, port);
    prefs.putString(NVS_KEY_MQTT_USER, username);
    prefs.putString(NVS_KEY_MQTT_PASS, password);
    DEBUG_PRINTLN("[NVS] MQTT config saved");
  }

  String getMQTTServer() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_MQTT_SERVER, "");
  }

  int getMQTTPort() {
    if (!begin()) return 1883;
    return prefs.getInt(NVS_KEY_MQTT_PORT, 1883);
  }

  String getMQTTUsername() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_MQTT_USER, "");
  }

  String getMQTTPassword() {
    if (!begin()) return "";
    return prefs.getString(NVS_KEY_MQTT_PASS, "");
  }

  // === 清除所有 ===
  void clearAll() {
    if (!begin()) return;
    prefs.clear();
    DEBUG_PRINTLN("[NVS] All data cleared");
  }

  // === 打印配置 ===
  void printConfig() {
    if (!begin()) return;
    DEBUG_PRINTLN("[NVS] Stored config:");
    DEBUG_PRINT("  SSID: ");
    DEBUG_PRINTLN(getWiFiSSID());
    DEBUG_PRINT("  Device ID: ");
    DEBUG_PRINTLN(getDeviceId());
    DEBUG_PRINT("  Activated: ");
    DEBUG_PRINTLN(isActivated() ? "Yes" : "No");
  }
};

#endif // NVS_STORAGE_H
