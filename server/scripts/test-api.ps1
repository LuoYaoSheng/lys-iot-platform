# IoT Platform Core - API 测试脚本 (PowerShell)
# 作者: 罗耀生
# 日期: 2025-12-13

$API_URL = "http://localhost:8080"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "IoT Platform Core - API Test" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. 健康检查
Write-Host "`n[1] Health Check" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$API_URL/health" -Method Get
    $health | ConvertTo-Json
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 2. 设备激活
Write-Host "`n[2] Device Activate" -ForegroundColor Yellow
$activateBody = @{
    productKey = "SW-SERVO-001"
    deviceSN = "AABBCCDDEEFF"
    firmwareVersion = "1.0.0"
    chipModel = "ESP32-WROOM-32E"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_URL/api/v1/devices/activate" `
        -Method Post `
        -ContentType "application/json" `
        -Body $activateBody

    $response | ConvertTo-Json -Depth 5

    # 提取 MQTT 凭证
    $mqttUsername = $response.data.mqtt.username
    $mqttPassword = $response.data.mqtt.password
    $mqttClientId = $response.data.mqtt.clientId
    $deviceId = $response.data.deviceId

    Write-Host "`nMQTT Username: $mqttUsername" -ForegroundColor Green
    Write-Host "MQTT Password: $mqttPassword" -ForegroundColor Green
    Write-Host "MQTT ClientID: $mqttClientId" -ForegroundColor Green

    # 3. MQTT 认证测试
    Write-Host "`n[3] MQTT Auth Test" -ForegroundColor Yellow
    $authBody = @{
        username = $mqttUsername
        password = $mqttPassword
        clientid = $mqttClientId
    } | ConvertTo-Json

    $authResult = Invoke-RestMethod -Uri "$API_URL/api/v1/mqtt/auth" `
        -Method Post `
        -ContentType "application/json" `
        -Body $authBody

    $authResult | ConvertTo-Json

    # 4. MQTT ACL 测试
    $topic = "/sys/SW-SERVO-001/$deviceId/thing/event/property/post"
    Write-Host "`n[4] MQTT ACL Test (Topic: $topic)" -ForegroundColor Yellow

    $aclBody = @{
        username = $mqttUsername
        topic = $topic
        action = "publish"
    } | ConvertTo-Json

    $aclResult = Invoke-RestMethod -Uri "$API_URL/api/v1/mqtt/acl" `
        -Method Post `
        -ContentType "application/json" `
        -Body $aclBody

    $aclResult | ConvertTo-Json

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
