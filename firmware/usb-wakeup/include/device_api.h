/**
 * 设备激活 API 模块
 * 作者: 罗耀生
 * 日期: 2025-12-26
 * 更新: 2026-01-07 - 统一 HTTP 客户端实现与 switch 固件
 */

#ifndef DEVICE_API_H
#define DEVICE_API_H

#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <WiFi.h>
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

    String deviceSN = getDeviceSN();
    DEBUG_PRINT("[API] Activating device: ");
    DEBUG_PRINTLN(deviceSN);

    // 构建请求 URL
    String url = baseUrl + String(API_ACTIVATE_PATH);
    DEBUG_PRINT("[API] URL: ");
    DEBUG_PRINTLN(url);

    // 构建请求体
    StaticJsonDocument<256> reqDoc;
    reqDoc["productKey"] = PRODUCT_KEY;
    reqDoc["deviceSN"] = deviceSN;
    reqDoc["firmwareVersion"] = FIRMWARE_VERSION;
    reqDoc["chipModel"] = CHIP_MODEL;

    String reqBody;
    serializeJson(reqDoc, reqBody);
    DEBUG_PRINT("[API] Request: ");
    DEBUG_PRINTLN(reqBody);

    // 发送 HTTP 请求
    HTTPClient http;
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(API_TIMEOUT);

    int httpCode = http.POST(reqBody);
    DEBUG_PRINT("[API] Response code: ");
    DEBUG_PRINTLN(httpCode);

    if (httpCode <= 0) {
      result.errorMessage = "HTTP request failed: " + http.errorToString(httpCode);
      DEBUG_PRINTLN(result.errorMessage);
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
      result.errorMessage = "JSON parse error: " + String(error.c_str());
      DEBUG_PRINTLN(result.errorMessage);
      return result;
    }

    int code = respDoc["code"] | 0;

    // 处理错误响应
    if (code != 200 && code != 409) {
      result.errorMessage = respDoc["message"] | "Unknown error";
      DEBUG_PRINT("[API] Error = ");
      DEBUG_PRINTLN(result.errorMessage);
      return result;
    }

    // 解析成功响应
    JsonObject data = respDoc["data"];

    result.deviceId = data["deviceId"] | "";
    result.deviceSecret = data["deviceSecret"] | "";

    // 解析 MQTT 配置（嵌套在 mqtt 对象中）
    JsonObject mqtt = data["mqtt"];
    String serverStr = mqtt["server"] | "";
    result.mqttServer = serverStr;
    result.mqttPort = mqtt["port"] | 1883;
    result.mqttUsername = mqtt["username"] | "";
    result.mqttPassword = mqtt["password"] | "";
    result.mqttClientId = mqtt["clientId"] | "";

    // 解析 topics 配置（嵌套在 topics 对象中）
    JsonObject topics = data["topics"];
    result.topicPropertyPost = topics["propertyPost"] | "";
    result.topicPropertySet = topics["propertySet"] | "";
    result.topicStatus = topics["status"] | "";

    // 验证必要字段
    if (result.deviceId.length() == 0 || result.mqttServer.length() == 0) {
      result.errorMessage = "Missing required fields in response";
      DEBUG_PRINTLN(result.errorMessage);
      return result;
    }

    result.success = true;
    DEBUG_PRINTLN("[API] Activation successful!");
    DEBUG_PRINT("[API] MQTT Server = ");
    DEBUG_PRINTLN(result.mqttServer);

    return result;
  }
};

#endif // DEVICE_API_H
