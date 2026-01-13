<!-- WiFi配置页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="config-container">
    <!-- 状态栏占位 -->
    <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>

    <view class="header">
      <view class="back-btn" v-if="configState === 'form'" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">{{ pageTitle }}</text>
    </view>

    <!-- 表单页面 -->
    <scroll-view class="content" scroll-y v-if="configState === 'form'">
      <!-- 设备信息卡片 -->
      <view class="device-info-card" v-if="deviceInfo.deviceId">
        <view class="device-icon-small">
          <text class="icon-symbol">{{ deviceInfo.type === 'servo' ? '🔘' : '🔌' }}</text>
        </view>
        <view class="device-info-content">
          <text class="info-label">扫描到设备</text>
          <text class="info-value">{{ deviceInfo.deviceId }}</text>
          <text class="info-type">{{ deviceInfo.type === 'servo' ? '舵机开关' : 'USB唤醒设备' }}</text>
        </view>
      </view>

      <!-- 设备名称 -->
      <view class="form-group">
        <text class="form-label">设备名称</text>
        <input class="form-input" v-model="deviceName" placeholder="请输入设备名称，如：客厅开关" />
      </view>

      <!-- WiFi 配置 -->
      <view class="form-group">
        <text class="form-label">WiFi 配置</text>
        <view class="wifi-selector" @tap="showWifiPicker">
          <view class="wifi-icon">📶</view>
          <view class="wifi-info">
            <text class="wifi-label">WiFi 网络</text>
            <text class="wifi-name">{{ wifiName }}</text>
          </view>
          <text class="wifi-arrow">›</text>
        </view>
        <input class="form-input" type="password" v-model="wifiPassword" placeholder="请输入WiFi密码" />
      </view>

      <!-- 开始配置按钮 -->
      <view class="action-section">
        <button class="btn-primary" @tap="startConfig">
          开始配置
        </button>
      </view>
    </scroll-view>

    <!-- 配网进度页面 -->
    <view class="progress-container" v-if="configState === 'configuring'">
      <view class="progress-content">
        <!-- 步骤指示器 -->
        <view class="steps">
          <view class="step" v-for="(step, index) in steps" :key="index" :class="getStepClass(index)">
            <view class="step-dot">
              <text v-if="index < currentStep" class="check-icon">✓</text>
              <view v-if="index === currentStep" class="loading-dot"></view>
            </view>
            <view class="step-line" v-if="index < steps.length - 1"></view>
            <text class="step-label">{{ step.label }}</text>
          </view>
        </view>

        <view class="progress-message">
          <text class="message-text">{{ progressMessage }}</text>
        </view>

        <view class="progress-spinner">
          <view class="spinner"></view>
        </view>
      </view>
    </view>

    <!-- 配置成功页面 -->
    <view class="success-container" v-if="configState === 'success'">
      <view class="success-content">
        <view class="success-icon">
          <text>✓</text>
        </view>
        <text class="success-title">配置成功！</text>
        <text class="success-desc">「{{ deviceName }}」已添加到设备列表</text>
        <button class="btn-primary" @tap="finishConfig">完成</button>
      </view>
    </view>

    <!-- 配置失败页面 -->
    <view class="error-container" v-if="configState === 'error'">
      <view class="error-content">
        <view class="error-icon">
          <text>✕</text>
        </view>
        <text class="error-title">配置失败</text>
        <text class="error-desc">{{ errorMessage }}</text>
        <view class="error-actions">
          <button class="btn-outline" @tap="retryConfig">重新配置</button>
          <button class="btn-primary" @tap="goBack">取消</button>
        </view>
      </view>
    </view>

    <!-- WiFi 选择弹窗 -->
    <view class="modal-overlay" v-if="showWifiModal" @tap="showWifiModal = false">
      <view class="modal-content" @tap.stop>
        <text class="modal-title">选择 WiFi 网络</text>
        <view class="wifi-list">
          <view class="wifi-option" v-for="wifi in wifiList" :key="wifi.ssid" @tap="selectWiFi(wifi)">
            <text class="wifi-ssid">{{ wifi.ssid }}</text>
            <view class="wifi-signal">
              <text class="signal-dot" :class="{ active: wifi.signal >= 4 }"></text>
              <text class="signal-dot" :class="{ active: wifi.signal >= 3 }"></text>
              <text class="signal-dot" :class="{ active: wifi.signal >= 2 }"></text>
              <text class="signal-dot" :class="{ active: wifi.signal >= 1 }"></text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { MockData, DeviceType, DeviceStatus } from '@/utils/mock-data.js';

