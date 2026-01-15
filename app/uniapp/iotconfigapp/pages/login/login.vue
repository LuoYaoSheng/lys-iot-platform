<!-- 登录页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="login">
    <!-- 右上角设置按钮 -->
    <view class="settings-btn" @click="showServerConfig = true">
      <text class="settings-icon">⚙️</text>
    </view>

    <!-- Logo -->
    <view class="header">
      <view class="logo">
        <text class="logo-icon">⚡</text>
      </view>
      <text class="title">Open IoT</text>
      <text class="subtitle">欢迎回来，请登录</text>
    </view>

    <!-- 表单 -->
    <view class="form">
      <view class="input-group">
        <input class="input" type="text" placeholder="邮箱" v-model="email" />
      </view>
      <view class="input-group">
        <input class="input" :type="showPwd ? 'text' : 'password'" placeholder="密码" v-model="password" />
        <text class="input-action" @click="showPwd = !showPwd">{{ showPwd ? '隐藏' : '显示' }}</text>
      </view>

      <view class="form-footer">
        <text class="link" @click="goForgotPassword">忘记密码？</text>
      </view>

      <button class="btn-primary" @click="handleLogin">登录</button>

      <view class="register-row">
        <text class="text">还没有账号？</text>
        <text class="link" @click="goRegister">立即注册</text>
      </view>
    </view>

    <!-- 服务器配置弹窗 -->
    <view class="modal-mask" v-if="showServerConfig" @click="showServerConfig = false">
      <view class="modal-content" @click.stop>
        <view class="modal-handle"></view>
        <text class="modal-title">服务器配置</text>
        <view class="modal-form">
          <text class="modal-label">API 服务器地址</text>
          <input class="modal-input" type="text" v-model="serverUrl" placeholder="http://192.168.1.100:48080" />
        </view>
        <button class="btn-primary" @click="saveServerConfig">保存配置</button>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      email: '',
      password: '',
      showPwd: false,
      showServerConfig: false,
      serverUrl: ''
    }
  },
  onLoad() {
    this.serverUrl = uni.getStorageSync('serverUrl') || 'http://192.168.1.100:48080'
  },
  methods: {
    saveServerConfig() {
      uni.setStorageSync('serverUrl', this.serverUrl)
      this.showServerConfig = false
      uni.showToast({ title: '已保存', icon: 'success' })
    },
    handleLogin() {
      if (!this.email || !this.password) {
        uni.showToast({ title: '请输入邮箱和密码', icon: 'none' })
        return
      }
      // Mock登录
      uni.setStorageSync('token', 'mock_token')
      uni.setStorageSync('userInfo', { email: this.email })
      uni.switchTab({ url: '/pages/device-list/device-list' })
    },
    goRegister() {
      uni.navigateTo({ url: '/pages/register/register' })
    },
    goForgotPassword() {
      uni.navigateTo({ url: '/pages/forgot-password/forgot-password' })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.login {
  min-height: 100vh;
  background: $color-card;
  padding: $spacing-xl;
  box-sizing: border-box;
}

.header {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 180rpx 0 80rpx; // 增加顶部间距，对齐 Flutter SafeArea
}

.logo {
  width: 128rpx;
  height: 128rpx;
  background: $color-primary;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-xl;
}

.logo-icon {
  font-size: 64rpx;
  color: #FFFFFF;
}

.title {
  font-size: $font-2xl;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-sm;
}

.subtitle {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.form {
  width: 100%;
}

.input-group {
  position: relative;
  margin-bottom: $spacing-lg;
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

.input-action {
  position: absolute;
  right: $spacing-lg;
  top: 50%;
  transform: translateY(-50%);
  font-size: $font-sm;
  color: $color-primary;
}

.form-footer {
  display: flex;
  justify-content: flex-end;
  margin-bottom: $spacing-xl;
}

.link {
  font-size: $font-sm;
  color: $color-primary;
}

.text {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.btn-primary {
  width: 100%;
  height: $height-button;
  background: $color-primary;
  color: #FFFFFF;
  font-size: $font-md;
  font-weight: 500;
  border-radius: $radius-md;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.btn-primary:active {
  background: $color-primary-dark;
}

.register-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: $spacing-xs;
  margin-top: $spacing-lg;
}

// 右上角设置按钮
.settings-btn {
  position: absolute;
  top: 100rpx;
  right: $spacing-xl;
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.settings-icon {
  font-size: 48rpx;
}

// 弹窗样式
.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  z-index: 100;
}

.modal-content {
  width: 100%;
  background: $color-card;
  border-radius: 40rpx 40rpx 0 0;
  padding: $spacing-xl;
  box-sizing: border-box;
}

.modal-handle {
  width: 72rpx;
  height: 8rpx;
  background: #E5E5EA;
  border-radius: 4rpx;
  margin: 0 auto $spacing-xl;
}

.modal-title {
  display: block;
  text-align: center;
  font-size: $font-lg;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-xl;
}

.modal-form {
  margin-bottom: $spacing-xl;
}

.modal-label {
  display: block;
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-sm;
}

.modal-input {
  width: 100%;
  height: $height-input;
  background: $color-bg;
  border-radius: $radius-md;
  padding: 0 $spacing-lg;
  font-size: $font-md;
  box-sizing: border-box;
}
</style>
