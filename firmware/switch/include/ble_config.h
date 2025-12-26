/**
 * BLE 配网模块 - 通过蓝牙接收WiFi配置和API地址
 * 作者: 罗耀生
 * 日期: 2025-12-13
 */

#ifndef BLE_CONFIG_H
#define BLE_CONFIG_H

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ArduinoJson.h>
#include "config.h"

// 回调函数类型
typedef void (*WiFiConfigCallback)(const String& ssid, const String& password);
typedef void (*StatusNotifyCallback)(const String& status);

class BLEConfigManager {
private:
  BLEServer* pServer = nullptr;
  BLECharacteristic* pWiFiCharacteristic = nullptr;
  BLECharacteristic* pStatusCharacteristic = nullptr;
  
  bool bleStarted = false;      // BLE是否已启动
  bool deviceConnected = false;
  bool configReceived = false;
  String receivedSSID = "";
  String receivedPassword = "";
  String receivedApiUrl = "";  // 新增：API地址
  
  WiFiConfigCallback onConfigReceived = nullptr;

  // BLE 服务器回调
  class ServerCallbacks : public BLEServerCallbacks {
    BLEConfigManager* manager;
  public:
    ServerCallbacks(BLEConfigManager* m) : manager(m) {}
    
    void onConnect(BLEServer* pServer) override {
      manager->deviceConnected = true;
      DEBUG_PRINTLN("BLE: Client connected");
    }
    
    void onDisconnect(BLEServer* pServer) override {
      manager->deviceConnected = false;
      DEBUG_PRINTLN("BLE: Client disconnected");
      // 重新开始广播
      pServer->startAdvertising();
    }
  };

  // WiFi 配置特征值回调
  class WiFiCharCallbacks : public BLECharacteristicCallbacks {
    BLEConfigManager* manager;
  public:
    WiFiCharCallbacks(BLEConfigManager* m) : manager(m) {}
    
    void onWrite(BLECharacteristic* pCharacteristic) override {
      String value = pCharacteristic->getValue().c_str();
      DEBUG_PRINT("BLE: Received config: ");
      DEBUG_PRINTLN(value);
      
      // 解析 JSON: {"ssid":"xxx","password":"xxx","apiUrl":"http://..."}
      StaticJsonDocument<512> doc;
      DeserializationError error = deserializeJson(doc, value);
      
      if (error) {
        DEBUG_PRINT("BLE: JSON parse error: ");
        DEBUG_PRINTLN(error.c_str());
        manager->notifyStatus("error", "Invalid JSON format");
        return;
      }
      
      if (!doc.containsKey("ssid") || !doc.containsKey("password")) {
        DEBUG_PRINTLN("BLE: Missing ssid or password");
        manager->notifyStatus("error", "Missing ssid or password");
        return;
      }
      
      manager->receivedSSID = doc["ssid"].as<String>();
      manager->receivedPassword = doc["password"].as<String>();
      
      // API 地址是可选的，如果提供则使用，否则使用默认值
      if (doc.containsKey("apiUrl")) {
        manager->receivedApiUrl = doc["apiUrl"].as<String>();
        DEBUG_PRINT("BLE: API URL = ");
        DEBUG_PRINTLN(manager->receivedApiUrl);
      }
      
      manager->configReceived = true;
      
      DEBUG_PRINT("BLE: SSID = ");
      DEBUG_PRINTLN(manager->receivedSSID);
      
      manager->notifyStatus("received", "Config received");
      
      // 触发回调
      if (manager->onConfigReceived) {
        manager->onConfigReceived(manager->receivedSSID, manager->receivedPassword);
      }
    }
  };

public:
  // 初始化 BLE
  void begin(const String& deviceName) {
    String bleName = String(BLE_DEVICE_PREFIX) + deviceName.substring(deviceName.length() - 4);
    
    DEBUG_PRINT("BLE: Initializing as ");
    DEBUG_PRINTLN(bleName);
    
    BLEDevice::init(bleName.c_str());
    
    // 创建 BLE 服务器
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks(this));
    
    // 创建 BLE 服务
    BLEService* pService = pServer->createService(BLE_SERVICE_UUID);
    
    // 创建 WiFi 配置特征值（可写 + 带响应）
    pWiFiCharacteristic = pService->createCharacteristic(
      BLE_CHAR_WIFI_UUID,
      BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
    );
    pWiFiCharacteristic->setCallbacks(new WiFiCharCallbacks(this));
    DEBUG_PRINTLN("BLE: WiFi char created with WRITE | WRITE_NR");
    
    // 创建状态通知特征值（可读 + 通知）
    pStatusCharacteristic = pService->createCharacteristic(
      BLE_CHAR_STATUS_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
    );
    pStatusCharacteristic->addDescriptor(new BLE2902());
    
    // 启动服务
    pService->start();
    
    // 开始广播
    BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(BLE_SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    bleStarted = true;
    
    DEBUG_PRINTLN("BLE: Advertising started");
  }
  
  // 停止 BLE
  void stop() {
    if (!bleStarted) return;
    DEBUG_PRINTLN("BLE: Stopping...");
    BLEDevice::deinit(true);
    bleStarted = false;
  }
  
  // 发送状态通知
  void notifyStatus(const String& status, const String& message = "") {
    if (!pStatusCharacteristic) return;
    
    StaticJsonDocument<256> doc;
    doc["status"] = status;
    if (message.length() > 0) {
      doc["message"] = message;
    }
    
    String json;
    serializeJson(doc, json);
    
    pStatusCharacteristic->setValue(json.c_str());
    pStatusCharacteristic->notify();
    
    DEBUG_PRINT("BLE: Status notify: ");
    DEBUG_PRINTLN(json);
  }
  
  // 通知连接成功
  void notifyConnected(const String& ip) {
    if (!pStatusCharacteristic) return;

    StaticJsonDocument<256> doc;
    doc["status"] = "wifi_connected";
    doc["ip"] = ip;
    
    String json;
    serializeJson(doc, json);
    
    pStatusCharacteristic->setValue(json.c_str());
    pStatusCharacteristic->notify();
  }
  
  // 通知激活成功
  void notifyActivated(const String& deviceId) {
     if (!pStatusCharacteristic) return;
     
    StaticJsonDocument<256> doc;
    doc["status"] = "activated";
    doc["deviceId"] = deviceId;
    
    String json;
    serializeJson(doc, json);
    
    pStatusCharacteristic->setValue(json.c_str());
    pStatusCharacteristic->notify();
  }
  
  // 设置配置接收回调
  void setConfigCallback(WiFiConfigCallback callback) {
    onConfigReceived = callback;
  }
  
  // 检查是否已连接
  bool isConnected() {
    return deviceConnected;
  }
  
  // 检查是否收到配置
  bool hasConfig() {
    return configReceived;
  }
  
  // 获取 SSID
  String getSSID() {
    return receivedSSID;
  }
  
  // 获取密码
  String getPassword() {
    return receivedPassword;
  }
  
  // 获取 API 地址
  String getApiUrl() {
    return receivedApiUrl;
  }
  
  // 检查是否有自定义 API 地址
  bool hasApiUrl() {
    return receivedApiUrl.length() > 0;
  }
  
  // 重置配置状态
  void resetConfig() {
    configReceived = false;
    receivedSSID = "";
    receivedPassword = "";
    receivedApiUrl = "";
  }
};

#endif // BLE_CONFIG_H