export default {
  name: 'Config',
  data() {
    return {
      statusBarHeight: 0,
      // 设备信息
      deviceInfo: {
        deviceId: '',
        type: ''
      },
      deviceName: '',
      wifiName: 'MyHome_5G',
      wifiPassword: '',
      // 配网状态
      configState: 'form', // 'form' | 'configuring' | 'success' | 'error'
      currentStep: 0,
      progressMessage: '',
      errorMessage: '',
      // WiFi选择
      showWifiModal: false,
      wifiList: [
        { ssid: 'MyHome_5G', signal: 4 },
        { ssid: 'MyHome_2.4G', signal: 3 },
        { ssid: 'Office_WiFi', signal: 2 }
      ],
      steps: [
        { label: '连接设备' },
        { label: '发送配置' },
        { label: 'WiFi连接' },
        { label: '激活设备' }
      ]
    };
  },
  computed: {
    pageTitle() {
      const titles = {
        'form': '配置设备',
        'configuring': '配置中',
        'success': '配置成功',
        'error': '配置失败'
      };
      return titles[this.configState] || '配置设备';
    }
  },
  onReady() {
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
  },
  onLoad(options) {
    if (options.deviceId) {
      this.deviceInfo.deviceId = options.deviceId;
      this.deviceName = options.deviceId;
    }
    if (options.type) {
      this.deviceInfo.type = options.type;
    }
  },
  methods: {
    getStepClass(index) {
      if (index < this.currentStep) return 'completed';
      if (index === this.currentStep) return 'active';
      return '';
    },

    showWifiPicker() {
      this.showWifiModal = true;
    },

    selectWiFi(wifi) {
      this.wifiName = wifi.ssid;
      this.showWifiModal = false;
    },

    startConfig() {
      if (!this.deviceName.trim()) {
        uni.showToast({
          title: '请输入设备名称',
          icon: 'none'
        });
        return;
      }

      if (!this.wifiPassword) {
        uni.showToast({
          title: '请输入WiFi密码',
          icon: 'none'
        });
        return;
      }

      this.configState = 'configuring';
      this.runConfigProcess();
    },

    async runConfigProcess() {
      const configSteps = [
        { step: 0, message: '正在连接设备...' },
        { step: 1, message: '正在发送配置...' },
        { step: 2, message: '等待设备连接 WiFi...' },
        { step: 3, message: '正在激活设备...' }
      ];

      for (const config of configSteps) {
        await this.delay(800);
        this.currentStep = config.step;
        this.progressMessage = config.message;
      }

      await this.delay(500);

      // 添加设备到列表
      const newDevice = {
        id: 'device_' + Date.now(),
        name: this.deviceName,
        type: this.deviceInfo.type || 'servo',
        status: 'online',
        firmware: '1.0.0'
      };
      MockData.addDevice(newDevice);

      this.configState = 'success';
    },

    delay(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    },

    retryConfig() {
      this.configState = 'form';
      this.currentStep = 0;
    },

    finishConfig() {
      uni.navigateBack();
      uni.navigateBack();
    },

    goBack() {
      uni.navigateBack();
    }
  }
};
</script>

<style scoped>
.config-container {
  min-height: 100vh;
  background: #FFFFFF;
}

.status-bar {
  width: 100%;
  background: #FFFFFF;
}

.header {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #FFFFFF;
  border-bottom: 1rpx solid #E5E5EA;
}

.back-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  font-size: 64rpx;
  color: #3A3A3C;
  font-weight: 300;
}

.title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.content {
  padding: 32rpx;
}

/* 设备信息卡片 */
.device-info-card {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #F5F5F7;
  border-radius: 24rpx;
  margin-bottom: 32rpx;
}

.device-icon-small {
  width: 80rpx;
  height: 80rpx;
  background: #E5E5EA;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
}

.icon-symbol {
  font-size: 40rpx;
}

.device-info-content {
  flex: 1;
}

.info-label {
  font-size: 24rpx;
  color: #8E8E93;
  margin-bottom: 4rpx;
}

.info-value {
  font-size: 32rpx;
  color: #3A3A3C;
  font-weight: 500;
}

.info-type {
  font-size: 28rpx;
  color: #007AFF;
}

