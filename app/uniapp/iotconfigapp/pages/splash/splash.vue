<!-- 启动页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="splash">
    <view class="content">
      <view class="logo">
        <AppIcon name="bolt" :size="64" color="#FFFFFF" />
      </view>
      <text class="title">Open IoT</text>
      <text class="subtitle">智能设备配置工具</text>
    </view>
    <view class="loading">
      <view class="spinner"></view>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  onLoad() {
    setTimeout(() => {
      const token = uni.getStorageSync('token')
      if (token) {
        uni.switchTab({ url: '/pages/device-list/device-list' })
      } else {
        uni.redirectTo({ url: '/pages/login/login' })
      }
    }, 1500)
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.splash {
  min-height: 100vh;
  background: $color-card;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo {
  width: 160rpx;
  height: 160rpx;
  background: $color-primary;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-xl;
}

.logo-icon {
  font-size: 80rpx;
  color: #FFFFFF;
}

.title {
  font-size: $font-3xl;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-sm;
}

.subtitle {
  font-size: $font-md;
  color: $color-text-secondary;
}

.loading {
  position: fixed;
  bottom: 160rpx;
}

.spinner {
  width: 48rpx;
  height: 48rpx;
  border: 4rpx solid $color-border;
  border-top-color: $color-primary;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
