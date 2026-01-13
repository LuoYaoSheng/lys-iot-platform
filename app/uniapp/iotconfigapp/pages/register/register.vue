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

      <view class="form">
        <view class="input-group">
          <input class="input" type="text" placeholder="邮箱" v-model="email" />
        </view>
        <view class="input-group">
          <input class="input" type="password" placeholder="密码" v-model="password" />
        </view>
        <view class="input-group">
          <input class="input" type="password" placeholder="确认密码" v-model="confirmPassword" />
        </view>

        <button class="btn-primary" @click="handleRegister">注 册</button>
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
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 64rpx;
}

.form {
  width: 100%;
}

.input-group {
  margin-bottom: 32rpx;
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
</style>
