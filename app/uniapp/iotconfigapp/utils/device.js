/**
 * 设备 API 服务
 * 作者: 罗耀生
 * 日期: 2026-01-15
 */

import http from './http.js'

class DeviceApi {
  /**
   * 获取设备列表
   * @param {object} options 查询参数
   */
  async getDeviceList(options = {}) {
    try {
      const { productKey, status, page = 1, size = 20 } = options

      const params = { page, size }
      if (productKey) params.productKey = productKey
      if (status !== undefined) params.status = status

      const result = await http.get('/devices', params)

      // 转换设备列表格式
      const list = (result.data?.list || []).map(this._transformDevice)

      return {
        success: true,
        data: {
          list: list,
          total: result.data?.total || 0,
          page: result.data?.page || 1,
          size: result.data?.size || 20
        }
      }
    } catch (error) {
      return { success: false, message: error.message || '获取设备列表失败' }
    }
  }

  /**
   * 获取设备详情
   */
  async getDevice(deviceId) {
    try {
      const result = await http.get(`/devices/${deviceId}`)
      const device = this._transformDevice(result.data)
      return { success: true, data: device }
    } catch (error) {
      return { success: false, message: error.message || '获取设备详情失败' }
    }
  }

  /**
   * 获取设备状态
   */
  async getDeviceStatus(deviceId) {
    try {
      const result = await http.get(`/devices/${deviceId}/status`)
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '获取设备状态失败' }
    }
  }

  /**
   * 控制设备 - 位置切换
   */
  async togglePosition(deviceId, position) {
    try {
      const result = await http.post(`/devices/${deviceId}/control`, {
        action: 'toggle',
        position: position
      })
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '控制设备失败' }
    }
  }

  /**
   * 控制设备 - 脉冲触发
   */
  async triggerPulse(deviceId, duration = 500) {
    try {
      const result = await http.post(`/devices/${deviceId}/control`, {
        action: 'pulse',
        duration: duration
      })
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '控制设备失败' }
    }
  }

  /**
   * 控制设备 - 唤醒
   */
  async triggerWakeup(deviceId) {
    try {
      const result = await http.post(`/devices/${deviceId}/control`, {
        action: 'trigger'
      })
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '控制设备失败' }
    }
  }

  /**
   * 删除设备
   */
  async deleteDevice(deviceId) {
    try {
      const result = await http.delete(`/devices/${deviceId}`)
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '删除设备失败' }
    }
  }

  /**
   * 设备激活（配网后调用）
   */
  async activateDevice(productKey, deviceSN, options = {}) {
    try {
      const { firmwareVersion, chipModel } = options

      const data = {
        productKey: productKey,
        deviceSN: deviceSN
      }
      if (firmwareVersion) data.firmwareVersion = firmwareVersion
      if (chipModel) data.chipModel = chipModel

      const result = await http.post('/devices/activate', data)
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '设备激活失败' }
    }
  }

  /**
   * 转换设备数据格式
   * @private
   */
  _transformDevice(item) {
    if (!item) return null

    // 状态映射
    const statusMap = {
      0: 'not_activated',
      1: 'online',
      2: 'offline',
      3: 'disabled'
    }

    // 判断是否在线
    const statusCode = item.status !== undefined ? item.status : 2
    const isOnline = statusCode === 1 || item.status === 'online'

    // 判断设备类型
    const productKey = item.productKey || ''
    const uiTemplate = item.product?.uiTemplate || ''
    const isWakeup = productKey.includes('wakeup') || uiTemplate === 'wakeup'

    return {
      id: item.deviceId || item.id || '',
      deviceId: item.deviceId || item.id || '',
      deviceSn: item.deviceSN || item.deviceSn,
      productKey: item.productKey,
      name: (item.name || '').trim() || '未知设备',
      type: isWakeup ? 'wakeup' : 'servo',
      status: isOnline ? 'online' : 'offline',
      firmware: item.firmwareVersion || item.firmware || 'v1.0.0',
      model: item.product?.model || item.chipModel,
      location: item.location || null,
      lastSeen: item.lastOnlineAt ? new Date(item.lastOnlineAt).getTime() : null,
      product: item.product
    }
  }

  /**
   * 获取设备状态文本
   */
  getStatusText(device) {
    if (!device) return '未知'

    if (device.status === 'offline' && device.lastSeen) {
      const diff = Date.now() - device.lastSeen
      const hours = Math.floor(diff / (1000 * 60 * 60))

      if (hours > 0) {
        return `离线 ${hours}小时前`
      }

      const minutes = Math.floor(diff / (1000 * 60))
      if (minutes > 0) {
        return `离线 ${minutes}分钟前`
      }

      return '离线 刚刚'
    }

    const statusMap = {
      'online': '在线',
      'offline': '离线',
      'configuring': '配置中',
      'not_activated': '未激活',
      'disabled': '禁用'
    }

    return statusMap[device.status] || '未知'
  }
}

export default new DeviceApi()
