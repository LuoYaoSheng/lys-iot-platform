<!-- 设备列表页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="device-list">
    <!-- 设备列表 -->
    <scroll-view class="list" scroll-y>
      <view v-if="devices.length === 0" class="empty">
        <text class="empty-icon">📱</text>
        <text class="empty-text">暂无设备</text>
        <button class="btn-add" @click="goScan">添加设备</button>
      </view>

      <view v-for="device in devices" :key="device.id" class="device-card" @click="goControl(device)" @longpress="showDelete(device)">
        <view class="card-header">
          <view class="status-dot" :class="device.status"></view>
          <text class="device-name">{{ device.name }}</text>
          <text class="device-status" :class="device.status">{{ statusText(device.status) }}</text>
        </view>
        <view class="card-footer">
          <text class="device-info">{{ device.type === 'servo' ? '舵机开关' : 'USB唤醒' }}</text>
          <text class="device-info">固件: {{ device.firmware }}</text>
        </view>
      </view>

      <view v-if="devices.length > 0" class="tip">长按设备可删除</view>
    </scroll-view>

    <!-- 悬浮添加按钮 -->
    <view class="fab" @click="goScan">
      <text class="fab-icon">+</text>
    </view>

    <!-- 删除确认 -->
    <view class="modal" v-if="showModal" @click="showModal = false">
      <view class="modal-content" @click.stop>
        <text class="modal-title">删除设备</text>
        <text class="modal-msg">确定删除「{{ currentDevice?.name }}」？</text>
        <view class="modal-btns">
          <button class="btn-cancel" @click="showModal = false">取消</button>
          <button class="btn-delete" @click="doDelete">删除</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
// Mock数据
const mockDevices = [
  { id: '1', name: 'IoT-Switch-A1B2', type: 'servo', status: 'online', firmware: 'v1.2.0' },
  { id: '2', name: 'IoT-Wakeup-C3D4', type: 'wakeup', status: 'online', firmware: 'v1.0.0' },
  { id: '3', name: 'IoT-Switch-E5F6', type: 'servo', status: 'offline', firmware: 'v1.1.0' }
]

export default {
  data() {
    return {
      devices: [],
      showModal: false,
      currentDevice: null
    }
  },
  onShow() {
    this.loadDevices()
  },
  methods: {
    loadDevices() {
      // 从本地存储获取，如果没有则用mock数据
      const saved = uni.getStorageSync('devices')
      this.devices = saved || mockDevices
      if (!saved) uni.setStorageSync('devices', mockDevices)
    },
    statusText(status) {
      return { online: '在线', offline: '离线', configuring: '配置中' }[status] || '未知'
    },
    goScan() {
      uni.navigateTo({ url: '/pages/scan/scan' })
    },
    goControl(device) {
      uni.navigateTo({ url: '/pages/device-control/device-control?id=' + device.id })
    },
    showDelete(device) {
      this.currentDevice = device
      this.showModal = true
    },
    doDelete() {
      this.devices = this.devices.filter(d => d.id !== this.currentDevice.id)
      uni.setStorageSync('devices', this.devices)
      this.showModal = false
      uni.showToast({ title: '已删除', icon: 'success' })
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.device-list {
  min-height: 100vh;
  background: $color-bg;
  box-sizing: border-box;
}

.list {
  height: calc(100vh - 100rpx);
  padding: $spacing-lg;
  box-sizing: border-box;
}

.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 200rpx;
}

.empty-icon { font-size: 120rpx; margin-bottom: $spacing-lg; }
.empty-text { font-size: $font-md; color: $color-text-secondary; margin-bottom: $spacing-xl; }

.btn-add {
  padding: 0 $spacing-xl;
  height: $height-button-sm;
  background: $color-primary;
  color: #FFF;
  border-radius: $radius-md;
  font-size: $font-sm;
  border: none;
}

.device-card {
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-md;
}

.card-header {
  display: flex;
  align-items: center;
  margin-bottom: $spacing-sm;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: $spacing-sm;
  background: $color-text-secondary;
  &.online { background: $color-success; }
  &.offline { background: $color-text-secondary; }
  &.configuring { background: $color-warning; }
}

.device-name {
  flex: 1;
  font-size: $font-md;
  font-weight: 500;
  color: $color-text;
}

.device-status {
  font-size: $font-sm;
  color: $color-text-secondary;
  &.online { color: $color-success; }
}

.card-footer {
  display: flex;
  justify-content: space-between;
  padding-left: 28rpx;
}

.device-info {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.tip {
  text-align: center;
  font-size: $font-xs;
  color: $color-text-secondary;
  padding: $spacing-lg;
}

.fab {
  position: fixed;
  right: $spacing-xl;
  bottom: calc(100rpx + env(safe-area-inset-bottom));
  width: 112rpx;
  height: 112rpx;
  background: $color-primary;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: $shadow-lg;
}

.fab-icon {
  font-size: 56rpx;
  color: #FFF;
  font-weight: 300;
}

.modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
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
  font-size: $font-lg;
  font-weight: 600;
  color: $color-text;
  text-align: center;
  margin-bottom: $spacing-md;
}

.modal-msg {
  font-size: $font-sm;
  color: $color-text-secondary;
  text-align: center;
  margin-bottom: $spacing-xl;
}

.modal-btns {
  display: flex;
  gap: $spacing-md;
}

.btn-cancel, .btn-delete {
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

.btn-delete {
  background: $color-error;
  color: #FFF;
}
</style>
