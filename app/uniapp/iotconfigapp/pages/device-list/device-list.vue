<!-- 设备列表页（主页） -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="device-list-container">
    <!-- 状态栏占位 -->
    <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>

    <!-- 页面标题区 -->
    <view class="header">
      <text class="title">我的设备</text>
    </view>

    <!-- 设备列表 -->
    <scroll-view class="device-list" scroll-y @touchstart="handleTouchStart" @touchend="handleTouchEnd">
      <view class="device-item" v-for="device in devices" :key="device.id"
            @tap="openDevice(device)"
            @longpress="showDeviceMenu(device)">
        <view class="device-status" :class="device.status"></view>
        <view class="device-icon">
          <text class="icon-symbol">{{ device.type === 'servo' ? '🔘' : '🔌' }}</text>
        </view>
        <view class="device-info">
          <text class="device-name">{{ device.name }}</text>
          <text class="device-status-text" :style="{ color: getStatusColor(device.status) }">
            {{ getStatusText(device.status) }}
          </text>
        </view>
        <text class="arrow">›</text>
      </view>

      <view v-if="devices.length === 0" class="empty-state">
        <text class="empty-icon">📱</text>
        <text class="empty-text">暂无设备</text>
        <text class="empty-hint">点击右下角添加设备</text>
      </view>
    </scroll-view>

    <!-- 悬浮添加按钮 -->
    <view class="fab" @click="goToScan">
      <text class="fab-icon">+</text>
    </view>

    <!-- 设备操作弹窗 -->
    <view class="modal-overlay" v-if="showModal" @tap="closeModal">
      <view class="modal-content" @tap.stop>
        <view class="modal-item" @tap="editDeviceName">
          <text class="modal-icon">✏️</text>
          <text class="modal-label">修改名称</text>
        </view>
        <view class="modal-item delete" @tap="confirmDelete">
          <text class="modal-icon">🗑️</text>
          <text class="modal-label">删除设备</text>
        </view>
        <view class="modal-cancel" @tap="closeModal">
          <text>取消</text>
        </view>
      </view>
    </view>

    <!-- 设备名称编辑弹窗 -->
    <view class="modal-overlay" v-if="showEditModal" @tap="closeEditModal">
      <view class="edit-modal-content" @tap.stop>
        <text class="edit-title">修改设备名称</text>
        <input class="edit-input" v-model="editName" placeholder="请输入设备名称" />
        <view class="edit-actions">
          <button class="edit-btn cancel" @tap="closeEditModal">取消</button>
          <button class="edit-btn confirm" @tap="saveDeviceName">确定</button>
        </view>
      </view>
    </view>

    <!-- 删除确认弹窗 -->
    <view class="modal-overlay" v-if="showDeleteModal" @tap="closeDeleteModal">
      <view class="delete-modal-content" @tap.stop>
        <text class="delete-title">删除设备</text>
        <text class="delete-message">确定要删除「{{ currentDevice?.name }}」吗？</text>
        <view class="delete-actions">
          <button class="delete-btn cancel" @tap="closeDeleteModal">取消</button>
          <button class="delete-btn confirm" @tap="doDelete">删除</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { MockData, DeviceType, DeviceStatus } from '@/utils/mock-data.js';

export default {
  name: 'DeviceList',
  data() {
    return {
      statusBarHeight: 0,
      devices: [],
      showModal: false,
      showEditModal: false,
      showDeleteModal: false,
      currentDevice: null,
      editName: '',
      longPressTimer: null,
      isLongPress: false
    };
  },
  onReady() {
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
    this.loadDevices();
  },
  onShow() {
    this.loadDevices();
  },
  methods: {
    loadDevices() {
      this.devices = MockData.getDevices();
    },

    getStatusText(status) {
      const map = {
        [DeviceStatus.ONLINE]: '在线',
        [DeviceStatus.OFFLINE]: '离线',
        [DeviceStatus.CONFIGURING]: '配置中'
      };
      return map[status] || '未知';
    },

    getStatusColor(status) {
      const map = {
        [DeviceStatus.ONLINE]: '#34C759',
        [DeviceStatus.OFFLINE]: '#8E8E93',
        [DeviceStatus.CONFIGURING]: '#FF9500'
      };
      return map[status] || '#8E8E93';
    },

    handleTouchStart() {
      this.isLongPress = false;
      this.longPressTimer = setTimeout(() => {
        this.isLongPress = true;
      }, 500);
    },

    handleTouchEnd() {
      if (this.longPressTimer) {
        clearTimeout(this.longPressTimer);
      }
    },

    openDevice(device) {
      if (this.isLongPress) return;
      uni.navigateTo({
        url: `/pages/device-control/device-control?deviceId=${device.id}`
      });
    },

    showDeviceMenu(device) {
      this.currentDevice = device;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.currentDevice = null;
    },

    editDeviceName() {
      this.editName = this.currentDevice.name;
      this.showModal = false;
      this.showEditModal = true;
    },

    closeEditModal() {
      this.showEditModal = false;
      this.editName = '';
    },

    saveDeviceName() {
      if (!this.editName.trim()) {
        uni.showToast({ title: '请输入设备名称', icon: 'none' });
        return;
      }
      MockData.updateDevice(this.currentDevice.id, { name: this.editName });
      this.loadDevices();
      this.closeEditModal();
      uni.showToast({ title: '设备名称已修改', icon: 'success' });
    },

    confirmDelete() {
      this.showModal = false;
      this.showDeleteModal = true;
    },

    closeDeleteModal() {
      this.showDeleteModal = false;
    },

    doDelete() {
      MockData.removeDevice(this.currentDevice.id);
      this.loadDevices();
      this.closeDeleteModal();
      uni.showToast({ title: '设备已删除', icon: 'success' });
    },

    goToScan() {
      uni.navigateTo({
        url: '/pages/scan/scan'
      });
    }
  }
};
</script>

