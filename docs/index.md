---
layout: home
hero:
  name: Open IoT Platform
  text: 一体化 IoT 平台
  tagline: 设备接入 → BLE 配网 → MQTT 通信 → 服务端管理 → App 控制，完整闭环
  actions:
    - theme: brand
      text: 使用教程
      link: /TUTORIAL
    - theme: alt
      text: Docker 一键部署
      link: /QUICK_START_DOCKER
    - theme: alt
      text: GitHub
      link: https://github.com/LuoYaoSheng/open-iot-platform

features:
  - icon: 📡
    title: 设备接入
    details: ESP32 / ESP32-S3 固件支持，BLE 蓝牙配网，设备自动注册与激活
  - icon: 🔗
    title: BLE 配网
    details: 移动端 APP 通过 BLE 扫描、连接设备，一键完成 WiFi 配网与平台绑定
  - icon: 📨
    title: MQTT 通信
    details: 内置 MQTT Broker (mochi-mqtt)，设备认证、消息路由、实时状态推送，无需外部依赖
  - icon: 🖥️
    title: 服务端管理
    details: Go + Gin 构建，设备生命周期管理、物模型定义、Redis 在线状态缓存
  - icon: 📱
    title: 移动端控制
    details: Flutter 跨平台 APP，设备列表、远程控制、USB 唤醒专用面板
  - icon: 🐳
    title: Docker 部署
    details: 一条命令启动全套服务，零配置体验完整 IoT 链路
---

<div class="quick-start-section">
  <div class="section-title">⚡ 5 分钟快速体验</div>
  <div class="steps-container">
    <div class="step-card">
      <div class="step-number">1</div>
      <div class="step-title">克隆并启动</div>
      <div class="step-desc">git clone → docker compose up -d</div>
    </div>
    <div class="step-card">
      <div class="step-number">2</div>
      <div class="step-title">烧写固件</div>
      <div class="step-desc">PlatformIO 编译烧写到 ESP32</div>
    </div>
    <div class="step-card">
      <div class="step-number">3</div>
      <div class="step-title">BLE 配网</div>
      <div class="step-desc">打开 APP → 扫描 → 配网 → 控制</div>
    </div>
  </div>
  <a class="quick-start-btn" href="/TUTORIAL.html">查看完整使用教程 →</a>
</div>

<div class="project-highlights">
  <div class="highlight-item">
    <span class="highlight-value">2</span>
    <span class="highlight-label">硬件平台 (ESP32 / ESP32-S3)</span>
  </div>
  <div class="highlight-item">
    <span class="highlight-value">6+</span>
    <span class="highlight-label">REST API 模块</span>
  </div>
  <div class="highlight-item">
    <span class="highlight-value">1</span>
    <span class="highlight-label">命令启动全套服务</span>
  </div>
  <div class="highlight-item">
    <span class="highlight-value">3</span>
    <span class="highlight-label">端到端闭环 (固件/服务端/APP)</span>
  </div>
</div>

<style>
.quick-start-section {
  max-width: 800px;
  margin: 64px auto 32px;
  text-align: center;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 24px;
}

.steps-container {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.step-card {
  flex: 1;
  min-width: 180px;
  max-width: 240px;
  padding: 24px 16px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  text-align: center;
  transition: border-color 0.3s;
}

.step-card:hover {
  border-color: var(--vp-c-brand);
}

.step-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--vp-c-brand);
  color: #fff;
  font-weight: 700;
  font-size: 1.1rem;
  margin-bottom: 12px;
}

.step-title {
  font-weight: 600;
  font-size: 1rem;
  margin-bottom: 8px;
}

.step-desc {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.quick-start-btn {
  display: inline-block;
  margin-top: 24px;
  padding: 10px 24px;
  border: 1px solid var(--vp-c-brand);
  border-radius: 8px;
  color: var(--vp-c-brand);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
}

.quick-start-btn:hover {
  background: var(--vp-c-brand);
  color: #fff;
}

.project-highlights {
  max-width: 800px;
  margin: 32px auto 64px;
  display: flex;
  gap: 24px;
  justify-content: center;
  flex-wrap: wrap;
}

.highlight-item {
  text-align: center;
  padding: 16px;
  min-width: 140px;
}

.highlight-value {
  display: block;
  font-size: 2rem;
  font-weight: 800;
  color: var(--vp-c-brand);
  line-height: 1.2;
}

.highlight-label {
  display: block;
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  margin-top: 4px;
}
</style>
