<!-- 忘记密码页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="forgot-container">
    <view class="header">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">忘记密码</text>
    </view>

    <view class="content">
      <text class="page-title">找回密码</text>
      <text class="page-desc">请输入您的注册邮箱，我们将发送密码重置链接。</text>

      <view class="form">
        <view class="input-group">
          <text class="input-label">邮箱</text>
          <input class="input" type="text" placeholder="请输入邮箱" v-model="email" />
        </view>

        <button class="btn-primary" @click="handleSubmit">发送重置链接</button>
        <view class="back-link" @click="goBack">
          <text>返回登录</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'ForgotPassword',
  data() {
    return {
      email: ''
    };
  },
  methods: {
    handleSubmit() {
      if (!this.email) {
        uni.showToast({
          title: '请输入邮箱',
          icon: 'none'
        });
        return;
      }

      // TODO: 实际发送逻辑
      uni.showToast({
        title: '重置链接已发送',
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
.forgot-container {
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
  font-size: 28rpx;
  display: block;
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
}

.back-link {
  text-align: center;
  margin-top: 32rpx;

  text {
    color: #007AFF;
    font-size: 28rpx;
  }
}
</style>
