<!-- 设备信息卡片组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 显示设备详细信息的卡片 -->

<template>
  <view class="device-info-card">
    <view
      v-for="(item, index) in normalizedItems"
      :key="index"
      class="info-row"
      :class="{ 'no-border': index === normalizedItems.length - 1 }"
    >
      <text class="info-label">{{ item.label }}</text>
      <text class="info-value">{{ item.value }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppDeviceInfoCard',
  props: {
    // 信息项数组
    // 格式1: [{ label: '设备名称', value: '客厅开关' }, ...]
    // 格式2: { deviceName: '客厅开关', deviceId: 'xxx', ... } (需配置 fieldLabels)
    items: {
      type: [Array, Object],
      default: () => []
    },
    // 字段标签映射（当 items 为对象时使用）
    fieldLabels: {
      type: Object,
      default: () => ({
        name: '设备名称',
        id: '设备 ID',
        deviceId: '设备 ID',
        type: '产品类型',
        productType: '产品类型',
        firmware: '固件版本',
        location: '位置',
        model: '型号'
      })
    }
  },
  computed: {
    normalizedItems() {
      if (Array.isArray(this.items)) {
        return this.items;
      }
      // 对象格式转为数组
      return Object.entries(this.items).map(([key, value]) => ({
        label: this.fieldLabels[key] || key,
        value: value || '-'
      }));
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.device-info-card {
  background: #FFFFFF;
  border-radius: $radius-lg;
  overflow: hidden;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-md $spacing-lg;
  border-bottom: 1px solid $color-border-primary;

  &.no-border {
    border-bottom: none;
  }
}

.info-label {
  font-size: $font-size-sm;
  color: $color-text-secondary;
  flex-shrink: 0;
}

.info-value {
  font-size: $font-size-sm;
  color: $color-text-primary;
  margin-left: $spacing-md;
  text-align: right;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
