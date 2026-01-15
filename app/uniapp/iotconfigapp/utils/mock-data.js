/**
 * 模拟数据存储
 * 作者: 罗耀生
 * 日期: 2026-01-14
 */

// 设备类型
export const DeviceType = {
  servo: 'servo',
  wakeup: 'wakeup'
};

// 设备状态
export const DeviceStatus = {
  ONLINE: 'online',
  OFFLINE: 'offline',
  CONFIGURING: 'configuring'
};

// 初始模拟设备
const mockDevices = [
  {
    id: 'device_001',
    name: '客厅开关',
    type: DeviceType.servo,
    status: DeviceStatus.ONLINE,
    firmware: '1.0.0',
    location: '上',
    model: 'SERVO-SWITCH',
    lastSeen: Date.now()
  },
  {
    id: 'device_002',
    name: '电脑唤醒',
    type: DeviceType.wakeup,
    status: DeviceStatus.ONLINE,
    firmware: '1.0.0',
    location: null,
    model: 'USB-WAKEUP-S3',
    lastSeen: Date.now()
  },
  {
    id: 'device_003',
    name: '卧室开关',
    type: DeviceType.servo,
    status: DeviceStatus.OFFLINE,
    firmware: '1.0.0',
    location: '下',
    model: 'SERVO-SWITCH',
    lastSeen: Date.now() - 2 * 60 * 60 * 1000 // 2小时前
  }
];

class MockData {
  static getDevices() {
    return mockDevices;
  }

  static addDevice(device) {
    mockDevices.push(device);
  }

  static removeDevice(id) {
    const index = mockDevices.findIndex(d => d.id === id);
    if (index > -1) {
      mockDevices.splice(index, 1);
    }
  }

  static updateDevice(id, data) {
    const device = mockDevices.find(d => d.id === id);
    if (device) {
      Object.assign(device, data);
    }
  }

  static getDevice(id) {
    return mockDevices.find(d => d.id === id);
  }

  static getStatusText(device) {
    if (device.status === DeviceStatus.OFFLINE) {
      const hours = Math.floor((Date.now() - device.lastSeen) / (1000 * 60 * 60));
      if (hours > 0) {
        return `离线 ${hours}小时前`;
      }
      return '离线';
    }
    const map = {
      [DeviceStatus.ONLINE]: '在线',
      [DeviceStatus.OFFLINE]: '离线',
      [DeviceStatus.CONFIGURING]: '配置中'
    };
    return map[device.status] || '未知';
  }
}

export { MockData };
