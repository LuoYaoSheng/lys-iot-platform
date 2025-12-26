# IoT Platform Core - 开发环境启动脚本
# 使用 iot-platform Docker Compose 服务 (4开头端口)
# 作者: 罗耀生

# 本机 IP (ESP32 连接使用)
$LOCAL_IP = "192.168.21.77"

$env:DB_HOST = "localhost"
$env:DB_PORT = "43306"
$env:DB_USER = "root"
$env:DB_PASSWORD = "root123456"
$env:DB_NAME = "iot_platform"
$env:REDIS_HOST = "localhost"
$env:REDIS_PORT = "46379"
$env:SERVER_PORT = "48080"
$env:SERVER_HOST = "0.0.0.0"
$env:MQTT_BROKER = $LOCAL_IP
$env:MQTT_PORT = "41883"

Write-Host "Starting IoT Platform Core..." -ForegroundColor Green
Write-Host ""
Write-Host "=== 本地开发服务 ===" -ForegroundColor Cyan
Write-Host "MySQL: localhost:43306" -ForegroundColor Yellow
Write-Host "Redis: localhost:46379" -ForegroundColor Yellow
Write-Host ""
Write-Host "=== ESP32 连接地址 ===" -ForegroundColor Cyan
Write-Host "API Server: http://${LOCAL_IP}:48080" -ForegroundColor Green
Write-Host "MQTT Broker: ${LOCAL_IP}:41883" -ForegroundColor Green
Write-Host "EMQX Dashboard: http://${LOCAL_IP}:48084 (admin/public)" -ForegroundColor Yellow
Write-Host ""

go run ./cmd/server
