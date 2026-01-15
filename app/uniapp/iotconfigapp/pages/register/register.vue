<!-- 注册页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="register">
    <view class="form">
      <view class="input-group">
        <text class="label">邮箱</text>
        <input class="input" type="text" placeholder="请输入邮箱" v-model="email" />
      </view>
      <view class="input-group">
        <text class="label">密码</text>
        <input class="input" :type="showPwd ? 'text' : 'password'" placeholder="请输入密码" v-model="password" />
        <view class="input-action" @click="showPwd = !showPwd"><AppIcon :name="showPwd ? 'eyeOff' : 'eye'" :size="40" color="#8E8E93" /></view>
      </view>
      <view class="input-group">
        <text class="label">确认密码</text>
        <input class="input" :type="showPwd ? 'text' : 'password'" placeholder="请再次输入密码" v-model="confirmPassword" />
      </view>

      <view class="tip">
        <AppIcon name="warning" :size="32" color="#FF9500" />
        <text class="tip-text">密码至少8位，包含字母和数字</text>
      </view>

      <button class="btn-primary" @click="handleRegister">注册</button>

      <view class="footer">
        <text class="text">已有账号？</text>
        <text class="link" @click="goBack">返回登录</text>
      </view>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  data() {
    return {
      email: '',
      password: '',
      confirmPassword: '',
      showPwd: false
    }
  },
  methods: {
    handleRegister() {
      if (!this.email || !this.password || !this.confirmPassword) {
        uni.showToast({ title: '请填写完整信息', icon: 'none' })
        return
      }
      if (this.password !== this.confirmPassword) {
        uni.showToast({ title: '两次密码不一致', icon: 'none' })
        return
      }
      uni.showToast({ title: '注册成功', icon: 'success' })
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

.register {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-xl;
  box-sizing: border-box;
}

.form {
  width: 100%;
}

.input-group {
  position: relative;
  margin-bottom: $spacing-lg;
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

.input-action {
  position: absolute;
  right: $spacing-lg;
  bottom: 30rpx;
  font-size: $font-sm;
  color: $color-primary;
}

.tip {
  display: flex;
  align-items: center;
  padding: $spacing-md;
  background: rgba(255, 149, 0, 0.1);
  border-radius: $radius-md;
  margin-bottom: $spacing-xl;
}

.tip-icon {
  font-size: $font-sm;
  margin-right: $spacing-sm;
}

.tip-text {
  font-size: $font-sm;
  color: $color-warning;
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
  align-items: center;
  gap: $spacing-xs;
  margin-top: $spacing-lg;
}

.text {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.link {
  font-size: $font-sm;
  color: $color-primary;
}
</style>
