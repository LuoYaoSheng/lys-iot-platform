<!-- 设置页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="settings">
    <!-- 用户信息 -->
    <view class="user-card">
      <view class="avatar">
        <text class="avatar-text">U</text>
      </view>
      <view class="user-info">
        <text class="user-name">用户</text>
        <text class="user-email">user@example.com</text>
      </view>
    </view>

    <!-- 服务器配置 -->
    <text class="group-title">服务器配置</text>
    <view class="menu-section">
      <view class="menu-item" @click="showServerModal = true">
        <text class="menu-label">API 服务器</text>
        <text class="menu-value">{{ serverUrl }}</text>
        <text class="menu-arrow">›</text>
      </view>
    </view>

    <!-- 其他 -->
    <text class="group-title">其他</text>
    <view class="menu-section">
      <view class="menu-item" @click="goAbout">
        <text class="menu-label">关于</text>
        <text class="menu-value">v1.0.0</text>
        <text class="menu-arrow">›</text>
      </view>
    </view>

    <!-- 退出登录 -->
    <view class="logout-section">
      <button class="btn-logout" @click="handleLogout">退出登录</button>
    </view>

    <!-- 服务器设置弹窗 -->
    <view class="modal" v-if="showServerModal" @click="showServerModal = false">
      <view class="modal-content" @click.stop>
        <text class="modal-title">服务器配置</text>
        <view class="input-group">
          <text class="label">API 服务器地址</text>
          <input class="input" v-model="serverUrl" placeholder="http://192.168.1.100:48080" />
        </view>
        <button class="btn-save" @click="saveServer">保存配置</button>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      showServerModal: false,
      serverUrl: 'http://192.168.1.100:48080'
    }
  },
  onLoad() {
    const saved = uni.getStorageSync('serverUrl')
    if (saved) this.serverUrl = saved
  },
  methods: {
    saveServer() {
      uni.setStorageSync('serverUrl', this.serverUrl)
      this.showServerModal = false
      uni.showToast({ title: '已保存', icon: 'success' })
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

.settings {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-lg;
  box-sizing: border-box;
}

.user-card {
  display: flex;
  align-items: center;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-lg;
}

.avatar {
  width: 96rpx;
  height: 96rpx;
  background: $color-primary;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: $spacing-md;
}

.avatar-text {
  font-size: 36rpx;
  font-weight: 600;
  color: #FFF;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: $font-md;
  color: $color-text;
  margin-bottom: $spacing-xs;
}

.user-email {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.group-title {
  display: block;
  font-size: $font-xs;
  color: $color-text-secondary;
  margin: $spacing-md 0 $spacing-sm $spacing-sm;
}

.menu-section {
  background: $color-card;
  border-radius: $radius-lg;
  overflow: hidden;
  margin-bottom: $spacing-md;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1rpx solid $color-border;
  &:last-child { border-bottom: none; }
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
  max-width: 400rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-arrow {
  font-size: 32rpx;
  color: $color-placeholder;
}

.logout-section {
  margin-top: $spacing-xl;
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

.modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: flex-end;
  z-index: 999;
}

.modal-content {
  width: 100%;
  background: $color-card;
  border-radius: $radius-lg $radius-lg 0 0;
  padding: $spacing-xl;
  padding-bottom: calc(#{$spacing-xl} + env(safe-area-inset-bottom));
}

.modal-title {
  display: block;
  font-size: $font-lg;
  font-weight: 600;
  color: $color-text;
  text-align: center;
  margin-bottom: $spacing-xl;
}

.input-group {
  margin-bottom: $spacing-xl;
}

.label {
  display: block;
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-sm;
}

.input {
  width: 100%;
  height: $height-input;
  background: $color-bg;
  border-radius: $radius-md;
  padding: 0 $spacing-lg;
  font-size: $font-md;
  box-sizing: border-box;
}

.btn-save {
  width: 100%;
  height: $height-button;
  background: $color-primary;
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
