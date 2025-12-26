/**
 * 设备激活 API 模块 - 调用平台API获取MQTT配置
 * 作者: 罗耀生
 * 日期: 2025-12-13
 */

#ifndef DEVICE_API_H
#define DEVICE_API_H

#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include "config.h"

// 激活结果结构体
struct ActivationResult {
  bool success;
  String errorMessage;
  
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
};

class DeviceAPI {
private:
  String baseUrl;
  
public:
  DeviceAPI() {
    baseUrl = API_BASE_URL;
  }
  
  // 设置 API 地址
  void setBaseUrl(const String& url) {
    baseUrl = url;
  }
  
  // 获取设备 SN (MAC 地址)
  String getDeviceSN() {
    String mac = WiFi.macAddress();
    mac.replace(":", "");  // 移除冒号
    return mac;
  }
  
  // 设备激活
  ActivationResult activate() {
    ActivationResult result;
    result.success = false;
    
    String deviceSN = getDeviceSN();
    DEBUG_PRINT("API: Activating device, SN = ");
    DEBUG_PRINTLN(deviceSN);
    
    // 构建请求 URL
    String url = baseUrl + API_ACTIVATE_PATH;
    DEBUG_PRINT("API: URL = ");
    DEBUG_PRINTLN(url);
    
    // 构建请求体
    StaticJsonDocument<256> requestDoc;
    requestDoc["productKey"] = PRODUCT_KEY;
    requestDoc["deviceSN"] = deviceSN;
    requestDoc["firmwareVersion"] = FIRMWARE_VERSION;
    requestDoc["chipModel"] = CHIP_MODEL;
    
    String requestBody;
    serializeJson(requestDoc, requestBody);
    DEBUG_PRINT("API: Request = ");
    DEBUG_PRINTLN(requestBody);
    
    // 发送 HTTP 请求
    HTTPClient http;
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(API_TIMEOUT);
    
    int httpCode = http.POST(requestBody);
    DEBUG_PRINT("API: HTTP Code = ");
    DEBUG_PRINTLN(httpCode);
    
    if (httpCode <= 0) {
      result.errorMessage = "HTTP request failed: " + http.errorToString(httpCode);
      DEBUG_PRINTLN(result.errorMessage);
      http.end();
      return result;
    }
    
    String response = http.getString();
    DEBUG_PRINT("API: Response = ");
    DEBUG_PRINTLN(response);
    http.end();
    
    // 解析响应
    StaticJsonDocument<1024> responseDoc;
    DeserializationError error = deserializeJson(responseDoc, response);
    
    if (error) {
      result.errorMessage = "JSON parse error: " + String(error.c_str());
      DEBUG_PRINTLN(result.errorMessage);
      return result;
    }
    
    int code = responseDoc["code"] | 0;
    
    // 处理错误响应
    if (code != 200 && code != 409) {
      result.errorMessage = responseDoc["message"] | "Unknown error";
      DEBUG_PRINT("API: Error = ");
      DEBUG_PRINTLN(result.errorMessage);
      return result;
    }
    
    // 解析成功响应
    JsonObject data = responseDoc["data"];
    
    result.deviceId = data["deviceId"] | "";
    result.deviceSecret = data["deviceSecret"] | "";
    
    JsonObject mqtt = data["mqtt"];
    String serverStr = mqtt["server"] | "";

    // 解析 server 字段（可能包含端口）
    int colonPos = serverStr.indexOf(':');
    if (colonPos > 0) {
      // server 包含端口，例如 "117.50.216.173:42883"
      result.mqttServer = serverStr.substring(0, colonPos);
      result.mqttPort = serverStr.substring(colonPos + 1).toInt();
    } else {
      // server 不包含端口，使用单独的 port 字段
      result.mqttServer = serverStr;
      result.mqttPort = mqtt["port"] | 1883;
    }

    result.mqttUsername = mqtt["username"] | "";
    result.mqttPassword = mqtt["password"] | "";
    result.mqttClientId = mqtt["clientId"] | "";
    
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
    DEBUG_PRINTLN("API: Activation successful!");
    DEBUG_PRINT("API: Device ID = ");
    DEBUG_PRINTLN(result.deviceId);
    DEBUG_PRINT("API: MQTT Server = ");
    DEBUG_PRINTLN(result.mqttServer);
    
    return result;
  }
  
  // 获取设备配置（用于检查配置更新）
  bool getConfig(const String& deviceId, const String& deviceSecret) {
    // TODO: 实现获取配置接口
    return true;
  }
};

#endif // DEVICE_API_H
