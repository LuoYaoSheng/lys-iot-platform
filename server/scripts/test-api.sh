#!/bin/bash
# IoT Platform Core - API 测试脚本
# 作者: 罗耀生
# 日期: 2025-12-13

API_URL="http://localhost:8080"

echo "=========================================="
echo "IoT Platform Core - API Test"
echo "=========================================="

# 1. 健康检查
echo ""
echo "[1] Health Check"
curl -s "$API_URL/health" | jq .
echo ""

# 2. 设备激活
echo "[2] Device Activate"
RESPONSE=$(curl -s -X POST "$API_URL/api/v1/devices/activate" \
  -H "Content-Type: application/json" \
  -d '{
    "productKey": "SW-SERVO-001",
    "deviceSN": "AABBCCDDEEFF",
    "firmwareVersion": "1.0.0",
    "chipModel": "ESP32-WROOM-32E"
  }')

echo "$RESPONSE" | jq .
echo ""

# 提取 MQTT 凭证
MQTT_USERNAME=$(echo "$RESPONSE" | jq -r '.data.mqtt.username')
MQTT_PASSWORD=$(echo "$RESPONSE" | jq -r '.data.mqtt.password')
MQTT_CLIENTID=$(echo "$RESPONSE" | jq -r '.data.mqtt.clientId')

echo "MQTT Username: $MQTT_USERNAME"
echo "MQTT Password: $MQTT_PASSWORD"
echo "MQTT ClientID: $MQTT_CLIENTID"
echo ""

# 3. MQTT 认证测试
echo "[3] MQTT Auth Test"
curl -s -X POST "$API_URL/api/v1/mqtt/auth" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$MQTT_USERNAME\",
    \"password\": \"$MQTT_PASSWORD\",
    \"clientid\": \"$MQTT_CLIENTID\"
  }" | jq .
echo ""

# 4. MQTT ACL 测试
DEVICE_ID=$(echo "$RESPONSE" | jq -r '.data.deviceId')
TOPIC="/sys/SW-SERVO-001/$DEVICE_ID/thing/event/property/post"

echo "[4] MQTT ACL Test (Topic: $TOPIC)"
curl -s -X POST "$API_URL/api/v1/mqtt/acl" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$MQTT_USERNAME\",
    \"topic\": \"$TOPIC\",
    \"action\": \"publish\"
  }" | jq .
echo ""

echo "=========================================="
echo "Test completed!"
echo "=========================================="
