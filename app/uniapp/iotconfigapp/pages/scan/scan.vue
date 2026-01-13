<!-- 扫码配网页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="scan-container">
    <!-- 状态栏占位 -->
    <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>

    <view class="header">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">添加设备</text>
    </view>

    <view class="content">
      <view v-if="scanning" class="scan-area">
        <view class="scan-icon">
          <text class="scan-symbol">🔍</text>
        </view>
        <text class="scan-text">正在扫描附近的设备...</text>
      </view>

      <view v-else class="device-list">
        <text class="list-title">发现以下设备</text>
        <view class="device-item" @tap="selectDevice('IoT-Switch-A1B2', 'servo')">
          <view class="device-icon">
            <text class="icon-symbol">🔘</text>
          </view>
          <view class="device-info">
            <text class="device-name">IoT-Switch-A1B2</text>
            <text class="device-type">舵机开关</text>
          </view>
          <view class="device-signal">
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot">●</text>
          </view>
        </view>

        <view class="device-item" @tap="selectDevice('IoT-Wakeup-C3D4', 'wakeup')">
          <view class="device-icon">
            <text class="icon-symbol">🔌</text>
          </view>
          <view class="device-info">
            <text class="device-name">IoT-Wakeup-C3D4</text>
            <text class="device-type">USB唤醒设备</text>
          </view>
          <view class="device-signal">
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
            <text class="signal-dot active">●</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'Scan',
  data() {
    return {
      statusBarHeight: 0,
      scanning: true
    };
  },
  onReady() {
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
    this.startScan();
  },
  methods: {
    startScan() {
      this.scanning = true;
      setTimeout(() => {
        this.scanning = false;
      }, 2000);
    },

    selectDevice(deviceId, type) {
      uni.navigateTo({
        url: `/pages/config/config?deviceId=${deviceId}&type=${type}`
      });
    },

    goBack() {
      uni.navigateBack();
    }
  }
};
</script>

<style scoped>
.scan-container {
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

.scan-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;
}

.scan-icon {
  width: 128rpx;
  height: 128rpx;
  background: #F5F5F7;
  border-radius: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.scan-symbol {
  font-size: 64rpx;
}

.scan-text {
  font-size: 28rpx;
  color: #8E8E93;
}

.list-title {
  font-size: 32rpx;
  font-weight: 500;
  color: #3A3A3C;
  margin-bottom: 24rpx;
}

.device-list {
  margin-top: 32rpx;
}

.device-item {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #F5F5F7;
  border-radius: 24rpx;
  margin-bottom: 16rpx;
}

.device-icon {
  width: 80rpx;
  height: 80rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
}

.icon-symbol {
  font-size: 40rpx;
}

.device-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.device-name {
  font-size: 32rpx;
  color: #3A3A3C;
  margin-bottom: 8rpx;
}

.device-type {
  font-size: 28rpx;
  color: #8E8E93;
}

.device-signal {
  display: flex;
  gap: 4rpx;
}

.signal-dot {
  font-size: 16rpx;
  color: #E5E5EA;
}

.signal-dot.active {
  color: #34C759;
}
</style>
