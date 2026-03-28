# EMQX 完整配置指南

> 部署后必须完成的 EMQX 配置，确保系统安全运行

---

## 📋 配置清单

EMQX 需要配置以下 3 项：

1. ✅ **HTTP 认证**（Authentication）- 已自动配置
2. ⚠️ **HTTP 授权/ACL**（Authorization）- 需要手动配置
3. ⚠️ **Webhook**（设备上下线）- 需要手动配置

---

## 1️⃣ HTTP 认证（已自动配置）

### 说明
通过 docker-compose.yml 环境变量已自动配置，设备连接时会验证：
- `username`（格式：`productKey&deviceId`）
- `password`（设备密钥）
- `clientid`（ESP32 设备ID）

### 验证方式
后端 API: `POST http://iot_core:48080/api/v1/mqtt/auth`

✅ **无需手动配置**

---

## 2️⃣ HTTP 授权/ACL（重要！）

### 说明
控制设备只能发布/订阅自己的主题，防止设备越权访问其他设备的数据。

### 配置步骤

#### A. 登录 EMQX Dashboard

访问：`http://你的IP:48884`
- 账号: `admin`
- 密码: `public`

#### B. 配置 HTTP 授权

1. 左边菜单点击：**访问控制** → **客户端授权**
2. 点击右上角：**+ 创建**
3. 在弹出的对话框中：
   - 选择类型：**HTTP Server**

4. 填写配置：

   **基本信息**：
   ```
   名称 (Name): http_acl
   启用 (Enable): ✅ 勾选
   ```

   **HTTP 配置**：
   ```
   URL: http://iot_core:48080/api/v1/mqtt/acl
   方法 (Method): POST

   请求头 (Headers):
   Content-Type: application/json

   请求体模板 (Body):
   {
     "username": "${username}",
     "topic": "${topic}",
     "action": "${action}"
   }
   ```

   **默认动作**（如果配置中有此选项）：
   ```
   默认拒绝 / Deny if no match
   ```

5. 点击 **创建** 保存

#### C. 验证配置

在 **访问控制** → **客户端授权** 页面，应该看到：
- ✅ `http_acl` - 已启用

---

## 3️⃣ Webhook（设备上下线）

### 说明
实时监听设备上下线事件，同步设备状态到数据库。

### 配置步骤

#### A. 配置设备上线 Webhook

1. 左边菜单点击：**集成** → **Webhook**
2. 点击右上角：**+ 创建**
3. 填写配置：

   **基本信息**：
   ```
   名称 (Name): device_online
   启用 (Enable): ✅ 勾选
   ```

   **触发事件**：
   ```
   事件 (Event): 客户端连接 / client.connected
   ```

   **动作配置**：
   ```
   URL: http://iot_core:48080/api/v1/webhook/client
   方法 (Method): POST
   ```

4. 点击 **创建** 保存

#### B. 配置设备下线 Webhook

1. 再次点击右上角：**+ 创建**
2. 填写配置：

   **基本信息**：
   ```
   名称 (Name): device_offline
   启用 (Enable): ✅ 勾选
   ```

   **触发事件**：
   ```
   事件 (Event): 客户端断开 / client.disconnected
   ```

   **动作配置**：
   ```
   URL: http://iot_core:48080/api/v1/webhook/client
   方法 (Method): POST
   ```

3. 点击 **创建** 保存

#### C. 验证配置

在 **集成** → **Webhook** 页面，应该看到：
- ✅ `device_online` - 已启用
- ✅ `device_offline` - 已启用

---

## 🔍 测试验证

### 1. 测试认证（Authentication）

使用 MQTT 客户端连接：

```bash
# 正确的设备凭证
mosquitto_pub -h 你的IP -p 48883 \
  -u "switch-001&device_xxx" \
  -P "设备密钥" \
  -t "/sys/switch-001/device_xxx/status" \
  -m "test"

# 应该成功连接 ✅
```

