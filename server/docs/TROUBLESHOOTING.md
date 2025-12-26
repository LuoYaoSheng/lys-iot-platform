# 故障排查指南

作者：罗耀生
最后更新：2025-12-16

---

## 📋 目录

- [常见问题](#常见问题)
- [后端服务问题](#后端服务问题)
- [数据库问题](#数据库问题)
- [MQTT连接问题](#mqtt连接问题)
- [EMQX Webhook问题](#emqx-webhook问题)
- [设备状态同步问题](#设备状态同步问题)
- [认证授权问题](#认证授权问题)
- [性能问题](#性能问题)
- [日志分析](#日志分析)

---

## 常见问题

### Q1: 服务启动失败，提示端口被占用

**错误信息**：
```
listen tcp :8080: bind: address already in use
```

**原因**：端口已被其他进程占用

**解决方案**：

**Windows**：
```bash
# 查找占用端口的进程
netstat -ano | findstr :8080

# 杀死进程（替换PID）
taskkill /F /PID <PID>
```

**Linux/Mac**：
```bash
# 查找占用端口的进程
lsof -i :8080

# 杀死进程（替换PID）
kill -9 <PID>
```

**或修改配置**：
```env
# .env
SERVER_PORT=8081  # 改为其他端口
```

---

### Q2: 数据库连接失败

**错误信息**：
```
Error connecting to database: dial tcp 127.0.0.1:3306: connect: connection refused
```

**排查步骤**：

**1. 检查MySQL服务状态**：
```bash
# Docker部署
docker-compose ps mysql

# 手动部署
sudo systemctl status mysql
```

**2. 检查网络连接**：
```bash
# 测试端口连通性
telnet localhost 3306
# 或
nc -zv localhost 3306
```

**3. 检查配置**：
```bash
# 查看.env配置
cat .env | grep DB_

# 确认配置正确
DB_HOST=localhost      # Docker部署应为 mysql
DB_PORT=3306
DB_USER=iot_user
DB_PASSWORD=<your-password>
DB_NAME=iot_platform
```

**4. 检查用户权限**：
```sql
-- 登录MySQL
mysql -u root -p

-- 检查用户
SELECT user, host FROM mysql.user WHERE user='iot_user';

-- 重新授权（如果需要）
GRANT ALL PRIVILEGES ON iot_platform.* TO 'iot_user'@'%';
FLUSH PRIVILEGES;
```

**5. Docker部署特殊检查**：
```bash
# 确保容器在同一网络
docker network inspect iot_network

# 测试容器间连通性
docker exec -it iot_backend ping mysql
```

---

### Q3: EMQX连接失败

**错误信息**：
```
MQTT connection failed: Network Error
```

**排查步骤**：

**1. 检查EMQX服务**：
```bash
# Docker部署
docker-compose ps emqx

# 手动部署
sudo systemctl status emqx
```

**2. 检查端口**：
```bash
# MQTT端口1883
telnet localhost 1883

# Dashboard端口18083
curl http://localhost:18083
```

**3. 检查配置**：
```bash
cat .env | grep MQTT_

# 确认配置
MQTT_BROKER=localhost  # Docker部署应为 emqx
MQTT_PORT=1883
```

**4. 测试MQTT连接**：
```bash
# 使用mosquitto客户端测试
mosquitto_pub -h localhost -p 1883 -t "test/topic" -m "test"

# 查看EMQX Dashboard
# http://localhost:18083
# 检查 Monitoring → Connections 是否有连接
```

**5. 检查防火墙**：
```bash
# Linux
sudo ufw status
sudo ufw allow 1883/tcp

# Windows
# 控制面板 → 防火墙 → 高级设置 → 入站规则 → 新建规则
```

---

### Q4: EMQX API认证失败

**错误信息**：
```
Warning: EMQX API connection failed: EMQX API认证失败: 401
{"code":"BAD_API_KEY_OR_SECRET","message":"Check api_key/api_secret"}
```

**原因**：EMQX 5.x使用API Key认证，不能使用admin/public

**解决方案**：

参考 [ENV_CONFIG.md](./ENV_CONFIG.md#如何获取emqx-api-key) 创建API Key

**快速步骤**：
1. 登录EMQX Dashboard：`http://localhost:18083`（注意端口18083）
2. 点击：**System（系统）** → **API Keys（API密钥）** → **+ Create（创建）**
3. 填写Name，点击创建
4. **立即复制**API Key和Secret Key（只显示一次！）
5. 更新`.env`：
   ```env
   EMQX_API_USERNAME=<你的API Key>
   EMQX_API_PASSWORD=<你的Secret Key>
   ```
6. 重启后端服务

**验证配置**：
```bash
# 测试API连接
curl -u "<API_KEY>:<SECRET_KEY>" http://localhost:18083/api/v5/nodes

# 应该返回节点信息，而不是401错误
```

---

### Q5: 设备状态显示不准确

**现象**：设备明明离线了，但列表仍显示在线

**原因分析**：

1. **EMQX API未配置**：后端无法查询设备真实在线状态
2. **Webhook未配置**：无法实时接收设备上下线事件
3. **网络断开但未发送断连消息**：设备异常断电

**解决方案**：

**1. 配置EMQX API Key**（必需）：
- 参考 [ENV_CONFIG.md](./ENV_CONFIG.md#emqx-api配置重要) 配置API Key
- 重启后端，查看日志：
  ```
  [EMQX] API连接测试成功
  [DeviceSync] 开始同步设备在线状态...
  ```

**2. 配置EMQX Webhook**（推荐）：
- 参考 [EMQX_WEBHOOK.md](./EMQX_WEBHOOK.md) 配置Webhook
- 实现实时状态更新

**3. 检查定时同步**：
```bash
# 查看日志，应该每5分钟看到
docker-compose logs backend | grep "DeviceSync"

# 应该看到：
# [DeviceSync] 执行定时设备状态同步...
# [DeviceSync] 同步完成: 在线=X, 离线=X
```

**4. 手动触发同步**（临时方案）：
```bash
# 重启后端会立即执行一次同步
docker-compose restart backend
```

---

### Q6: JWT Token过期，401错误

**现象**：APP或API请求返回401 Unauthorized

**原因**：Token过期（默认2小时有效期）

**正常行为**：
- APP会自动跳转到登录页
- 用户需要重新登录获取新Token

**如果需要延长有效期**（仅开发环境）：
```env
# .env
JWT_EXPIRE_HOURS=24  # 延长到24小时
```

**⚠️ 生产环境不建议**超过2小时，安全考虑。

---

### Q7: Webhook接收不到事件

**检查清单**：

**1. Webhook是否配置正确**：
```
URL: http://backend:8080/api/v1/webhook/mqtt/client-event
或
URL: http://<服务器IP>:8080/api/v1/webhook/mqtt/client-event
```

**2. 测试Webhook连通性**：
```bash
# 从EMQX容器测试
docker exec -it iot_emqx curl http://backend:8080/health

# 从外部测试
curl -X POST http://localhost:8080/api/v1/webhook/mqtt/client-event \
  -H "Content-Type: application/json" \
  -d '{
    "event": "client.connected",
    "clientid": "test",
    "username": "testProduct&testDevice",
    "peerhost": "192.168.1.100",
    "timestamp": 1734336000000
  }'
```

**3. 查看EMQX Webhook状态**：
- 访问EMQX Dashboard：http://localhost:18083
- Integration → Webhook → 检查状态
- 查看Success/Failed计数

**4. 查看后端日志**：
```bash
docker-compose logs backend | grep "Webhook"

# 应该看到：
# [Webhook] 客户端事件: client.connected, clientId=xxx
```

---

### Q8: 设备无法连接到MQTT

**设备端排查**：

**1. 检查连接参数**：
```c
// ESP32固件
const char* mqtt_server = "your-server-ip";  // 确认IP正确
const int mqtt_port = 1883;                   // 确认端口正确
const char* username = "productKey&deviceId"; // 格式正确
const char* password = "deviceSecret";        // 密钥正确
```

**2. 检查网络连通性**：
- 设备能否ping通服务器
- 端口1883是否开放
- 使用natapp穿透时，确认映射正确

**3. 查看设备日志**：
```
MQTT连接失败，返回码：5 → 认证失败
MQTT连接失败，返回码：4 → 用户名或密码错误
MQTT连接失败，返回码：-1 → 网络连接失败
```

**服务端排查**：

**1. 查看EMQX Dashboard**：
- http://localhost:18083
- Monitoring → Connections → 搜索ClientID
- 查看连接失败原因

**2. 查看EMQX日志**：
```bash
docker-compose logs emqx | grep "authentication failed"
```

**3. 检查设备激活状态**：
```bash
# 查询数据库
docker exec -it iot_mysql mysql -u iot_user -p iot_platform

SELECT device_id, status, device_secret
FROM devices
WHERE device_id = 'your-device-id';

# 确认：
# - status = 'active' （已激活）
# - device_secret 与固件中一致
```

---

## 后端服务问题

### 编译失败

**常见错误**：

**1. 依赖下载失败**：
```bash
# 使用国内代理
go env -w GOPROXY=https://goproxy.cn,direct

# 重新下载依赖
go mod download
```

**2. 版本不兼容**：
```bash
# 清理缓存
go clean -modcache

# 更新依赖
go mod tidy
```

### 运行时Panic

**查看完整堆栈**：
```bash
docker-compose logs backend --tail=100

# 手动部署
journalctl -u iot-platform -n 100
```

**常见Panic原因**：
- 数据库连接失败
- 配置项缺失
- 空指针访问

---

## 数据库问题

### 数据库初始化失败

**错误**：表不存在

**解决**：
```bash
# 执行初始化SQL
docker exec -i iot_mysql mysql -u iot_user -p iot_platform < init.sql

# 或登录手动执行
docker exec -it iot_mysql mysql -u iot_user -p
```

### 性能慢查询

**启用慢查询日志**：
```sql
-- 临时启用
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- 超过2秒记录

-- 查看慢查询
SHOW VARIABLES LIKE 'slow_query_log_file';
```

**分析查询**：
```sql
-- 查看执行计划
EXPLAIN SELECT * FROM devices WHERE ...;

-- 检查索引使用
SHOW INDEX FROM devices;
```

---

## MQTT连接问题

### TLS连接失败

如果启用了TLS加密：

**检查证书**：
```bash
# 验证证书有效性
openssl s_client -connect localhost:8883
```

**检查配置**：
- 证书路径正确
- 证书未过期
- CA证书包含完整链

---

## EMQX Webhook问题

### 返回非200状态码

EMQX会认为Webhook失败，可能会重试。

**检查后端处理逻辑**：
```go
// webhook_handler.go
// 确保返回200
response.Success(c, gin.H{"message": "ok"})
```

### 格式不兼容

**后端已支持EMQX默认格式**：
- 使用`peerhost`或`ipaddress`字段都可以
- 不需要自定义Body

---

## 设备状态同步问题

### 启动同步未执行

**检查日志**：
```bash
docker-compose logs backend | grep "DeviceSync"

# 应该看到：
# [DeviceSync] 开始同步设备在线状态...
# [EMQX] 查询到 X 个在线客户端
# [DeviceSync] 同步完成: 在线=X, 离线=X
```

**未执行的原因**：
- EMQX API配置错误
- EMQX服务未启动
- 网络不通

### 定时同步未运行

**检查配置**：
```env
EMQX_SYNC_INTERVAL=5  # 间隔5分钟
```

**查看日志**：
```bash
# 应该每5分钟看到一次
docker-compose logs backend -f | grep "定时同步"
```

---

## 认证授权问题

### API Key无效

**错误**：Invalid API Key

**解决**：
```bash
# 检查数据库
SELECT * FROM api_keys WHERE api_key = 'your-key';

# 检查：
# - status = 'active'
# - expires_at > NOW()
```

### 权限不足

**错误**：403 Forbidden

**检查**：
- 用户角色是否正确
- 项目成员权限
- API Key权限范围

---

## 性能问题

### 响应慢

**排查步骤**：

1. **检查数据库查询**：启用慢查询日志
2. **检查网络延迟**：ping测试
3. **检查资源使用**：CPU、内存、磁盘IO
4. **检查日志级别**：过多日志输出影响性能

**优化建议**：
- 添加数据库索引
- 启用Redis缓存
- 使用连接池
- 优化SQL查询

### 内存占用高

**排查**：
```bash
# 查看容器资源使用
docker stats

# Go程序内存分析
go tool pprof http://localhost:6060/debug/pprof/heap
```

---

## 日志分析

### 查看实时日志

```bash
# 所有服务
docker-compose logs -f

# 特定服务
docker-compose logs -f backend

# 过滤关键字
docker-compose logs backend | grep "ERROR"
```

### 日志级别

默认日志级别：`INFO`

**调整级别**（如需要）：
```env
LOG_LEVEL=DEBUG  # DEBUG, INFO, WARN, ERROR
```

### 重要日志标记

- `[EMQX]` - EMQX API相关
- `[DeviceSync]` - 设备状态同步
- `[Webhook]` - Webhook事件
- `[MQTT]` - MQTT连接
- `[Auth]` - 认证授权

---

## 获取帮助

### 收集故障信息

报告问题时请提供：

1. **错误信息**：完整的错误日志
2. **环境信息**：
   ```bash
   docker-compose version
   docker version
   cat .env | grep -v PASSWORD
   ```
3. **服务状态**：
   ```bash
   docker-compose ps
   ```
4. **重现步骤**：详细操作步骤

### 联系支持

- **Issue跟踪**：项目GitHub Issues
- **技术支持**：联系开发团队

---

**遇到问题先不要慌，按照本指南逐步排查，大多数问题都能快速解决！**
