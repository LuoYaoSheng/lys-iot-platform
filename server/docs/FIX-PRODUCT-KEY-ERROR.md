# 线上部署快速修复指南

**问题**: 配网时提示 `invalid_product_key`
**原因**: 线上数据库缺少产品数据
**修复时间**: 1分钟

---

## 🚑 快速修复步骤

### 方法一：使用修复脚本（推荐）

```bash
# 1. 登录服务器
ssh root@117.50.216.173

# 2. 进入项目目录
cd /path/to/iot-platform-core

# 3. 执行修复脚本
docker-compose exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} iot_platform < scripts/fix-product-data.sql

# 或者直接使用 MySQL 命令
docker-compose exec mysql mysql -uroot -proot123 iot_platform -e "
INSERT INTO products (product_key, name, description, category, status) VALUES
('SW-SERVO-001', '智能开关(舵机版)', 'ESP32智能舵机开关', 'switch', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name);
"
```

### 方法二：手动执行SQL

```bash
# 1. 连接数据库
docker-compose exec mysql mysql -uroot -proot123 iot_platform

# 2. 执行以下SQL
INSERT INTO products (product_key, name, description, category, status) VALUES
('SW-SERVO-001', '智能开关(舵机版)', 'ESP32智能舵机开关，支持BLE配网和MQTT控制', 'switch', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name);

# 3. 验证数据
SELECT * FROM products WHERE product_key = 'SW-SERVO-001';

# 4. 退出
exit;
```

### 方法三：使用 Navicat/DBeaver 等工具

1. 连接到线上数据库：`117.50.216.173:3306`
2. 打开 SQL 编辑器
3. 执行 `scripts/fix-product-data.sql` 脚本
4. 验证 `products` 表有数据

---

## ✅ 验证修复结果

### 1. 检查产品数据

```bash
docker-compose exec mysql mysql -uroot -proot123 iot_platform -e "
SELECT product_key, name, category, status FROM products;
"
```

**期望输出**:
```
+---------------+--------------------+----------+--------+
| product_key   | name               | category | status |
+---------------+--------------------+----------+--------+
| SW-SERVO-001  | 智能开关(舵机版)     | switch   |      1 |
+---------------+--------------------+----------+--------+
```

### 2. 测试设备激活

```bash
# 方法A: 使用 curl 测试激活接口
curl -X POST http://117.50.216.173:48080/api/v1/devices/activate \
  -H "Content-Type: application/json" \
  -d '{
    "productKey": "SW-SERVO-001",
    "deviceSN": "TEST-ESP32-001",
    "firmwareVersion": "1.0.0",
    "chipModel": "ESP32-WROOM-32E"
  }'

# 期望返回 200 OK
# {"code":0,"data":{"deviceId":"dev_xxx","deviceSecret":"sk_xxx",...}}
```

### 3. APP配网测试

1. 打开 APP，扫描设备
2. 连接设备，输入 WiFi 信息
3. 等待配网完成
4. ✅ 不再提示 `invalid_product_key`

---

## 📋 线上部署检查清单

为避免类似问题，建议每次部署时执行以下检查：

### 部署前检查

- [ ] Docker 服务正常运行 (`docker ps`)
- [ ] MySQL 容器健康 (`docker-compose ps mysql`)
- [ ] Redis 容器健康 (`docker-compose ps redis`)
- [ ] EMQX 容器健康 (`docker-compose ps emqx`)

### 数据库初始化检查

```bash
# 检查表是否存在
docker-compose exec mysql mysql -uroot -proot123 iot_platform -e "SHOW TABLES;"

# 期望输出包含:
# - products
# - devices
# - mqtt_auth_logs

# 检查产品数据
docker-compose exec mysql mysql -uroot -proot123 iot_platform -e "SELECT COUNT(*) FROM products;"

# 期望输出: COUNT(*) > 0
```

### 应用服务检查

```bash
# 检查服务日志
docker-compose logs -f --tail=50 api

# 期望看到:
# - "Server started on :8080"
# - "Database connected successfully"
# - "Redis connected successfully"
```

### API 接口检查

```bash
# 健康检查
curl http://117.50.216.173:48080/health

# 产品列表
curl http://117.50.216.173:48080/api/v1/products

# MQTT 认证（测试）
curl -X POST http://117.50.216.173:48080/api/v1/mqtt/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test","clientid":"test"}'
```

---

## 🔧 预防措施

### 1. 更新部署脚本

在 `docker-compose.yml` 中添加初始化检查：

```yaml
services:
  mysql:
    # ...
    volumes:
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql  # 自动执行
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### 2. 创建部署检查脚本

```bash
#!/bin/bash
# scripts/check-deployment.sh

echo "=== IoT Platform Deployment Check ==="

# 1. 检查 Docker 服务
echo "Checking Docker services..."
docker-compose ps

# 2. 检查数据库
echo "Checking database..."
PRODUCT_COUNT=$(docker-compose exec -T mysql mysql -uroot -proot123 iot_platform -sN -e "SELECT COUNT(*) FROM products;")

if [ "$PRODUCT_COUNT" -eq 0 ]; then
  echo "❌ Products table is empty! Running fix script..."
  docker-compose exec -T mysql mysql -uroot -proot123 iot_platform < scripts/fix-product-data.sql
  echo "✅ Products data fixed"
else
  echo "✅ Products data OK ($PRODUCT_COUNT products)"
fi

# 3. 检查 API
echo "Checking API..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:48080/health)
if [ "$API_STATUS" -eq 200 ]; then
  echo "✅ API is healthy"
else
  echo "❌ API is down (HTTP $API_STATUS)"
fi

echo "=== Check Complete ==="
```

### 3. 添加到 CI/CD 流程

```yaml
# .github/workflows/deploy.yml
- name: Check Database
  run: |
    chmod +x scripts/check-deployment.sh
    ./scripts/check-deployment.sh
```

---

## 📞 故障排查

### 问题 1: 仍然提示 invalid_product_key

**检查步骤**:
```bash
# 1. 确认产品数据
docker-compose exec mysql mysql -uroot -proot123 iot_platform -e "
SELECT * FROM products WHERE product_key='SW-SERVO-001';
"

# 2. 查看服务端日志
docker-compose logs api | grep "invalid_product_key"

# 3. 检查固件 ProductKey
# 查看硬件端 config.h 确认 PRODUCT_KEY 值
```

### 问题 2: 数据库连接失败

**检查步骤**:
```bash
# 1. 检查 MySQL 容器
docker-compose ps mysql

# 2. 查看 MySQL 日志
docker-compose logs mysql

# 3. 测试连接
docker-compose exec mysql mysql -uroot -proot123 -e "SELECT 1;"
```

### 问题 3: 端口被占用

```bash
# 检查端口占用
netstat -tulpn | grep :48080
netstat -tulpn | grep :3306

# 修改 docker-compose.yml 端口映射
```

---

## 📚 相关文档

- [数据库初始化脚本](../scripts/init.sql)
- [修复脚本](../scripts/fix-product-data.sql)
- [部署文档](../docs/DEPLOYMENT.md)
- [故障排查指南](../docs/TROUBLESHOOTING.md)

---

**最后更新**: 2025-12-19
**维护者**: 罗耀生
