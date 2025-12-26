@echo off
REM IoT Platform Core - 停止开发环境
REM 作者: 罗耀生
REM 日期: 2025-12-13

echo Stopping IoT Platform Core development services...
docker-compose -f docker-compose.dev.yml down

echo.
echo Services stopped.
pause