/* 表单 */
.form-group {
  margin-bottom: 32rpx;
}

.form-label {
  font-size: 32rpx;
  font-weight: 500;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.form-input {
  width: 100%;
  height: 96rpx;
  padding: 0 32rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  font-size: 32rpx;
}

.wifi-selector {
  display: flex;
  align-items: center;
  height: 96rpx;
  padding: 0 32rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  margin-bottom: 16rpx;
}

.wifi-icon {
  font-size: 40rpx;
  margin-right: 16rpx;
}

.wifi-info {
  flex: 1;
}

.wifi-label {
  font-size: 24rpx;
  color: #8E8E93;
}

.wifi-name {
  font-size: 32rpx;
  color: #3A3A3C;
}

.wifi-arrow {
  font-size: 40rpx;
  color: #C7C7CC;
}

.action-section {
  margin-top: 32rpx;
}

.btn-primary {
  width: 100%;
  height: 96rpx;
  background: #007AFF;
  color: #FFFFFF;
  border-radius: 16rpx;
  font-size: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-outline {
  flex: 1;
  height: 88rpx;
  background: transparent;
  border: 2rpx solid #E5E5EA;
  color: #3A3A3C;
  border-radius: 16rpx;
  font-size: 32rpx;
  margin-right: 16rpx;
}

/* 进度页面 */
.progress-container {
  min-height: calc(100vh - var(--status-bar-height) - 100rpx);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64rpx 32rpx;
}

.progress-content {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.steps {
  display: flex;
  justify-content: space-between;
  width: 100%;
  margin-bottom: 64rpx;
}

.step {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.step-dot {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: #E5E5EA;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
}

.step.completed .step-dot {
  background: #34C759;
}

.step.active .step-dot {
  background: #007AFF;
}

.check-icon {
  font-size: 28rpx;
  color: #FFFFFF;
}

.loading-dot {
  width: 24rpx;
  height: 24rpx;
}

.loading-dot::after {
  content: '';
  width: 24rpx;
  height: 24rpx;
  border: 4rpx solid #FFFFFF;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.step-line {
  position: absolute;
  top: 24rpx;
  left: 50%;
  width: 100%;
  height: 2rpx;
  background: #E5E5EA;
  z-index: -1;
}

.step.completed + .step .step-line,
.step.active + .step .step-line {
  background: #34C759;
}

.step-label {
  font-size: 24rpx;
  color: #8E8E93;
}

.step.completed .step-label,
.step.active .step-label {
  color: #3A3A3C;
}

.progress-message {
  margin-bottom: 48rpx;
}

.message-text {
  font-size: 28rpx;
  color: #8E8E93;
}

.progress-spinner {
  width: 64rpx;
  height: 64rpx;
}

.spinner {
  width: 64rpx;
  height: 64rpx;
  border: 4rpx solid #E5E5EA;
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* 成功页面 */
.success-container {
  min-height: calc(100vh - var(--status-bar-height) - 100rpx);
  display: flex;
  align-items: center;
  justify-content: center;
}

.success-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64rpx 32rpx;
}

.success-icon {
  width: 128rpx;
  height: 128rpx;
  background: #34C759;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.success-icon text {
  font-size: 72rpx;
  color: #FFFFFF;
}

.success-title {
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.success-desc {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 48rpx;
}

/* 失败页面 */
.error-container {
  min-height: calc(100vh - var(--status-bar-height) - 100rpx);
  display: flex;
  align-items: center;
  justify-content: center;
}

.error-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64rpx 32rpx;
}

.error-icon {
  width: 128rpx;
  height: 128rpx;
  background: #FF3B30;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.error-icon text {
  font-size: 72rpx;
  color: #FFFFFF;
}

.error-title {
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.error-desc {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 48rpx;
}

.error-actions {
  display: flex;
  gap: 16rpx;
  width: 100%;
}

/* WiFi 弹窗 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  z-index: 1000;
}

.modal-content {
  width: 100%;
  background: #FFFFFF;
  border-radius: 32rpx 32rpx 0 0;
  padding: 32rpx;
}

.modal-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 24rpx;
}

.wifi-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.wifi-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
}

.wifi-ssid {
  font-size: 32rpx;
  color: #3A3A3C;
}

.wifi-signal {
  display: flex;
  gap: 4rpx;
}

.signal-dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  background: #E5E5EA;
}

.signal-dot.active {
  background: #34C759;
}
</style>
