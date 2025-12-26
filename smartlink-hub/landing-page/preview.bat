@echo off
chcp 65001 >nul
REM ========================================
REM IoT Platform Landing Page 本地预览工具
REM 作者: 罗耀生
REM 日期: 2025-12-19
REM ========================================

echo ========================================
echo   IoT Platform Landing Page 本地预览
echo ========================================
echo.

REM 检查是否存在 index.html
if not exist "index.html" (
    echo [错误] 找不到 index.html 文件
    echo 请在 landing-page 目录下运行此脚本
    pause
    exit /b 1
)

echo [信息] 正在启动本地服务器...
echo.

REM 尝试使用 Python 启动服务器
where python >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 检测到 Python
    echo [信息] 服务器地址: http://localhost:8080
    echo [提示] 按 Ctrl+C 停止服务器
    echo.
    start http://localhost:8080
    python -m http.server 8080
    exit /b 0
)

REM 如果没有 Python,尝试使用 PHP
where php >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 检测到 PHP
    echo [信息] 服务器地址: http://localhost:8080
    echo [提示] 按 Ctrl+C 停止服务器
    echo.
    start http://localhost:8080
    php -S localhost:8080
    exit /b 0
)

REM 如果都没有,直接用浏览器打开文件
echo [警告] 未检测到 Python 或 PHP
echo [信息] 直接在浏览器中打开 HTML 文件
echo.
start index.html
pause
