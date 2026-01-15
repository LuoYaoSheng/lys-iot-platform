/**
 * 认证 API 服务
 * 作者: 罗耀生
 * 日期: 2026-01-15
 */

import http from './http.js'

class AuthApi {
  /**
   * 用户登录
   * @param {string} email 邮箱
   * @param {string} password 密码
   */
  async login(email, password) {
    try {
      const result = await http.post('/users/login', {
        email: email,
        password: password
      })

      // 保存 token
      if (result.data && result.data.token) {
        http.setToken(result.data.token)
        // 保存用户信息
        if (result.data.user) {
          uni.setStorageSync('user_info', result.data.user)
        }
        if (result.data.refreshToken) {
          uni.setStorageSync('refresh_token', result.data.refreshToken)
        }
      }

      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '登录失败' }
    }
  }

  /**
   * 用户注册
   * @param {string} username 用户名
   * @param {string} email 邮箱
   * @param {string} password 密码
   * @param {string} name 昵称（可选）
   */
  async register(username, email, password, name) {
    try {
      const data = {
        username: username || email,
        email: email,
        password: password
      }
      if (name) {
        data.name = name
      }

      const result = await http.post('/users/register', data)

      // 如果返回了 token，自动登录
      if (result.data && result.data.token) {
        http.setToken(result.data.token)
        if (result.data.userId) {
          uni.setStorageSync('user_info', {
            userId: result.data.userId,
            username: result.data.username,
            email: result.data.email
          })
        }
      }

      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '注册失败' }
    }
  }

  /**
   * 刷新 Token
   */
  async refreshToken() {
    try {
      const refreshToken = uni.getStorageSync('refresh_token')
      if (!refreshToken) {
        return { success: false, message: '无刷新令牌' }
      }

      const result = await http.post('/users/refresh-token', {
        refreshToken: refreshToken
      })

      if (result.data && result.data.token) {
        http.setToken(result.data.token)
        if (result.data.refreshToken) {
          uni.setStorageSync('refresh_token', result.data.refreshToken)
        }
        return { success: true, data: result.data }
      }

      return { success: false, message: '刷新失败' }
    } catch (error) {
      return { success: false, message: error.message || '刷新失败' }
    }
  }

  /**
   * 获取当前用户信息
   */
  async getMe() {
    try {
      const result = await http.get('/users/me')
      if (result.data) {
        uni.setStorageSync('user_info', result.data)
      }
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '获取用户信息失败' }
    }
  }

  /**
   * 退出登录
   */
  async logout() {
    http.clearAuth()
    uni.removeStorageSync('user_info')
    uni.removeStorageSync('refresh_token')
  }

  /**
   * 请求密码重置
   */
  async requestPasswordReset(email) {
    try {
      const result = await http.post('/users/password/reset/request', { email })
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '请求失败' }
    }
  }

  /**
   * 确认密码重置
   */
  async resetPassword(token, newPassword) {
    try {
      const result = await http.post('/users/password/reset/confirm', {
        token: token,
        newPassword: newPassword
      })
      return { success: true, data: result.data }
    } catch (error) {
      return { success: false, message: error.message || '重置失败' }
    }
  }

  /**
   * 检查是否已登录
   */
  isLoggedIn() {
    const token = uni.getStorageSync('auth_token')
    return !!token
  }

  /**
   * 获取本地存储的用户信息
   */
  getUserInfo() {
    try {
      return uni.getStorageSync('user_info') || null
    } catch (e) {
      return null
    }
  }

  /**
   * 获取用户显示名称
   */
  getDisplayName() {
    const user = this.getUserInfo()
    if (user) {
      return user.name || user.username || user.email?.split('@')[0] || '用户'
    }
    return '用户'
  }
}

export default new AuthApi()
