# Open IoT Platform Start Here

> 给第一次想从 `Open IoT Platform` 学完整 IoT 链路的人。

---

## 这套项目适合谁

适合下面这类人：

- 已经会一点 BLE 或 App 开发，想继续看完整链路
- 想把设备、配网、MQTT、服务端和移动端串起来
- 想看一个真实 IoT 项目怎么拆模块

如果你还没有 BLE 基础，建议先看：

- `Smart BLE`

---

## 推荐阅读顺序

### 1. 先看根 README

先理解这套项目到底包含哪些部分：

- 服务端
- 移动端
- 固件
- 公共库
- SmartLink 包装层

### 2. 再看仓库结构文档

建议下一步看：

- [REPOSITORY_ARCHITECTURE.md](./REPOSITORY_ARCHITECTURE.md)

### 3. 再看本地联调 Runbook

如果你要真的跑起来，请继续看：

- [LOCAL_EMULATOR_RUNBOOK.md](./LOCAL_EMULATOR_RUNBOOK.md)
- [CONFIGURATION_CHAIN.md](./CONFIGURATION_CHAIN.md)

### 4. 最后按模块进入

- 服务端：[`../server/`](../server/)
- 移动端：[`../mobile-app/`](../mobile-app/)
- 固件：[`../firmware/`](../firmware/)
- 公共库：[`../iot-libs-common/`](../iot-libs-common/)

---

## 你应该先关注什么

### 我想看完整链路

先看：

- 根 README
- 架构文档
- 本地联调 Runbook

### 我想先跑服务端

先看：

- `server/README.md`

### 我想先看移动端配网

先看：

- `mobile-app/README.md`

### 我想先看设备和固件

先看：

- `firmware/switch/README.md`
- `firmware/usb-wakeup/README.md`

---

## 下一步

- [REPOSITORY_ARCHITECTURE.md](./REPOSITORY_ARCHITECTURE.md)
- [LOCAL_EMULATOR_RUNBOOK.md](./LOCAL_EMULATOR_RUNBOOK.md)
- [CONFIGURATION_CHAIN.md](./CONFIGURATION_CHAIN.md)
