@echo off
REM IoT Platform Core - 开发环境启动脚本
REM 作者: 罗耀生
REM 日期: 2025-12-13

echo ==========================================
echo IoT Platform Core - Development Environment
echo ==========================================
echo.

REM 检查 Docker 是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [1/3] Starting infrastructure services...
docker-compose -f docker-compose.dev.yml up -d

echo.
echo [2/3] Waiting for services to be ready...
timeout /t 10 /nobreak >nul

echo.
echo [3/3] Checking service status...
docker-compose -f docker-compose.dev.yml ps

echo.
echo ==========================================
echo Services started successfully!
echo ==========================================
echo.
echo MySQL:    localhost:3306 (user: iot_user, pass: iot123456)
echo Redis:    localhost:6379
echo EMQX:     localhost:1883 (MQTT)
echo          localhost:18083 (Dashboard - admin/public)
echo.
echo Next steps:
echo   1. Run Go service: go run ./cmd/server
echo   2. Test API: powershell -File scripts/test-api.ps1
echo.
pause
