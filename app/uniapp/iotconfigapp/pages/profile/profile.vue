<!-- 个人中心页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="profile">
    <!-- 头部 -->
    <view class="header">
      <view class="avatar">
        <text class="avatar-text">{{ displayName ? displayName[0].toUpperCase() : 'U' }}</text>
      </view>
      <text class="user-name">{{ displayName }}</text>
      <text class="user-email">{{ userEmail }}</text>
      <!-- 统计 - 在头部内部 -->
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
    </view>

    <!-- 菜单列表 -->
    <view class="menu-section">
      <view class="menu-item" @click="goDeviceList">
        <AppIcon name="device" :size="40" color="#8E8E93" />
        <text class="menu-label">设备管理</text>
        <text class="menu-value">{{ deviceCount }} 台</text>
        <text class="menu-arrow">›</text>
      </view>
    </view>

    <view class="menu-section">
      <view class="menu-item" @click="goSettings">
        <AppIcon name="settings" :size="40" color="#8E8E93" />
        <text class="menu-label">设置</text>
        <text class="menu-arrow">›</text>
      </view>
      <view class="menu-item" @click="goAbout">
        <AppIcon name="info" :size="40" color="#8E8E93" />
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
import AppIcon from '@/components/AppIcon.vue'
import auth from '@/utils/auth.js'
import deviceApi from '@/utils/device.js'

export default {
  components: { AppIcon },
  data() {
    return {
      deviceCount: 0,
      onlineCount: 0,
      displayName: '用户',
      userEmail: 'user@example.com'
    }
  },
  onShow() {
    this.loadUserInfo()
    this.loadStats()
  },
  methods: {
    loadUserInfo() {
      this.displayName = auth.getDisplayName()
      const user = auth.getUserInfo()
      if (user) {
        this.userEmail = user.email || 'user@example.com'
      }
    },
    async loadStats() {
      try {
        const result = await deviceApi.getDeviceList()
        if (result.success) {
          const devices = result.data.list
          this.deviceCount = result.data.total || devices.length
          this.onlineCount = devices.filter(d => d.status === 'online').length
        }
      } catch (e) {
        // 保持当前数据
      }
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
        success: async (res) => {
          if (res.confirm) {
            await auth.logout()
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
  padding: calc(var(--status-bar-height) + 44rpx + 40rpx) $spacing-xl 0;
  padding-bottom: 16rpx;
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
  margin-top: 40rpx;
  margin-bottom: 16rpx;
  padding: $spacing-lg 0;
  width: 100%;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24rpx 16rpx;
  margin: 0 4rpx;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 24rpx;
}

.stat-value {
  font-size: 40rpx;
  font-weight: 600;
  color: #FFF;
  margin-bottom: $spacing-xs;
  &.online { color: #34C759; }
}

.stat-label {
  font-size: $font-xs;
  color: rgba(255, 255, 255, 0.7);
}

.menu-section {
  background: $color-card;
  border-radius: $radius-lg;
  margin: 24rpx $spacing-lg $spacing-md;
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
