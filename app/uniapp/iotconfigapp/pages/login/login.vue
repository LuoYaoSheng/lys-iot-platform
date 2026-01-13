<!-- 登录页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="login-container">
    <!-- 服务器设置按钮 -->
    <view class="settings-btn" @tap="showServerSettings">
      <text class="settings-icon">⚙️</text>
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
        <text class="forgot-link" @click="goToForgotPassword">忘记密码？</text>
      </view>

      <button class="btn-primary" @click="handleLogin">登 录</button>

      <view class="register-link">
        <text class="register-text">还没有账号？</text>
        <text class="register-btn" @click="goToRegister">立即注册</text>
      </view>
    </view>

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
  name: 'Login',
  data() {
    return {
      email: '',
      password: '',
      showServerModal: false,
      serverUrl: 'https://iot.example.com',
      serverPort: '443'
    };
  },
  onShow() {
    // 加载已保存的服务器配置
    const savedUrl = uni.getStorageSync('serverUrl');
    const savedPort = uni.getStorageSync('serverPort');
    if (savedUrl) this.serverUrl = savedUrl;
    if (savedPort) this.serverPort = savedPort;
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
      uni.redirectTo({
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
      uni.setStorageSync('serverPort', this.serverPort);
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
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.settings-icon {
  font-size: 36rpx;
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
  justify-content: flex-end;
  margin-bottom: 48rpx;
}

.forgot-link {
  font-size: 28rpx;
  color: #007AFF;
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

.modal-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 32rpx;
}

.modal-btn {
  flex: 1;
  height: 80rpx;
  border-radius: 16rpx;
  font-size: 32rpx;
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
