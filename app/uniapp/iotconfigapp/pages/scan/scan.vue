<!-- 扫码添加设备页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="scan">
    <!-- 扫描状态 -->
    <view class="scanning">
      <view class="spinner"></view>
      <text class="scanning-text">正在扫描附近的设备...</text>
    </view>

    <!-- 设备列表 -->
    <view class="device-list">
      <view v-for="(device, index) in devices" :key="index" class="device-item" @click="connectDevice(device)">
        <AppIcon :name="device.icon" :size="48" color="#007AFF" />
        <view class="device-info">
          <text class="device-name">{{ device.name }}</text>
          <text class="device-type">{{ device.type }}</text>
        </view>
        <view class="signal">
          <view v-for="n in 5" :key="n" class="bar" :class="{ active: n <= device.signal }" :style="{ height: (n * 6 + 4) + 'rpx' }"></view>
        </view>
        <view class="connect-btn">连接</view>
      </view>
    </view>

    <view v-if="devices.length === 0" class="empty">
      <text class="empty-text">未发现设备，请确保设备已开启</text>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  data() {
    return {
      devices: [
        { name: 'IoT-Switch-A1B2', type: '舵机开关', icon: 'plug', signal: 4 },
        { name: 'IoT-Wakeup-C3D4', type: 'USB唤醒', icon: 'bolt', signal: 5 },
        { name: 'IoT-Switch-E5F6', type: '舵机开关', icon: 'plug', signal: 2 }
      ]
    }
  },
  methods: {
    connectDevice(device) {
      uni.navigateTo({ url: '/pages/config/config?name=' + device.name + '&type=' + device.type })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.scan {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-lg;
  box-sizing: border-box;
}

.scanning {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-xl 0;
  gap: $spacing-md;
}

.spinner {
  width: 40rpx;
  height: 40rpx;
  border: 4rpx solid $color-border;
  border-top-color: $color-primary;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.scanning-text {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.device-list {
  margin-top: $spacing-md;
}

.device-item {
  display: flex;
  align-items: center;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-md;
}

.device-icon {
  font-size: 48rpx;
  margin-right: $spacing-md;
}

.device-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.device-name {
  font-size: $font-md;
  font-weight: 500;
  color: $color-text;
  margin-bottom: $spacing-xs;
}

.device-type {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.signal {
  display: flex;
  align-items: flex-end;
  gap: 4rpx;
  margin-right: $spacing-md;
}

.bar {
  width: 8rpx;
  background: $color-border;
  border-radius: 4rpx;
  &.active { background: $color-success; }
}

.connect-btn {
  padding: $spacing-sm $spacing-md;
  background: $color-primary;
  color: #FFF;
  border-radius: $radius-sm;
  font-size: $font-xs;
}

.empty {
  text-align: center;
  padding: $spacing-2xl;
}

.empty-text {
  font-size: $font-sm;
  color: $color-text-secondary;
}
</style>
