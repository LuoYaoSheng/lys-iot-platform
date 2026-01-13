/**
 * 模拟数据存储
 * 作者: 罗耀生
 * 日期: 2026-01-13
 */

// 设备类型
const DeviceType = {
  SERVO: 'servo',
  WAKEUP: 'wakeup'
};

// 设备状态
const DeviceStatus = {
  ONLINE: 'online',
  OFFLINE: 'offline',
  CONFIGURING: 'configuring'
};

// 初始模拟设备
const mockDevices = [
  {
    id: 'device_001',
    name: '客厅开关',
    type: DeviceType.SERVO,
    status: DeviceStatus.ONLINE,
    firmware: '1.0.0'
  },
  {
    id: 'device_002',
    name: '电脑唤醒',
    type: DeviceType.WAKEUP,
    status: DeviceStatus.ONLINE,
    firmware: '1.0.0'
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
}

export { MockData, DeviceType, DeviceStatus };
