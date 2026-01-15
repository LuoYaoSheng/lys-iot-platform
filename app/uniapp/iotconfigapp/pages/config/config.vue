<!-- WiFi配置页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="config">
    <!-- 步骤指示器 -->
    <view class="stepper">
      <view class="step" :class="{ current: step === 1, done: step > 1 }">
        <view class="circle">1</view>
        <text class="step-text">WiFi</text>
      </view>
      <view class="line"></view>
      <view class="step" :class="{ current: step === 2, done: step > 2 }">
        <view class="circle">2</view>
        <text class="step-text">名称</text>
      </view>
      <view class="line"></view>
      <view class="step" :class="{ current: step === 3 }">
        <view class="circle">3</view>
        <text class="step-text">完成</text>
      </view>
    </view>

    <!-- 设备信息卡片 -->
    <view class="device-card">
      <AppIcon :name="deviceType === 'USB唤醒' ? 'bolt' : 'plug'" :size="48" color="#007AFF" />
      <view class="device-info">
        <text class="device-name">{{ deviceName }}</text>
        <text class="device-type">{{ deviceType }}</text>
      </view>
    </view>

    <!-- Step 1: WiFi配置 -->
    <view v-if="step === 1" class="form-card">
      <view class="input-group">
        <text class="label">WiFi 网络</text>
        <view class="select" @click="selectWifi">
          <text>{{ wifiName || '选择WiFi' }}</text>
          <text class="arrow">›</text>
        </view>
      </view>
      <view class="input-group">
        <text class="label">WiFi 密码</text>
        <input class="input" type="password" placeholder="请输入WiFi密码" v-model="wifiPassword" />
      </view>
      <button class="btn-primary" @click="nextStep">下一步</button>
    </view>

    <!-- Step 2: 设备命名 -->
    <view v-if="step === 2" class="form-card">
      <view class="input-group">
        <text class="label">设备名称</text>
        <input class="input" placeholder="请输入设备名称" v-model="customName" />
      </view>
      <view class="input-group">
        <text class="label">设备位置（可选）</text>
        <input class="input" placeholder="如：客厅、卧室" v-model="location" />
      </view>
      <button class="btn-primary" @click="nextStep">下一步</button>
    </view>

    <!-- Step 3: 配置完成 -->
    <view v-if="step === 3" class="success-card">
      <AppIcon name="check" :size="64" color="#FFFFFF" />
      <text class="success-title">配置成功</text>
      <text class="success-desc">设备已添加到您的设备列表</text>
      <button class="btn-primary" @click="goDeviceList">返回设备列表</button>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  data() {
    return {
      step: 1,
      deviceName: '',
      deviceType: '',
      wifiName: 'MyHome_5G',
      wifiPassword: '',
      customName: '',
      location: ''
    }
  },
  onLoad(options) {
    this.deviceName = options.name || 'IoT-Device'
    this.deviceType = options.type || '舵机开关'
    this.customName = this.deviceName
  },
  methods: {
    selectWifi() {
      uni.showToast({ title: '选择WiFi功能开发中', icon: 'none' })
    },
    nextStep() {
      if (this.step === 1 && !this.wifiPassword) {
        uni.showToast({ title: '请输入WiFi密码', icon: 'none' })
        return
      }
      if (this.step === 2 && !this.customName) {
        uni.showToast({ title: '请输入设备名称', icon: 'none' })
        return
      }
      if (this.step === 2) {
        // 保存设备
        this.saveDevice()
      }
      this.step++
    },
    saveDevice() {
      const devices = uni.getStorageSync('devices') || []
      const newDevice = {
        id: Date.now().toString(),
        name: this.customName,
        type: this.deviceType === 'USB唤醒' ? 'wakeup' : 'servo',
        status: 'online',
        firmware: 'v1.0.0',
        location: this.location
      }
      devices.push(newDevice)
      uni.setStorageSync('devices', devices)
    },
    goDeviceList() {
      uni.switchTab({ url: '/pages/device-list/device-list' })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.config {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-lg;
  box-sizing: border-box;
}

.stepper {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-xl 0;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.circle {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  background: $color-border;
  color: $color-text-secondary;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $font-sm;
  margin-bottom: $spacing-sm;
}

.step.current .circle,
.step.done .circle {
  background: $color-primary;
  color: #FFF;
}

.step-text {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.step.current .step-text {
  color: $color-primary;
}

.line {
  width: 80rpx;
  height: 4rpx;
  background: $color-border;
  margin: 0 $spacing-sm;
  margin-bottom: 40rpx;
}

.device-card {
  display: flex;
  align-items: center;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-lg;
}

.device-icon {
  font-size: 48rpx;
  margin-right: $spacing-md;
}

.device-info {
  display: flex;
  flex-direction: column;
}

.device-name {
  font-size: $font-md;
  font-weight: 500;
  color: $color-text;
}

.device-type {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.form-card {
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
}

.input-group {
  margin-bottom: $spacing-lg;
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

.select {
  width: 100%;
  height: $height-input;
  background: $color-bg;
  border-radius: $radius-md;
  padding: 0 $spacing-lg;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: $font-md;
  color: $color-text;
  box-sizing: border-box;
}

.arrow {
  font-size: 32rpx;
  color: $color-placeholder;
}

.btn-primary {
  width: 100%;
  height: $height-button;
  background: $color-primary;
  color: #FFF;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
  margin-top: $spacing-md;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.success-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-2xl $spacing-lg;
}

.success-icon {
  width: 120rpx;
  height: 120rpx;
  background: $color-success;
  border-radius: 50%;
  color: #FFF;
  font-size: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-lg;
}

.success-title {
  font-size: $font-xl;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-sm;
}

.success-desc {
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-xl;
}
</style>
