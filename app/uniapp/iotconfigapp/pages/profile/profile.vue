<!-- 个人中心页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="profile">
    <!-- 头部 -->
    <view class="header">
      <view class="avatar">
        <text class="avatar-text">U</text>
      </view>
      <text class="user-name">用户</text>
      <text class="user-email">user@example.com</text>
    </view>

    <!-- 统计 -->
    <view class="stats">
      <view class="stat-item">
        <text class="stat-value">{{ deviceCount }}</text>
        <text class="stat-label">设备总数</text>
      </view>
      <view class="stat-item">
        <text class="stat-value online">{{ onlineCount }}</text>
        <text class="stat-label">在线设备</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">1.0</text>
        <text class="stat-label">版本</text>
      </view>
    </view>

    <!-- 菜单列表 -->
    <view class="menu-section">
      <view class="menu-item" @click="goDeviceList">
        <text class="menu-icon">📱</text>
        <text class="menu-label">设备管理</text>
        <text class="menu-value">{{ deviceCount }} 台</text>
        <text class="menu-arrow">›</text>
      </view>
    </view>

    <view class="menu-section">
      <view class="menu-item" @click="goSettings">
        <text class="menu-icon">⚙️</text>
        <text class="menu-label">设置</text>
        <text class="menu-arrow">›</text>
      </view>
      <view class="menu-item" @click="goAbout">
        <text class="menu-icon">ℹ️</text>
        <text class="menu-label">关于</text>
        <text class="menu-value">v1.0.0</text>
        <text class="menu-arrow">›</text>
      </view>
    </view>

    <!-- 退出登录 -->
    <view class="logout-section">
      <button class="btn-logout" @click="handleLogout">退出登录</button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      deviceCount: 0,
      onlineCount: 0
    }
  },
  onShow() {
    this.loadStats()
  },
  methods: {
    loadStats() {
      const devices = uni.getStorageSync('devices') || []
      this.deviceCount = devices.length
      this.onlineCount = devices.filter(d => d.status === 'online').length
    },
    goDeviceList() {
      uni.switchTab({ url: '/pages/device-list/device-list' })
    },
    goSettings() {
      uni.navigateTo({ url: '/pages/settings/settings' })
    },
    goAbout() {
      uni.navigateTo({ url: '/pages/about/about' })
    },
    handleLogout() {
      uni.showModal({
        title: '确认退出',
        content: '确定要退出登录吗？',
        success: (res) => {
          if (res.confirm) {
            uni.removeStorageSync('token')
            uni.reLaunch({ url: '/pages/login/login' })
          }
        }
      })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.profile {
  min-height: 100vh;
  background: $color-bg;
}

.header {
  background: linear-gradient(180deg, $color-primary 0%, #5856D6 100%);
  padding: 80rpx $spacing-xl $spacing-xl;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.avatar {
  width: 140rpx;
  height: 140rpx;
  background: rgba(255,255,255,0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-md;
}

.avatar-text {
  font-size: 56rpx;
  font-weight: 600;
  color: #FFF;
}

.user-name {
  font-size: $font-xl;
  font-weight: 600;
  color: #FFF;
  margin-bottom: $spacing-xs;
}

.user-email {
  font-size: $font-sm;
  color: rgba(255,255,255,0.7);
}

.stats {
  display: flex;
  margin: -40rpx $spacing-lg $spacing-lg;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg 0;
  box-shadow: $shadow-md;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-value {
  font-size: 40rpx;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-xs;
  &.online { color: $color-success; }
}

.stat-label {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.menu-section {
  background: $color-card;
  border-radius: $radius-lg;
  margin: 0 $spacing-lg $spacing-md;
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1rpx solid $color-border;
  &:last-child { border-bottom: none; }
}

.menu-icon {
  font-size: 40rpx;
  margin-right: $spacing-md;
}

.menu-label {
  flex: 1;
  font-size: $font-md;
  color: $color-text;
}

.menu-value {
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-right: $spacing-sm;
}

.menu-arrow {
  font-size: 32rpx;
  color: $color-placeholder;
}

.logout-section {
  padding: $spacing-xl $spacing-lg;
}

.btn-logout {
  width: 100%;
  height: $height-button;
  background: $color-error;
  color: #FFF;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}
</style>
