<!-- 设备控制页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="control-container">
    <!-- 状态栏占位 -->
    <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>

    <view class="header">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">{{ device?.name || '设备控制' }}</text>
      <view class="more-btn" @click="showMenu">
        <text class="more-icon">⋮</text>
      </view>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- 状态卡片 -->
      <view class="status-card">
        <view class="status-dot" :class="device?.status || 'offline'"></view>
        <text class="status-text" :style="{ color: getStatusColor(device?.status) }">
          {{ getStatusText(device?.status) }}
        </text>
        <text class="firmware-text">固件: {{ device?.firmware || '未知' }}</text>
      </view>

      <!-- 控制面板 -->
      <view v-if="device?.type === 'servo'" class="control-panel">
        <text class="panel-title">舵机控制</text>
        <view class="position-indicator">
          <view class="position-marker" :class="servoPosition"></view>
        </view>
        <view class="position-buttons">
          <view class="pos-btn" :class="{ active: servoPosition === 'up' }" @tap="setPosition('up')">
            <text>上</text>
          </view>
          <view class="pos-btn" :class="{ active: servoPosition === 'middle' }" @tap="setPosition('middle')">
            <text>中</text>
          </view>
          <view class="pos-btn" :class="{ active: servoPosition === 'down' }" @tap="setPosition('down')">
            <text>下</text>
          </view>
        </view>
        <view class="pulse-btn" @tap="triggerPulse">
          <text class="pulse-icon">⚡</text>
          <text>脉冲触发</text>
        </view>
      </view>

      <view v-else class="control-panel wakeup">
        <text class="panel-title">USB唤醒控制</text>
        <view class="wakeup-area" @tap="triggerWakeup">
          <text class="wakeup-icon">⏻</text>
          <text class="wakeup-label">点击唤醒</text>
          <text class="wakeup-hint">电脑将立即启动</text>
        </view>
        <view class="schedule-btn" @tap="setSchedule">
          <text class="schedule-icon">📅</text>
          <text>定时唤醒</text>
        </view>
      </view>
    </scroll-view>

    <!-- 操作菜单 -->
    <view class="modal-overlay" v-if="showMenuModal" @tap="closeMenu">
      <view class="menu-content" @tap.stop>
        <view class="menu-item" @tap="editName">
          <text class="menu-icon">✏️</text>
          <text class="menu-label">修改名称</text>
        </view>
        <view class="menu-item delete" @tap="confirmDelete">
          <text class="menu-icon">🗑️</text>
          <text class="menu-label">删除设备</text>
        </view>
        <view class="menu-cancel" @tap="closeMenu">
          <text>取消</text>
        </view>
      </view>
    </view>

    <!-- 编辑名称弹窗 -->
    <view class="modal-overlay" v-if="showEditModal" @tap="closeEditModal">
      <view class="edit-modal-content" @tap.stop>
        <text class="edit-title">修改设备名称</text>
        <input class="edit-input" v-model="editName" placeholder="请输入设备名称" />
        <view class="edit-actions">
          <button class="edit-btn cancel" @tap="closeEditModal">取消</button>
          <button class="edit-btn confirm" @tap="saveName">确定</button>
        </view>
      </view>
    </view>

    <!-- 删除确认弹窗 -->
    <view class="modal-overlay" v-if="showDeleteModal" @tap="closeDeleteModal">
      <view class="delete-modal-content" @tap.stop>
        <text class="delete-title">删除设备</text>
        <text class="delete-message">确定要删除「{{ device?.name }}」吗？</text>
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
  name: 'DeviceControl',
  data() {
    return {
      statusBarHeight: 0,
      deviceId: '',
      device: null,
      servoPosition: 'middle',
      showMenuModal: false,
      showEditModal: false,
      showDeleteModal: false,
      editName: ''
    };
  },
  onReady() {
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
  },
  onLoad(options) {
    if (options.deviceId) {
      this.deviceId = options.deviceId;
      this.loadDevice();
    }
  },
  methods: {
    loadDevice() {
      this.device = MockData.getDevice(this.deviceId);
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

    setPosition(pos) {
      this.servoPosition = pos;
    },

    triggerPulse() {
      uni.showToast({
        title: '脉冲触发成功',
        icon: 'success'
      });
    },

    triggerWakeup() {
      uni.showToast({
        title: '唤醒信号已发送',
        icon: 'success'
      });
    },

    setSchedule() {
      uni.showToast({
        title: '定时唤醒设置',
        icon: 'none'
      });
    },

    showMenu() {
      this.showMenuModal = true;
    },

    closeMenu() {
      this.showMenuModal = false;
    },

    editName() {
      this.editName = this.device.name;
      this.showMenuModal = false;
      this.showEditModal = true;
    },

    closeEditModal() {
      this.showEditModal = false;
      this.editName = '';
    },

    saveName() {
      if (!this.editName.trim()) {
        uni.showToast({ title: '请输入设备名称', icon: 'none' });
        return;
      }
      MockData.updateDevice(this.deviceId, { name: this.editName });
      this.loadDevice();
      this.closeEditModal();
      uni.showToast({ title: '设备名称已修改', icon: 'success' });
    },

    confirmDelete() {
      this.showMenuModal = false;
      this.showDeleteModal = true;
    },

    closeDeleteModal() {
      this.showDeleteModal = false;
    },

    doDelete() {
      MockData.removeDevice(this.deviceId);
      this.closeDeleteModal();
      uni.showToast({ title: '设备已删除', icon: 'success' });
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
.control-container {
  min-height: 100vh;
  background: #FFFFFF;
}

.status-bar {
  width: 100%;
  background: #FFFFFF;
}

.header {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #FFFFFF;
  border-bottom: 1rpx solid #E5E5EA;
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
  flex: 1;
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.more-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.more-icon {
  font-size: 32rpx;
  color: #3A3A3C;
}

.content {
  padding: 32rpx;
}

.status-card {
  display: flex;
  align-items: center;
  padding: 24rpx 32rpx;
  background: #F5F5F7;
  border-radius: 24rpx;
  margin-bottom: 32rpx;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: 16rpx;
}

.status-dot.online {
  background: #34C759;
}

.status-dot.offline {
  background: #8E8E93;
}

.status-dot.configuring {
  background: #FF9500;
}

.status-text {
  flex: 1;
  font-size: 32rpx;
  font-weight: 500;
}

.firmware-text {
  font-size: 28rpx;
  color: #8E8E93;
}

/* 控制面板 */
.control-panel {
  padding: 32rpx;
  background: #F5F5F7;
  border-radius: 24rpx;
}

.panel-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 32rpx;
}

.position-indicator {
  height: 120rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  margin-bottom: 32rpx;
  position: relative;
  display: flex;
  align-items: center;
  padding: 0 24rpx;
}

.position-marker {
  width: 80rpx;
  height: 80rpx;
  background: #007AFF;
  border-radius: 50%;
  position: absolute;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: left 0.3s;
}

.position-marker::after {
  content: '▲';
  color: #FFFFFF;
  font-size: 32rpx;
}

.position-marker.up {
  left: 24rpx;
}

.position-marker.middle {
  left: 50%;
  transform: translateX(-50%);
}

.position-marker.down {
  right: 24rpx;
  left: auto;
  transform: none;
}

.position-buttons {
  display: flex;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.pos-btn {
  flex: 1;
  height: 112rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
  color: #3A3A3C;
}

.pos-btn.active {
  background: #007AFF;
  color: #FFFFFF;
}

.pulse-btn {
  height: 96rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  color: #007AFF;
  gap: 16rpx;
}

/* USB唤醒面板 */
.wakeup-area {
  height: 400rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
}

.wakeup-icon {
  font-size: 128rpx;
  margin-bottom: 16rpx;
}

.wakeup-label {
  font-size: 36rpx;
  color: #3A3A3C;
  margin-bottom: 8rpx;
}

.wakeup-hint {
  font-size: 28rpx;
  color: #8E8E93;
}

.schedule-btn {
  height: 96rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  color: #007AFF;
  gap: 16rpx;
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

.menu-content {
  width: 100%;
  background: #FFFFFF;
  border-radius: 32rpx 32rpx 0 0;
  padding: 16rpx 0 32rpx;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid #E5E5EA;
}

.menu-item.delete .menu-label {
  color: #FF3B30;
}

.menu-icon {
  font-size: 48rpx;
  margin-right: 24rpx;
}

.menu-label {
  font-size: 32rpx;
  color: #3A3A3C;
}

.menu-cancel {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32rpx;
  font-size: 32rpx;
  color: #007AFF;
  border-top: 16rpx solid #F5F5F7;
}

.edit-modal-content,
.delete-modal-content {
  width: calc(100% - 64rpx);
  margin: 0 32rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  padding: 32rpx;
}

.edit-title,
.delete-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
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

.delete-message {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 32rpx;
}

.edit-actions,
.delete-actions {
  display: flex;
  gap: 16rpx;
}

.edit-btn,
.delete-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 16rpx;
  font-size: 32rpx;
}

.edit-btn.cancel,
.delete-btn.cancel {
  background: #F5F5F7;
  color: #3A3A3C;
}

.edit-btn.confirm,
.delete-btn.confirm {
  background: #007AFF;
  color: #FFFFFF;
}

.delete-btn.confirm {
  background: #FF3B30;
}
</style>
