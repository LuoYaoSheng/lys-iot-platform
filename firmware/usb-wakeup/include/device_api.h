/**
 * 设备激活 API 模块
 * 作者: 罗耀生
 * 日期: 2025-12-26
 */

#ifndef DEVICE_API_H
#define DEVICE_API_H

#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include "config.h"

// 激活结果结构
struct ActivationResult {
  bool success;
  String deviceId;
  String deviceSecret;
  String mqttServer;
  int mqttPort;
  String mqttUsername;
  String mqttPassword;
  String mqttClientId;
  String topicPropertyPost;
  String topicPropertySet;
  String topicStatus;
  String errorMessage;
};

class DeviceAPI {
private:
  String baseUrl;
  String deviceSN;

  // 生成设备 SN（基于 ESP32 芯片 ID）
  String generateSN() {
    uint64_t chipId = ESP.getEfuseMac();
    char sn[32];
    snprintf(sn, sizeof(sn), "S3-%08X", (uint32_t)(chipId >> 32));
    return String(sn);
  }

public:
  DeviceAPI() {
    baseUrl = String(API_BASE_URL);
    deviceSN = generateSN();
  }

  // 设置 API 基础 URL
  void setBaseUrl(const String& url) {
    baseUrl = url;
  }

  // 获取设备 SN
  String getDeviceSN() {
    return deviceSN;
  }

  // 设备激活
  ActivationResult activate() {
    ActivationResult result;
    result.success = false;

    DEBUG_PRINT("[API] Activating device: ");
    DEBUG_PRINTLN(deviceSN);

    HTTPClient http;
    WiFiClient client;

    String url = baseUrl + String(API_ACTIVATE_PATH);
    DEBUG_PRINT("[API] URL: ");
    DEBUG_PRINTLN(url);

    if (!http.begin(client, url)) {
      result.errorMessage = "Failed to connect";
      return result;
    }

    http.addHeader("Content-Type", "application/json");
    http.setTimeout(API_TIMEOUT);

    // 请求体
    StaticJsonDocument<256> reqDoc;
    reqDoc["productKey"] = PRODUCT_KEY;
    reqDoc["deviceSN"] = deviceSN;
    reqDoc["firmwareVersion"] = FIRMWARE_VERSION;
    reqDoc["chipModel"] = CHIP_MODEL;

    String reqBody;
    serializeJson(reqDoc, reqBody);

    DEBUG_PRINT("[API] Request: ");
    DEBUG_PRINTLN(reqBody);

    int httpCode = http.POST(reqBody);
    DEBUG_PRINT("[API] Response code: ");
    DEBUG_PRINTLN(httpCode);

    if (httpCode != 200) {
      result.errorMessage = "HTTP " + String(httpCode);
      http.end();
      return result;
    }

    String respBody = http.getString();
    DEBUG_PRINT("[API] Response: ");
    DEBUG_PRINTLN(respBody);

    http.end();

    // 解析响应
    StaticJsonDocument<1024> respDoc;
    DeserializationError error = deserializeJson(respDoc, respBody);

    if (error) {
      result.errorMessage = "JSON parse error";
      return result;
    }

    int code = respDoc["code"];
    if (code != 200) {
      result.errorMessage = respDoc["message"] | "Unknown error";
      return result;
    }

    JsonObject data = respDoc["data"];
    result.success = true;
    result.deviceId = data["deviceId"].as<String>();
    result.deviceSecret = data["deviceSecret"].as<String>();
    result.mqttServer = data["mqttServer"].as<String>();
    result.mqttPort = data["mqttPort"] | 1883;
    result.mqttUsername = data["mqttUsername"].as<String>();
    result.mqttPassword = data["mqttPassword"].as<String>();
    result.mqttClientId = data["mqttClientId"].as<String>();
    result.topicPropertyPost = data["topicPropertyPost"].as<String>();
    result.topicPropertySet = data["topicPropertySet"].as<String>();
    result.topicStatus = data["topicStatus"].as<String>();

    return result;
  }
};

#endif // DEVICE_API_H
