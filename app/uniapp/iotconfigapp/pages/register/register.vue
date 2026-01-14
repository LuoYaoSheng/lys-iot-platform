<!-- 注册页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="register-container">
    <view class="header">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">注册</text>
    </view>

    <view class="content">
      <text class="page-title">创建新账号</text>
      <text class="page-desc">请填写注册信息</text>

      <view class="form">
        <view class="input-group">
          <text class="input-label">邮箱</text>
          <input class="input" type="text" placeholder="请输入邮箱" v-model="email" />
        </view>
        <view class="input-group">
          <text class="input-label">密码</text>
          <input class="input" type="password" placeholder="请输入密码" v-model="password" />
        </view>
        <view class="input-group">
          <text class="input-label">确认密码</text>
          <input class="input" type="password" placeholder="请再次输入密码" v-model="confirmPassword" />
        </view>

        <!-- 黄色提示badge -->
        <view class="password-badge">
          <text class="badge-icon">⚠️</text>
          <text class="badge-text">密码至少 8 位，包含字母和数字</text>
        </view>

        <button class="btn-primary" @click="handleRegister">注 册</button>

        <!-- 登录链接 -->
        <view class="login-link">
          <text class="login-btn" @click="goToLogin">返回登录</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'Register',
  data() {
    return {
      email: '',
      password: '',
      confirmPassword: ''
    };
  },
  methods: {
    handleRegister() {
      if (!this.email || !this.password) {
        uni.showToast({
          title: '请填写完整信息',
          icon: 'none'
        });
        return;
      }

      if (this.password !== this.confirmPassword) {
        uni.showToast({
          title: '两次密码不一致',
          icon: 'none'
        });
        return;
      }

      // TODO: 实际注册逻辑
      uni.showToast({
        title: '注册成功',
        icon: 'success'
      });

      setTimeout(() => {
        uni.navigateBack();
      }, 1500);
    },

    goToLogin() {
      uni.navigateTo({
        url: '/pages/login/login'
      });
    },

    goBack() {
      uni.navigateBack();
    }
  }
};
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  background: #FFFFFF;
}

.header {
  display: flex;
  align-items: center;
  padding: 32rpx;
  position: relative;
}

.back-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  font-size: 64rpx;
  color: #3A3A3C;
  font-weight: 300;
}

.title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.content {
  padding: 32rpx;
}

.page-title {
  display: block;
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.page-desc {
  display: block;
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 64rpx;
}

.form {
  width: 100%;
}

.input-group {
  margin-bottom: 32rpx;
}

.input-label {
  display: block;
  font-size: 28rpx;
  color: #3A3A3C;
  margin-bottom: 12rpx;
}

.input {
  width: 100%;
  height: 96rpx;
  padding: 0 32rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  font-size: 32rpx;
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
  margin-top: 32rpx;
}

/* 密码提示badge */
.password-badge {
  display: flex;
  align-items: center;
  padding: 24rpx;
  background: rgba(255, 149, 0, 0.1);
  border: 1px solid rgba(255, 149, 0, 0.3);
  border-radius: 16rpx;
  margin-bottom: 32rpx;
}

.badge-icon {
  font-size: 28rpx;
  margin-right: 12rpx;
}

.badge-text {
  flex: 1;
  font-size: 28rpx;
  color: #FF9500;
}

/* 登录链接 */
.login-link {
  text-align: center;
  margin-top: 32rpx;
}

.login-btn {
  font-size: 28rpx;
  color: #007AFF;
}
</style>
