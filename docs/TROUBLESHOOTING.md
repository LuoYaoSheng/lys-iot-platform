# 故障排查

> Open IoT Platform 常见问题排查指南，涵盖服务端、数据库、MQTT、固件、BLE 和 Docker 等模块。

## 服务端问题

### 服务启动失败：端口被占用

**错误信息**：
```
listen tcp :48080: bind: address already in use
```

**解决方案**：

```bash
# 查找占用端口的进程
lsof -i :48080

# 终止进程
kill -9 <PID>

# 或修改 .env 中的端口
SERVER_PORT=48081
```

### Go 依赖下载失败

**解决方案**：

```bash
# 使用国内代理
go env -w GOPROXY=https://goproxy.cn,direct
go mod download
```

### 运行时 Panic

**排查步骤**：

```bash
# 查看完整堆栈
docker compose logs iot-core --tail=100

# 常见原因：
# - 数据库连接失败 → 检查 DB_HOST / DB_PORT
# - 配置项缺失 → 检查 .env
# - 空指针 → 检查数据库数据完整性
```

## 数据库问题

### 数据库连接失败

**错误信息**：
```
Error connecting to database: dial tcp 127.0.0.1:3306: connect: connection refused
```

**排查步骤**：

1. **检查 MySQL 容器状态**：
   ```bash
   docker compose ps mysql
   ```

2. **检查网络连通性**：
   ```bash
   nc -zv localhost 48306
   ```

3. **检查配置**：
   ```bash
   cat .env | grep DB_
   # Docker 部署时 DB_HOST 应为 mysql（服务名）
   # 本地运行时 DB_HOST 应为 localhost
   ```

4. **检查用户权限**：
   ```sql
   SELECT user, host FROM mysql.user WHERE user='root';
   GRANT ALL PRIVILEGES ON iot_platform.* TO 'root'@'%';
   FLUSH PRIVILEGES;
   ```

### 表不存在

**解决方案**：

```bash
# v0.3.0+ 自动初始化，重启服务即可
docker compose restart iot-core

# 手动初始化
docker exec -i iot-platform_mysql mysql -uroot -proot123456 iot_platform < scripts/init.sql
```

### 慢查询

```sql
-- 启用慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- 查看执行计划
EXPLAIN SELECT * FROM devices WHERE product_key = 'SW-SERVO-001';
```

## MQTT 问题

### 设备无法连接 MQTT

**排查步骤**：

1. **检查 Broker 服务**：
   ```bash
   docker compose ps
   # 确认 MQTT Broker 容器正常运行
   ```

2. **检查端口连通性**：
   ```bash
   nc -zv localhost 48883
   ```

3. **检查设备凭证**：
   ```bash
   # 查看数据库中的设备信息
   docker exec -it iot-platform_mysql mysql -uroot -proot123456 iot_platform
   SELECT device_id, status, device_secret FROM devices WHERE device_id = 'your-device-id';
   # 确认 status = 'active'
   ```

4. **检查 MQTT 连接参数**：
   ```c
   // ESP32 固件中确认
   username = "productKey&deviceId"  // 格式：产品Key & 设备ID
   password = "deviceSecret"          // 设备密钥
   port = 48883                       // v0.3.0 端口
   ```

5. **使用 mosquitto 测试**：
   ```bash
   mosquitto_pub -h localhost -p 48883 -t "test/topic" -m "test"
   ```

### 设备状态显示不准确

**原因**：设备离线但列表仍显示在线

**解决方案**：

1. 确认 Broker Webhook 已配置（上下线事件推送）
2. 检查 Redis 缓存是否正常
3. 重启后端触发一次全量同步

```bash
# 查看同步日志
docker compose logs iot-core | grep "DeviceSync"
```

### MQTT 认证失败

**错误码**：
| 返回码 | 含义 |
|--------|------|
| 5 | 认证失败（凭证无效） |
| 4 | 用户名或密码格式错误 |
| -1 | 网络连接失败 |

## 固件问题

### WiFi 连接失败

**排查步骤**：

1. 确认 WiFi 为 2.4GHz（ESP32 不支持 5GHz）
2. 确认密码正确（注意大小写和特殊字符）
3. 检查路由器是否限制了新设备接入
4. 查看串口日志：
   ```bash
   pio device monitor
   ```

### BLE 配网失败

**排查步骤**：

1. 确认设备已进入配网模式（LED 五次快闪）
2. Android 需开启位置服务 + 蓝牙权限
3. 距离设备 1 米以内
4. 关闭其他 BLE 连接应用（可能有冲突）

### 舵机异常旋转

**v0.3.0 已修复**：早期版本存在启动时大幅度旋转问题，请升级到 v0.3.0+。

### ESP32-S3 USB 日志不可用

USB HID 模式下 USB 串口被占用，需使用硬件 UART 查看日志：

```
ESP32-S3 TX (GPIO43) → USB-TTL RX
ESP32-S3 RX (GPIO44) → USB-TTL TX
ESP32-S3 GND → USB-TTL GND
```

## BLE 问题

### 扫描不到设备

- 确认设备已上电且未连接其他手机
- Android：开启定位 + 蓝牙权限
- iOS：确认蓝牙权限已授权
- 距离 1-3 米内效果最佳

### 配网后设备无响应

1. 确认 WiFi 连接成功（串口日志可见）
2. 确认服务端 API 可达
3. 确认 MQTT Broker 端口可达
4. 检查设备是否成功注册（查看数据库）

## Docker 问题

### 容器无法启动

```bash
# 查看容器日志
docker compose logs <service_name>

# 常见原因：
# 1. 端口冲突 → lsof -i :<port>
# 2. 镜像不存在 → docker compose pull
# 3. 磁盘空间不足 → df -h
# 4. 内存不足 → docker stats
```

### 容器间网络不通

```bash
# 检查网络
docker network inspect iot-platform_default

# 重建网络
docker compose down
docker compose up -d
```

### 数据丢失

Docker Volume 确保数据持久化：

```bash
# 查看 volumes
docker volume ls | grep iot

# 备份 MySQL
docker exec iot-platform_mysql mysqldump -uroot -proot123456 iot_platform > backup.sql
```

## 日志分析

### 查看日志

```bash
# 所有服务
docker compose logs -f

# 指定服务
docker compose logs -f iot-core

# 最近 100 行
docker compose logs --tail 100 iot-core

# 过滤关键字
docker compose logs iot-core | grep "ERROR"
```

### 日志标记

| 标记 | 模块 |
|------|------|
| `[MQTT]` | MQTT 连接/消息 |
| `[Auth]` | 认证授权 |
| `[DeviceSync]` | 设备状态同步 |
| `[Webhook]` | Webhook 事件 |

### 调整日志级别

```env
# .env
LOG_LEVEL=DEBUG  # DEBUG, INFO, WARN, ERROR
```

## 获取帮助

报告问题时请提供：

1. **错误信息**：完整日志
2. **环境信息**：`docker compose version && docker version`
3. **服务状态**：`docker compose ps`
4. **重现步骤**：详细操作过程

- [GitHub Issues](https://github.com/LuoYaoSheng/open-iot-platform/issues)
- [Gitee Issues](https://gitee.com/luoyaosheng/lys-iot-platform/issues)

## 相关文档

- [部署与运维](/DEPLOYMENT_GUIDE) — 部署指南
- [服务端开发指南](/SERVER_GUIDE) — 本地开发环境
- [固件开发指南](/FIRMWARE_GUIDE) — 固件相关问题