```bash
# 错误的密码
mosquitto_pub -h 你的IP -p 48883 \
  -u "switch-001&device_xxx" \
  -P "wrong_password" \
  -t "/sys/switch-001/device_xxx/status" \
  -m "test"

# 应该拒绝连接 ❌
```

---

### 2. 测试授权（ACL）

```bash
# 设备发布到自己的主题
mosquitto_pub -h 你的IP -p 48883 \
  -u "switch-001&device_001" \
  -P "设备密钥" \
  -t "/sys/switch-001/device_001/status" \
  -m "test"

# 应该允许 ✅
```

```bash
# 设备尝试发布到其他设备的主题
mosquitto_pub -h 你的IP -p 48883 \
  -u "switch-001&device_001" \
  -P "设备密钥" \
  -t "/sys/switch-001/device_002/status" \
  -m "test"

# 应该拒绝 ❌
```

---

### 3. 测试 Webhook

1. 启动 ESP32 设备
2. 查看后端日志：
   ```bash
   docker logs -f iot_core
   ```
3. 应该看到：
   ```
   [Webhook] 客户端事件: client.connected
   [Webhook] 设备上线: device_xxx
   ```

4. 断开设备电源
5. 应该看到：
   ```
   [Webhook] 客户端事件: client.disconnected
   [Webhook] 设备下线: device_xxx
   ```

---

## 🛡️ 安全说明

### ACL 规则

后端实现的 ACL 规则：
- 设备只能发布/订阅以下主题：
  ```
  /sys/{productKey}/{deviceId}/*
  ```
- 示例：设备 `device_001`（产品 `switch-001`）只能访问：
  ```
  /sys/switch-001/device_001/status
  /sys/switch-001/device_001/control
  /sys/switch-001/device_001/data
  ```

### 开发模式 vs 生产模式

**开发模式**（当前配置）：
```yaml
EMQX_AUTHORIZATION__NO_MATCH: allow
```
- 如果 ACL 规则不匹配，**允许**访问
- 适合开发调试

**生产模式**（推荐）：
```yaml
EMQX_AUTHORIZATION__NO_MATCH: deny
```
- 如果 ACL 规则不匹配，**拒绝**访问
- 更安全，但需要确保所有 ACL 规则配置正确

---

## 📊 配置完成检查清单

- [ ] HTTP 认证已配置（自动完成）
- [ ] HTTP 授权/ACL 已配置（手动完成）
- [ ] 设备上线 Webhook 已配置
- [ ] 设备下线 Webhook 已配置
- [ ] 已测试设备认证（正确密码 ✅ / 错误密码 ❌）
- [ ] 已测试 ACL（自己主题 ✅ / 其他主题 ❌）
- [ ] 已测试 Webhook（设备上下线日志正常）
- [ ] EMQX Dashboard 密码已修改（生产环境）

---

## ❓ 常见问题

### 1. ACL 配置后设备无法发布消息？

**检查主题格式**：
- ✅ 正确：`/sys/switch-001/device_001/status`
- ❌ 错误：`device_001/status`（缺少产品前缀）

### 2. Webhook 没有触发？

**检查后端日志**：
```bash
docker logs -f iot_core
```

**检查 EMQX 统计**：
- 进入 Dashboard
- 点击 Webhook 名称
- 查看 Success / Failed 计数

### 3. 如何查看 ACL 拒绝日志？

```bash
# 查看 EMQX 日志
docker logs -f iot_emqx

# 应该看到类似日志
# [ACL] Client device_001 not allowed to publish to topic /sys/switch-001/device_002/status
```

---

## 🔗 相关文档

- [部署指南](./部署指南.md) - 一键部署
- [安全配置](./安全配置.md) - 生产环境安全加固
- [故障排查](./TROUBLESHOOTING.md) - 常见问题解决

---

**作者**: 罗耀生
**创建时间**: 2025-12-18
