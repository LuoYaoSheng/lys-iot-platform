<!-- 设备列表页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="device-list">
    <!-- 设备列表 -->
    <scroll-view class="list" scroll-y refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onRefresh">
      <view v-if="isLoading" class="loading">
        <text class="loading-text">加载中...</text>
      </view>

      <view v-else-if="devices.length === 0" class="empty">
        <AppIcon name="device" :size="120" color="#C7C7CC" />
        <text class="empty-text">暂无设备</text>
        <button class="btn-add" @click="goScan">添加设备</button>
      </view>

      <view v-for="device in devices" :key="device.id" class="device-card" @click="goControl(device)" @longpress="showDelete(device)">
        <view class="card-header">
          <view class="status-dot" :class="device.status"></view>
          <text class="device-name">{{ device.name }}</text>
          <text class="device-status" :class="device.status">{{ device.statusText || statusText(device) }}</text>
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
import AppIcon from '@/components/AppIcon.vue'
import deviceApi from '@/utils/device.js'

export default {
  components: { AppIcon },
  data() {
    return {
      devices: [],
      showModal: false,
      currentDevice: null,
      isLoading: false,
      refreshing: false
    }
  },
  onShow() {
    this.loadDevices()
  },
  methods: {
    async loadDevices() {
      this.isLoading = true
      try {
        const result = await deviceApi.getDeviceList()
        if (result.success) {
          this.devices = result.data.list.map(device => ({
            ...device,
            statusText: deviceApi.getStatusText(device)
          }))
        } else {
          uni.showToast({ title: result.message || '加载失败', icon: 'none' })
          // 加载失败时使用本地缓存
          this.loadFromCache()
        }
      } catch (e) {
        console.error('加载设备列表失败:', e)
        this.loadFromCache()
      } finally {
        this.isLoading = false
      }
    },
    loadFromCache() {
      try {
        const cached = uni.getStorageSync('cache_devices')
        if (cached) {
          this.devices = cached
        }
      } catch (e) {
        // 忽略
      }
    },
    saveToCache() {
      try {
        uni.setStorageSync('cache_devices', this.devices)
      } catch (e) {
        // 忽略
      }
    },
    async onRefresh() {
      this.refreshing = true
      await this.loadDevices()
      this.refreshing = false
    },
    statusText(device) {
      return deviceApi.getStatusText(device)
    },
    goScan() {
      uni.navigateTo({ url: '/pages/scan/scan' })
    },
    goControl(device) {
      uni.navigateTo({ url: '/pages/device-control/device-control?id=' + device.deviceId })
    },
    showDelete(device) {
      this.currentDevice = device
      this.showModal = true
    },
    async doDelete() {
      if (!this.currentDevice) return

      try {
        const result = await deviceApi.deleteDevice(this.currentDevice.deviceId)
        if (result.success) {
          this.devices = this.devices.filter(d => d.deviceId !== this.currentDevice.deviceId)
          this.saveToCache()
          this.showModal = false
          uni.showToast({ title: '已删除', icon: 'success' })
        } else {
          uni.showToast({ title: result.message || '删除失败', icon: 'none' })
        }
      } catch (e) {
        uni.showToast({ title: '删除失败', icon: 'none' })
      }
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

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding-top: 200rpx;
}

.loading-text {
  font-size: $font-md;
  color: $color-text-secondary;
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
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
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
