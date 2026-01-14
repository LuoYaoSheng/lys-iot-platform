<!-- 设备列表页（TabBar主页） -->
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
      <AppCard
        v-for="device in devices"
        :key="device.id"
        :clickable="true"
        @click="openDevice(device)"
        @longpress="showDeviceMenu(device)"
      >
        <view class="device-card">
          <view class="device-card-header">
            <view class="status-dot" :class="device.status"></view>
            <text class="device-card-name">{{ device.name }}</text>
            <text class="device-card-status" :style="{ color: getStatusColor(device.status) }">
              {{ MockData.getStatusText(device) }}
            </text>
            <view class="more-icon">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="2" fill="currentColor"/>
                <path d="M3 10H8M12 10H17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </view>
          </view>
          <view class="device-card-footer">
            <text>位置: {{ device.location }}</text>
            <text>固件: {{ device.firmware }}</text>
          </view>
        </view>
      </AppCard>

      <AppEmpty v-if="devices.length === 0" message="暂无设备" actionText="添加设备" @action="goToScan" />

      <view class="tip-text">
        长按设备卡片可删除
      </view>
    </scroll-view>

    <!-- 悬浮添加按钮 -->
    <view class="fab" @click="goToScan">
      <AppIcon name="add" :size="56" color="#FFFFFF" />
    </view>

    <!-- 设备操作弹窗 -->
    <view class="modal-overlay" v-if="showModal" @tap="closeModal">
      <view class="modal-content" @tap.stop>
        <view class="modal-item" @tap="editDeviceName">
          <AppIcon name="edit" :size="48" color="#3A3A3C" />
          <text class="modal-label">修改名称</text>
        </view>
        <view class="modal-item delete" @tap="confirmDelete">
          <AppIcon name="delete" :size="48" color="#FF3B30" />
          <text class="modal-label">删除设备</text>
        </view>
        <view class="modal-cancel" @tap="closeModal">
          <text>取消</text>
        </view>
      </view>
    </view>

    <!-- 编辑设备名称弹窗 -->
    <view class="modal-overlay" v-if="showEditModal" @tap="closeEditModal">
      <view class="edit-modal-content" @tap.stop>
        <text class="modal-title">修改设备名称</text>
        <input class="modal-input" v-model="editName" placeholder="请输入设备名称" />
        <view class="modal-actions">
          <button class="modal-btn cancel" @tap="closeEditModal">取消</button>
          <button class="modal-btn confirm" @tap="saveDeviceName">保存</button>
        </view>
      </view>
    </view>

    <!-- 删除确认弹窗 -->
    <view class="modal-overlay" v-if="showDeleteModal" @tap="closeDeleteModal">
      <view class="edit-modal-content" @tap.stop>
        <text class="modal-title">删除设备</text>
        <text class="modal-message">确定要删除「{{ currentDevice?.name }}」吗？</text>
        <view class="modal-actions">
          <button class="modal-btn cancel" @tap="closeDeleteModal">取消</button>
          <button class="modal-btn danger" @tap="doDelete">删除</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { MockData, DeviceType, DeviceStatus } from '@/utils/mock-data.js';
import AppIcon from '@/components/AppIcon.vue';
import AppCard from '@/components/AppCard.vue';
import AppEmpty from '@/components/AppEmpty.vue';

export default {
  name: 'DeviceList',
  components: {
    AppIcon,
    AppCard,
    AppEmpty
  },
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

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.device-list-container {
  min-height: 100vh;
  background: $color-bg-gray;
  padding-bottom: env(safe-area-inset-bottom);
}

.status-bar {
  width: 100%;
  background: $color-bg-primary;
}

.header {
  display: flex;
  align-items: center;
  padding: $spacing-md $spacing-lg;
  background: $color-bg-primary;
  border-bottom: 1px solid $color-border-primary;
}

.title {
  font-size: $font-size-xl;
  font-weight: $font-weight-semibold;
  color: $color-text-primary;
}

.device-list {
  height: calc(100vh - var(--status-bar-height) - 100rpx - 50rpx);
  padding: $spacing-md;
}

.device-card {
  padding: 0;
}

.device-card-header {
  display: flex;
  align-items: center;
  padding: $spacing-md;
  border-bottom: 1px solid $color-border-primary;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  margin-right: $spacing-md;
  flex-shrink: 0;

  &.online {
    background: $color-success;
  }

  &.offline {
    background: $color-text-tertiary;
  }

  &.configuring {
    background: $color-warning;
  }
}

.device-card-name {
  flex: 1;
  font-size: $font-size-md;
  font-weight: $font-weight-medium;
  color: $color-text-primary;
}

.device-card-status {
  font-size: $font-size-sm;
  margin-right: $spacing-sm;
}

.more-icon {
  width: 40rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  color: $color-text-tertiary;
}

.device-card-footer {
  display: flex;
  justify-content: space-between;
  padding: $spacing-sm $spacing-md;
  background: $color-bg-secondary;
  font-size: $font-size-sm;
  color: $color-text-secondary;
}

.tip-text {
  text-align: center;
  font-size: $font-size-sm;
  color: $color-text-secondary;
  padding: $spacing-md;
}

.fab {
  position: fixed;
  right: $spacing-lg;
  bottom: calc(100rpx + env(safe-area-inset-bottom) + $spacing-lg);
  width: 112rpx;
  height: 112rpx;
  background: $color-primary;
  border-radius: $radius-xl;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: $shadow-lg;
  z-index: $z-index-floating;
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
  z-index: $z-index-modal;
}

.modal-content {
  width: 100%;
  background: $color-bg-primary;
  border-radius: $radius-xxl $radius-xxl 0 0;
  padding: $spacing-sm 0 $spacing-lg;
}

.modal-item {
  display: flex;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1px solid $color-border-primary;

  &.delete .modal-label {
    color: $color-error;
  }
}

.modal-label {
  font-size: $font-size-md;
  color: $color-text-primary;
  margin-left: $spacing-md;
}

.modal-cancel {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-lg;
  font-size: $font-size-md;
  color: $color-primary;
  border-top: 16rpx solid $color-bg-gray;
}

/* 编辑弹窗样式 */
.edit-modal-content {
  width: 600rpx;
  background: $color-bg-primary;
  border-radius: $radius-xxl;
  padding: $spacing-xl;
  margin-bottom: 15vh;
  align-self: center;
}

.modal-title {
  font-size: $font-size-lg;
  font-weight: $font-weight-semibold;
  color: $color-text-primary;
  display: block;
  text-align: center;
  margin-bottom: $spacing-lg;
}

.modal-message {
  font-size: $font-size-md;
  color: $color-text-secondary;
  display: block;
  text-align: center;
  margin-bottom: $spacing-lg;
}

.modal-input {
  width: 100%;
  padding: $spacing-md;
  background: $color-bg-secondary;
  border-radius: $radius-md;
  font-size: $font-size-md;
  color: $color-text-primary;
  margin-bottom: $spacing-lg;
}

.modal-actions {
  display: flex;
  gap: $spacing-md;
}

.modal-btn {
  flex: 1;
  padding: $spacing-md;
  border-radius: $radius-md;
  font-size: $font-size-md;
  border: none;

  &.cancel {
    background: $color-bg-secondary;
    color: $color-text-secondary;
  }

  &.confirm {
    background: $color-primary;
    color: #FFFFFF;
  }

  &.danger {
    background: $color-error;
    color: #FFFFFF;
  }
}
</style>