<style scoped>
.device-list-container {
  min-height: 100vh;
  background: #F5F5F7;
}

.status-bar {
  width: 100%;
  background: #FFFFFF;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 32rpx;
  background: #FFFFFF;
  border-bottom: 1rpx solid #E5E5EA;
}

.title {
  font-size: 40rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.device-list {
  height: calc(100vh - var(--status-bar-height) - 100rpx - 100rpx);
  padding: 16rpx;
}

.device-item {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  margin-bottom: 16rpx;
}

.device-status {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: 24rpx;
}

.device-status.online {
  background: #34C759;
}

.device-status.offline {
  background: #8E8E93;
}

.device-status.configuring {
  background: #FF9500;
}

.device-icon {
  width: 80rpx;
  height: 80rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
}

.icon-symbol {
  font-size: 40rpx;
}

.device-info {
  flex: 1;
}

.device-name {
  font-size: 32rpx;
  font-weight: 500;
  color: #3A3A3C;
}

.device-status-text {
  font-size: 28rpx;
  margin-top: 8rpx;
}

.arrow {
  font-size: 40rpx;
  color: #C7C7CC;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 200rpx 0;
}

.empty-icon {
  font-size: 128rpx;
  margin-bottom: 32rpx;
  opacity: 0.5;
}

.empty-text {
  font-size: 32rpx;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.empty-hint {
  font-size: 28rpx;
  color: #8E8E93;
}

.fab {
  position: fixed;
  right: 32rpx;
  bottom: 180rpx;
  width: 112rpx;
  height: 112rpx;
  background: #007AFF;
  border-radius: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(0, 122, 255, 0.4);
  z-index: 100;
}

.fab-icon {
  font-size: 56rpx;
  color: #FFFFFF;
  font-weight: 300;
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  z-index: 1000;
}

.modal-content {
  width: 100%;
  background: #FFFFFF;
  border-radius: 32rpx 32rpx 0 0;
  padding: 16rpx 0 32rpx;
}

.modal-item {
  display: flex;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid #E5E5EA;
}

.modal-item.delete .modal-label {
  color: #FF3B30;
}

.modal-icon {
  font-size: 48rpx;
  margin-right: 24rpx;
}

.modal-label {
  font-size: 32rpx;
  color: #3A3A3C;
}

.modal-cancel {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32rpx;
  font-size: 32rpx;
  color: #007AFF;
  border-top: 16rpx solid #F5F5F7;
}

/* 编辑弹窗 */
.edit-modal-content {
  width: calc(100% - 64rpx);
  margin: 0 32rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  padding: 32rpx;
}

.edit-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 24rpx;
}

.edit-input {
  width: 100%;
  height: 88rpx;
  padding: 0 24rpx;
  background: #F5F5F7;
  border-radius: 16rpx;
  font-size: 32rpx;
  margin-bottom: 32rpx;
}

.edit-actions {
  display: flex;
  gap: 16rpx;
}

.edit-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 16rpx;
  font-size: 32rpx;
}

.edit-btn.cancel {
  background: #F5F5F7;
  color: #3A3A3C;
}

.edit-btn.confirm {
  background: #007AFF;
  color: #FFFFFF;
}

/* 删除确认弹窗 */
.delete-modal-content {
  width: calc(100% - 64rpx);
  margin: 0 32rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  padding: 32rpx;
}

.delete-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.delete-message {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 32rpx;
}

.delete-actions {
  display: flex;
  gap: 16rpx;
}

.delete-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 16rpx;
  font-size: 32rpx;
}

.delete-btn.cancel {
  background: #F5F5F7;
  color: #3A3A3C;
}

.delete-btn.confirm {
  background: #FF3B30;
  color: #FFFFFF;
}
</style>
