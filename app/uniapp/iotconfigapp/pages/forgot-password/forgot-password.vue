<!-- 忘记密码页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="forgot">
    <view class="desc">
      <text class="desc-text">请输入您的注册邮箱，我们将发送密码重置链接。</text>
    </view>

    <view class="form">
      <view class="input-group">
        <text class="label">邮箱</text>
        <input class="input" type="text" placeholder="请输入邮箱" v-model="email" />
      </view>

      <button class="btn-primary" @click="handleSubmit">发送重置链接</button>

      <view class="footer">
        <text class="link" @click="goBack">返回登录</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      email: ''
    }
  },
  methods: {
    handleSubmit() {
      if (!this.email) {
        uni.showToast({ title: '请输入邮箱', icon: 'none' })
        return
      }
      uni.showToast({ title: '重置链接已发送', icon: 'success' })
      setTimeout(() => uni.navigateBack(), 1500)
    },
    goBack() {
      uni.navigateBack()
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.forgot {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-xl;
  box-sizing: border-box;
}

.desc {
  margin-bottom: $spacing-xl;
}

.desc-text {
  font-size: $font-sm;
  color: $color-text-secondary;
  line-height: 1.6;
}

.form {
  width: 100%;
}

.input-group {
  margin-bottom: $spacing-xl;
}

.label {
  display: block;
  font-size: $font-sm;
  color: $color-text;
  margin-bottom: $spacing-sm;
}

.input {
  width: 100%;
  height: $height-input;
  background: $color-card;
  border-radius: $radius-md;
  padding: 0 $spacing-lg;
  font-size: $font-md;
  box-sizing: border-box;
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

.footer {
  display: flex;
  justify-content: center;
  margin-top: $spacing-lg;
}

.link {
  font-size: $font-sm;
  color: $color-primary;
}
</style>
