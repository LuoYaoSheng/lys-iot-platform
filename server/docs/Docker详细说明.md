# IoT Platform - Docker 一键部署指南

作者：罗耀生
日期：2025-12-16

## 🚀 快速开始（仅需3步）

### 1. 克隆代码

```bash
git clone https://gitee.com/luoyaosheng/iot-platform-core.git
cd iot-platform-core
```

### 2. 修改配置（可选）

编辑 `.env` 文件，修改 `MQTT_BROKER_EXTERNAL` 为你的服务器IP或域名：

```env
MQTT_BROKER_EXTERNAL=你的服务器IP   # ESP32设备连接用
```

### 3. 启动所有服务

```bash
docker compose up -d
```

**就这么简单！** 🎉

## 📱 App配置

### 安装App后配置服务器地址：

1. 打开App
2. 点击登录页面**右上角服务器图标**
3. 输入你的服务器地址：
   - **API服务器地址**：`http://your-server-ip:48080`
   - **MQTT服务器地址**：`your-server-ip`
4. 保存并重启App
5. 注册/登录使用

## 📦 包含的服务

| 服务 | 端口 | 访问地址 |
|------|------|---------|
| 后端API | 48080 | http://localhost:48080 |
| MySQL | 48306 | localhost:48306 |
| Redis | 48379 | localhost:48379 |
| MQTT (EMQX) | 48883 | localhost:48883 |
| EMQX Dashboard | 48884 | http://localhost:48884 |

**EMQX Dashboard 登录：**
- 用户名：`admin`
- 密码：`public`

## 🔧 常用命令

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f

# 停止所有服务
docker compose down

# 重启服务
docker compose restart

# 更新镜像
docker compose pull
docker compose up -d
```

## 📋 完整用户流程

### 1. 部署服务器
```bash
# 在服务器上执行
docker compose up -d
```

### 2. 配置App
- 下载并安装App
- 配置服务器地址（登录页右上角）

### 3. 准备硬件
- 购买ESP32开发板
- 烧录固件（位于 `iot-device-firmware-switch`）
- 通过App进行BLE配网

### 4. 开始使用
- 设备上线后即可在App中控制
- 支持Toggle模式（三档位）
- 支持Pulse模式（触发+延时）

## 🐳 Docker镜像信息

- **镜像名称**：`luoyaosheng/iot-platform-core:latest`
- **镜像大小**：53.9MB
- **架构支持**：linux/amd64

## 🔍 故障排查

### 问题1：容器无法启动

```bash
# 检查容器日志
docker compose logs iot-platform-core

# 检查端口是否被占用
netstat -ano | findstr "48080"
```

### 问题2：设备无法连接MQTT

1. 确认 `.env` 中的 `MQTT_BROKER_EXTERNAL` 配置正确
2. 确认防火墙开放了48883端口
3. 查看EMQX日志：`docker compose logs emqx`

### 问题3：App无法连接

1. 确认服务器地址配置正确
2. 确认服务器防火墙开放了48080端口
3. 尝试使用浏览器访问：`http://your-server-ip:48080/health`

## 📞 技术支持

如有问题，请提交Issue到：
- 后端：https://gitee.com/luoyaosheng/iot-platform-core/issues
- App：https://gitee.com/luoyaosheng/iot-config-app/issues

## 📄 许可证

MIT License
