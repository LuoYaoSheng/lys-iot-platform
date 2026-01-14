<!-- 登录页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="login-container">
    <!-- 服务器设置按钮 -->
    <view class="settings-btn" @tap="showServerSettings">
      <text class="settings-icon">⚙️</text>
      <text class="settings-text">配置</text>
    </view>

    <!-- Logo -->
    <view class="logo-section">
      <view class="logo-icon">
        <text class="logo-symbol">⚡</text>
      </view>
      <text class="brand-name">Open IoT</text>
      <text class="brand-subtitle">欢迎回来，请登录</text>
    </view>

    <!-- 表单 -->
    <view class="form-section">
      <view class="input-group">
        <input class="input" type="text" placeholder="邮箱" v-model="email" />
      </view>
      <view class="input-group">
        <input class="input" type="password" placeholder="密码" v-model="password" />
      </view>

      <view class="form-actions">
        <text class="server-info">{{ currentServerUrl }}</text>
        <text class="forgot-link" @click="goToForgotPassword">忘记密码？</text>
      </view>

      <button class="btn-primary" @click="handleLogin">登 录</button>

      <view class="register-link">
        <text class="register-text">还没有账号？</text>
        <text class="register-btn" @click="goToRegister">立即注册</text>
      </view>
    </view>

    <!-- 服务器设置底部弹窗 -->
    <view class="bottom-sheet-overlay" v-if="showServerModal" @tap="closeServerSettings">
      <view class="bottom-sheet" @tap.stop>
        <!-- 拖动手柄 -->
        <view class="drag-handle"></view>

        <!-- 关闭按钮 -->
        <view class="close-btn" @tap="closeServerSettings">
          <text class="close-icon">×</text>
        </view>

        <!-- 弹窗内容 -->
        <view class="sheet-content">
          <text class="sheet-title">API 服务器设置</text>

          <view class="input-group">
            <text class="input-label">服务器地址</text>
            <input
              class="input"
              v-model="serverUrl"
              placeholder="http://192.168.1.100:48080"
            />
          </view>

          <button class="btn-save" @tap="saveServerSettings">保 存</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'Login',
  data() {
    return {
      email: 'user@example.com',
      password: 'password123',
      showServerModal: false,
      serverUrl: 'http://192.168.1.100:48080',
      currentServerUrl: 'http://192.168.1.100:48080'
    };
  },
  onShow() {
    // 加载已保存的服务器配置
    const savedUrl = uni.getStorageSync('serverUrl');
    if (savedUrl) {
      this.serverUrl = savedUrl;
      this.currentServerUrl = savedUrl;
    }
  },
  methods: {
    handleLogin() {
      // TODO: 实际登录逻辑
      if (!this.email || !this.password) {
        uni.showToast({
          title: '请输入邮箱和密码',
          icon: 'none'
        });
        return;
      }

      // 模拟登录成功
      uni.setStorageSync('token', 'demo-token');
      // 使用 switchTab 跳转到 TabBar 页面
      uni.switchTab({
        url: '/pages/device-list/device-list'
      });
    },

    goToRegister() {
      uni.navigateTo({
        url: '/pages/register/register'
      });
    },

    goToForgotPassword() {
      uni.navigateTo({
        url: '/pages/forgot-password/forgot-password'
      });
    },

    showServerSettings() {
      this.showServerModal = true;
    },

    closeServerSettings() {
      this.showServerModal = false;
    },

    saveServerSettings() {
      // 保存服务器配置
      uni.setStorageSync('serverUrl', this.serverUrl);
      this.currentServerUrl = this.serverUrl;
      this.closeServerSettings();
      uni.showToast({
        title: '服务器设置已保存',
        icon: 'success'
      });
    }
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  padding: 48rpx;
  background: #FFFFFF;
  position: relative;
}

/* 服务器设置按钮 */
.settings-btn {
  position: absolute;
  top: 48rpx;
  right: 48rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 20rpx;
  background: #F5F5F7;
  border-radius: 20rpx;
}

.settings-icon {
  font-size: 32rpx;
}

.settings-text {
  font-size: 28rpx;
  color: #3A3A3C;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 120rpx;
  margin-bottom: 80rpx;
}

.logo-icon {
  width: 128rpx;
  height: 128rpx;
  background: #007AFF;
  border-radius: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.logo-symbol {
  font-size: 72rpx;
  color: #FFFFFF;
}

.brand-name {
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.brand-subtitle {
  font-size: 28rpx;
  color: #8E8E93;
}

.form-section {
  width: 100%;
}

.input-group {
  margin-bottom: 32rpx;
}

.input-label {
  font-size: 28rpx;
  color: #3A3A3C;
  margin-bottom: 12rpx;
  display: block;
}

.input {
  width: 100%;
  height: 96rpx;
  padding: 0 32rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  font-size: 32rpx;
  box-sizing: border-box;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 48rpx;
}

.server-info {
  font-size: 24rpx;
  color: #8E8E93;
  flex: 1;
}

.forgot-link {
  font-size: 28rpx;
  color: #007AFF;
  margin-left: 16rpx;
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

.register-link {
  display: flex;
  justify-content: center;
  margin-top: 32rpx;
}

.register-text {
  font-size: 28rpx;
  color: #8E8E93;
}

.register-btn {
  font-size: 28rpx;
  color: #007AFF;
  margin-left: 8rpx;
}

/* 底部弹窗 */
.bottom-sheet-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}

.bottom-sheet {
  position: relative;
  background: #FFFFFF;
  border-radius: 24rpx 24rpx 0 0;
  padding-bottom: 68rpx;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(100%);
  }
  to {
    transform: translateY(0);
  }
}

/* 拖动手柄 */
.drag-handle {
  width: 72rpx;
  height: 8rpx;
  background: #C7C7CC;
  border-radius: 4rpx;
  margin: 16rpx auto 24rpx;
}

/* 关闭按钮 */
.close-btn {
  position: absolute;
  top: 24rpx;
  right: 32rpx;
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-icon {
  font-size: 56rpx;
  color: #8E8E93;
  font-weight: 300;
  line-height: 1;
}

/* 弹窗内容 */
.sheet-content {
  padding: 0 48rpx 48rpx;
}

.sheet-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 48rpx;
  display: block;
  text-align: center;
}

.btnSave {
  width: 100%;
  height: 96rpx;
  background: #007AFF;
  color: #FFFFFF;
  border-radius: 16rpx;
  font-size: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 48rpx;
}
</style>
