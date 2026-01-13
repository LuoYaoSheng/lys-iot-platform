<!-- 设置页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="settings-container">
    <!-- 状态栏占位 -->
    <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>

    <!-- 页面标题 -->
    <view class="header">
      <text class="title">我的</text>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- 用户信息卡片 -->
      <view class="user-card">
        <view class="user-avatar">
          <text class="avatar-icon">👤</text>
        </view>
        <view class="user-info">
          <text class="user-name">用户</text>
          <text class="user-email">user@example.com</text>
        </view>
      </view>

      <!-- 设置项列表 -->
      <view class="setting-section">
        <view class="setting-item" @click="showServerSettings">
          <view class="setting-item-left">
            <text class="setting-icon">🖥</text>
            <text class="setting-label">服务器设置</text>
          </view>
          <text class="setting-arrow">›</text>
        </view>

        <view class="setting-item" @click="goToAbout">
          <view class="setting-item-left">
            <text class="setting-icon">ℹ</text>
            <text class="setting-label">关于</text>
          </view>
          <text class="setting-arrow">›</text>
        </view>
      </view>

      <!-- 退出登录按钮 -->
      <view class="logout-section">
        <button class="btn-logout" @click="handleLogout">退出登录</button>
      </view>
    </scroll-view>

    <!-- 服务器设置弹窗 -->
    <view class="modal-overlay" v-if="showServerModal" @tap="closeServerSettings">
      <view class="modal-content" @tap.stop>
        <text class="modal-title">服务器设置</text>
        <view class="input-group">
          <text class="input-label">服务器地址</text>
          <input class="input" v-model="serverUrl" placeholder="https://iot.example.com" />
        </view>
        <view class="input-group">
          <text class="input-label">端口</text>
          <input class="input" v-model="serverPort" type="number" placeholder="443" />
        </view>
        <view class="modal-actions">
          <button class="modal-btn cancel" @tap="closeServerSettings">取消</button>
          <button class="modal-btn confirm" @tap="saveServerSettings">保存</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'Settings',
  data() {
    return {
      statusBarHeight: 0,
      showServerModal: false,
      serverUrl: 'https://iot.example.com',
      serverPort: '443'
    };
  },
  onReady() {
    // 获取状态栏高度
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
    // 加载已保存的服务器配置
    const savedUrl = uni.getStorageSync('serverUrl');
    const savedPort = uni.getStorageSync('serverPort');
    if (savedUrl) this.serverUrl = savedUrl;
    if (savedPort) this.serverPort = savedPort;
  },
  methods: {
    showServerSettings() {
      this.showServerModal = true;
    },

    closeServerSettings() {
      this.showServerModal = false;
    },

    saveServerSettings() {
      // 保存服务器配置
      uni.setStorageSync('serverUrl', this.serverUrl);
      uni.setStorageSync('serverPort', this.serverPort);
      this.closeServerSettings();
      uni.showToast({
        title: '服务器设置已保存',
        icon: 'success'
      });
    },

    goToAbout() {
      uni.navigateTo({
        url: '/pages/about/about'
      });
    },

    handleLogout() {
      uni.showModal({
        title: '确认退出',
        content: '确定要退出登录吗？',
        success: (res) => {
          if (res.confirm) {
            uni.removeStorageSync('token');
            uni.reLaunch({
              url: '/pages/login/login'
            });
          }
        }
      });
    }
  }
};
</script>

<style scoped>
.settings-container {
  min-height: 100vh;
  background: #F5F5F7;
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

.title {
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.content {
  height: calc(100vh - var(--status-bar-height) - 100rpx - 80rpx);
  padding: 16rpx;
}

.user-card {
  display: flex;
  align-items: center;
  padding: 32rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  margin-bottom: 16rpx;
}

.user-avatar {
  width: 80rpx;
  height: 80rpx;
  background: #E5E5EA;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
}

.avatar-icon {
  font-size: 40rpx;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 32rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 8rpx;
}

.user-email {
  font-size: 28rpx;
  color: #8E8E93;
}

.setting-section {
  background: #FFFFFF;
  border-radius: 24rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 32rpx;
  border-bottom: 1rpx solid #E5E5EA;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-item-left {
  display: flex;
  align-items: center;
}

.setting-icon {
  font-size: 40rpx;
  margin-right: 24rpx;
}

.setting-label {
  font-size: 32rpx;
  color: #3A3A3C;
}

.setting-arrow {
  font-size: 40rpx;
  color: #C7C7CC;
}

.logout-section {
  margin-top: 32rpx;
}

.btn-logout {
  width: 100%;
  height: 96rpx;
  background: #FF3B30;
  color: #FFFFFF;
  border-radius: 16rpx;
  font-size: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 服务器设置弹窗 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  width: 560rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  padding: 32rpx;
}

.modal-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 32rpx;
}

.input-group {
  margin-bottom: 24rpx;
}

.input-label {
  font-size: 28rpx;
  color: #3A3A3C;
  margin-bottom: 12rpx;
  display: block;
}

.input {
  width: 100%;
  height: 80rpx;
  padding: 0 24rpx;
  background: #F5F5F7;
  border-radius: 12rpx;
  font-size: 28rpx;
  box-sizing: border-box;
}

.modal-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 32rpx;
}

.modal-btn {
  flex: 1;
  height: 80rpx;
  border-radius: 12rpx;
  font-size: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-btn.cancel {
  background: #F5F5F7;
  color: #3A3A3C;
}

.modal-btn.confirm {
  background: #007AFF;
  color: #FFFFFF;
}
</style>
