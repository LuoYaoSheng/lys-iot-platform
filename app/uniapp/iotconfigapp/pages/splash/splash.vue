<!-- 启动页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="splash-container">
    <view class="logo">
      <view class="logo-icon">
        <text class="logo-icon-symbol">⚡</text>
      </view>
    </view>
    <text class="app-name">Open IoT</text>
    <text class="app-subtitle">Platform</text>
    <view class="loading">
      <view class="loading-spinner"></view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'Splash',
  data() {
    return {};
  },
  onLoad() {
    // 2秒后自动跳转
    setTimeout(() => {
      this.checkLoginStatus();
    }, 2000);
  },
  methods: {
    checkLoginStatus() {
      // TODO: 检查登录状态
      const token = uni.getStorageSync('token');

      if (token) {
        uni.redirectTo({
          url: '/pages/device-list/device-list'
        });
      } else {
        uni.redirectTo({
          url: '/pages/login/login'
        });
      }
    }
  }
};
</script>

<style scoped>
.splash-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background: #FFFFFF;
}

.logo {
  margin-bottom: 24rpx;
}

.logo-icon {
  width: 160rpx;
  height: 160rpx;
  background: #007AFF;
  border-radius: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-icon-symbol {
  font-size: 96rpx;
  color: #FFFFFF;
}

.app-name {
  font-size: 48rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.app-subtitle {
  font-size: 32rpx;
  color: #8E8E93;
  margin-bottom: 96rpx;
}

.loading {
  margin-top: 48rpx;
}

.loading-spinner {
  width: 48rpx;
  height: 48rpx;
  border: 4rpx solid #F0F0F0;
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
