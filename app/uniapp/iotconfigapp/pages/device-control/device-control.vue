<!-- 设备控制页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="control">
    <!-- 状态卡片 -->
    <view class="status-card">
      <view class="status-dot" :class="device.status"></view>
      <text class="status-text" :class="device.status">{{ statusText(device.status) }}</text>
      <text class="firmware">固件: {{ device.firmware }}</text>
    </view>

    <!-- 舵机控制 -->
    <view v-if="device.type === 'servo'" class="control-section">
      <text class="section-title">位置控制</text>
      <view class="position-display">
        <text class="position-label">当前位置</text>
        <text class="position-value">{{ positionText }}</text>
      </view>
      <view class="position-buttons">
        <button class="pos-btn" :class="{ active: position === 'up' }" @click="setPosition('up')">上</button>
        <button class="pos-btn" :class="{ active: position === 'middle' }" @click="setPosition('middle')">中</button>
        <button class="pos-btn" :class="{ active: position === 'down' }" @click="setPosition('down')">下</button>
      </view>

      <view class="pulse-section">
        <text class="section-title">脉冲触发</text>
        <button class="pulse-btn" :class="{ sending: pulseSending, success: pulseSuccess }" @click="triggerPulse">
          {{ pulseSending ? '发送中...' : (pulseSuccess ? '✓ 已触发' : '触发脉冲') }}
        </button>
        <text class="pulse-hint">短暂触发后自动恢复</text>
      </view>
    </view>

    <!-- USB唤醒控制 -->
    <view v-else class="control-section">
      <text class="section-title">电脑唤醒</text>
      <view class="wakeup-card" @click="triggerWakeup">
        <view class="wakeup-icon">
          <image src="/static/icons/power.svg" class="power-img" mode="aspectFit"></image>
        </view>
        <text class="wakeup-label">点击唤醒</text>
        <text class="wakeup-hint">电脑将立即启动</text>
      </view>
    </view>

    <!-- 设备信息 -->
    <view class="info-section">
      <text class="section-title">设备信息</text>
      <view class="info-card">
        <view class="info-item editable" @click="editDeviceName">
          <text class="info-label">设备名称</text>
          <view class="info-right">
            <text class="info-value">{{ device.name }}</text>
            <text class="edit-icon">›</text>
          </view>
        </view>
        <view class="info-item">
          <text class="info-label">设备ID</text>
          <text class="info-value">{{ device.id }}</text>
        </view>
        <view class="info-item">
          <text class="info-label">设备类型</text>
          <text class="info-value">{{ device.type === 'servo' ? '舵机开关' : 'USB唤醒' }}</text>
        </view>
      </view>
    </view>

    <!-- 删除按钮 -->
    <view class="delete-section">
      <button class="btn-delete" @click="confirmDelete">删除设备</button>
    </view>

    <!-- 编辑名称弹窗 -->
    <view class="modal" v-if="showEditModal" @click="showEditModal = false">
      <view class="modal-content" @click.stop>
        <text class="modal-title">修改设备名称</text>
        <input
          class="modal-input"
          v-model="editName"
          placeholder="请输入设备名称"
          maxlength="20"
        />
        <view class="modal-btns">
          <button class="btn-cancel" @click="showEditModal = false">取消</button>
          <button class="btn-confirm" @click="saveDeviceName">确定</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      device: { id: '', name: '', type: 'servo', status: 'online', firmware: 'v1.0.0' },
      position: 'middle',
      pulseSending: false,
      pulseSuccess: false,
      showEditModal: false,
      editName: ''
    }
  },
  computed: {
    positionText() {
      return { up: '上', middle: '中', down: '下' }[this.position]
    }
  },
  onLoad(options) {
    if (options.id) {
      this.loadDevice(options.id)
    }
  },
  methods: {
    loadDevice(id) {
      const devices = uni.getStorageSync('devices') || []
      const device = devices.find(d => d.id === id)
      if (device) this.device = device
    },
    statusText(status) {
      return { online: '在线', offline: '离线', configuring: '配置中' }[status] || '未知'
    },
    setPosition(pos) {
      this.position = pos
      uni.showToast({ title: '已设置到' + this.positionText, icon: 'success' })
    },
    triggerPulse() {
      if (this.pulseSending) return
      this.pulseSending = true
      this.pulseSuccess = false
      setTimeout(() => {
        this.pulseSending = false
        this.pulseSuccess = true
        setTimeout(() => { this.pulseSuccess = false }, 2000)
      }, 800)
    },
    triggerWakeup() {
      uni.showToast({ title: '唤醒信号已发送', icon: 'success' })
    },
    editDeviceName() {
      this.editName = this.device.name
      this.showEditModal = true
    },
    saveDeviceName() {
      const newName = this.editName.trim()
      if (!newName) {
        uni.showToast({ title: '名称不能为空', icon: 'none' })
        return
      }
      // 更新本地存储
      const devices = uni.getStorageSync('devices') || []
      const index = devices.findIndex(d => d.id === this.device.id)
      if (index !== -1) {
        devices[index].name = newName
        uni.setStorageSync('devices', devices)
        this.device.name = newName
      }
      this.showEditModal = false
      uni.showToast({ title: '修改成功', icon: 'success' })
    },
    confirmDelete() {
      uni.showModal({
        title: '删除设备',
        content: '确定要删除「' + this.device.name + '」吗？',
        success: (res) => {
          if (res.confirm) {
            const devices = uni.getStorageSync('devices') || []
            const newDevices = devices.filter(d => d.id !== this.device.id)
            uni.setStorageSync('devices', newDevices)
            uni.showToast({ title: '已删除', icon: 'success' })
            setTimeout(() => uni.navigateBack(), 1500)
          }
        }
      })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.control {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-lg;
  box-sizing: border-box;
}

.status-card {
  display: flex;
  align-items: center;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-lg;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: $spacing-sm;
  background: $color-text-secondary;
  &.online { background: $color-success; }
  &.offline { background: $color-text-secondary; }
}

.status-text {
  flex: 1;
  font-size: $font-md;
  font-weight: 500;
  color: $color-text-secondary;
  &.online { color: $color-success; }
}

.firmware {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.control-section, .info-section {
  margin-bottom: $spacing-lg;
}

.section-title {
  display: block;
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-md;
}

.position-display {
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-xl;
  text-align: center;
  margin-bottom: $spacing-md;
}

.position-label {
  display: block;
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-sm;
}

.position-value {
  font-size: 64rpx;
  font-weight: 600;
  color: $color-primary;
}

.position-buttons {
  display: flex;
  gap: $spacing-md;
  margin-bottom: $spacing-xl;
}

.pos-btn {
  flex: 1;
  height: $height-button;
  background: $color-card;
  color: $color-text;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
  &.active {
    background: $color-primary;
    color: #FFF;
  }
}

.pulse-section {
  margin-top: $spacing-xl;
  padding-top: $spacing-xl;
  border-top: 1rpx solid $color-border;
}

.pulse-btn {
  width: 100%;
  height: $height-button;
  background: $color-primary;
  color: #FFF;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
  margin-bottom: $spacing-sm;
  &.sending { background: $color-warning; }
  &.success { background: $color-success; }
}

.pulse-hint {
  display: block;
  text-align: center;
  font-size: $font-xs;
  color: $color-text-secondary;
}

.wakeup-card {
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-2xl;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.wakeup-icon {
  width: 120rpx;
  height: 120rpx;
  background: rgba(0, 122, 255, 0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-md;
}

.power-img {
  width: 56rpx;
  height: 56rpx;
}

.wakeup-label {
  font-size: $font-lg;
  font-weight: 500;
  color: $color-text;
  margin-bottom: $spacing-xs;
}

.wakeup-hint {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.info-card {
  background: $color-card;
  border-radius: $radius-lg;
  overflow: hidden;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1rpx solid $color-border;
  &:last-child { border-bottom: none; }
  &.editable {
    cursor: pointer;
  }
}

.info-right {
  display: flex;
  align-items: center;
  gap: $spacing-xs;
}

.info-label {
  font-size: $font-md;
  color: $color-text;
}

.info-value {
  font-size: $font-md;
  color: $color-text-secondary;
}

.edit-icon {
  font-size: $font-lg;
  color: $color-text-secondary;
}

.delete-section {
  margin-top: $spacing-xl;
}

.btn-delete {
  width: 100%;
  height: $height-button;
  background: $color-card;
  color: $color-error;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
}

// 编辑名称弹窗
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}

.modal-content {
  width: 560rpx;
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-xl;
}

.modal-title {
  display: block;
  font-size: $font-lg;
  font-weight: 600;
  color: $color-text;
  text-align: center;
  margin-bottom: $spacing-lg;
}

.modal-input {
  width: 100%;
  height: 88rpx;
  background: $color-bg;
  border: 2rpx solid $color-border;
  border-radius: $radius-md;
  padding: 0 $spacing-md;
  font-size: $font-md;
  box-sizing: border-box;
  margin-bottom: $spacing-lg;
}

.modal-btns {
  display: flex;
  gap: $spacing-md;
}

.btn-cancel, .btn-confirm {
  flex: 1;
  height: $height-button-sm;
  border-radius: $radius-md;
  font-size: $font-md;
  border: none;
}

.btn-cancel {
  background: $color-bg;
  color: $color-text-secondary;
}

.btn-confirm {
  background: $color-primary;
  color: #FFF;
}
</style>
