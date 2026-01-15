/**
 * HTTP 请求工具
 * 作者: 罗耀生
 * 日期: 2026-01-15
 */

// 默认配置
const DEFAULT_BASE_URL = 'http://117.50.216.173:48080'
const API_PATH = '/api/v1'
const TIMEOUT = 30000

class HttpClient {
  constructor() {
    this.baseUrl = DEFAULT_BASE_URL
    this.token = null
    this.init()
  }

  // 初始化 - 从本地读取配置
  init() {
    try {
      this.token = uni.getStorageSync('auth_token')
      this.baseUrl = uni.getStorageSync('api_url') || DEFAULT_BASE_URL
      console.log('[HttpClient] init, baseUrl:', this.baseUrl, 'hasToken:', !!this.token)
    } catch (e) {
      console.warn('[HttpClient] init error:', e)
    }
  }

  // 设置服务器地址
  setBaseUrl(url) {
    this.baseUrl = url
    uni.setStorageSync('api_url', url)
    console.log('[HttpClient] baseUrl set to:', url)
  }

  // 设置认证 Token
  setToken(token) {
    this.token = token
    if (token) {
      uni.setStorageSync('auth_token', token)
    } else {
      uni.removeStorageSync('auth_token')
    }
    console.log('[HttpClient] token updated:', !!token)
  }

  // 清除认证信息
  clearAuth() {
    this.token = null
    uni.removeStorageSync('auth_token')
  }

  // 构建完整 URL
  _buildUrl(path) {
    const url = this.baseUrl + API_PATH + path
    console.log('[HttpClient] request URL:', url)
    return url
  }

  // 统一请求方法
  _request(options) {
    const { url, method = 'GET', data = null, params = null } = options

    // 构建查询参数
    let fullUrl = this._buildUrl(url)
    if (params) {
      const query = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
        .join('&')
      fullUrl += (fullUrl.includes('?') ? '&' : '?') + query
    }

    console.log('[HttpClient] request:', method, fullUrl, data ? JSON.stringify(data) : '')

    return new Promise((resolve, reject) => {
      uni.request({
        url: fullUrl,
        method: method.toUpperCase(),
        data: data,
        header: {
          'Content-Type': 'application/json',
          ...(this.token ? { 'Authorization': `Bearer ${this.token}` } : {})
        },
        timeout: TIMEOUT,
        success: (res) => {
          console.log('[HttpClient] response status:', res.statusCode)
          console.log('[HttpClient] response data:', res.data)

          // 401 处理 - Token 过期
          if (res.statusCode === 401) {
            this.clearAuth()
            // 跳转到登录页
            uni.reLaunch({ url: '/pages/login/login' })
            reject({ code: 401, message: '登录已过期' })
            return
          }

          // 获取响应数据
          const result = res.data

          // 判断是否成功
          const isSuccess = result && (result.code === 200 || result.code === 201)

          if (isSuccess) {
            console.log('[HttpClient] request success')
            resolve(result)
          } else {
            const errorMsg = result?.message || '请求失败'
            console.error('[HttpClient] request failed:', errorMsg, result)
            reject({
              code: result?.code || res.statusCode,
              message: errorMsg,
              data: result
            })
          }
        },
        fail: (err) => {
          console.error('[HttpClient] request fail:', err)
          console.error('[HttpClient] fail errMsg:', err.errMsg)
          console.error('[HttpClient] fail statusCode:', err.statusCode)

          let message = '网络请求失败'
          if (err.errMsg) {
            if (err.errMsg.includes('timeout') || err.errMsg.includes('超时')) {
              message = '请求超时，请检查网络'
            } else if (err.errMsg.includes('fail') || err.errMsg.includes('连接')) {
              message = '网络连接失败，请检查服务器地址'
            } else if (err.errMsg.includes('400')) {
              message = '无效请求 (400)'
            } else if (err.errMsg.includes('401')) {
              message = '未授权 (401)'
            } else if (err.errMsg.includes('404')) {
              message = '接口不存在 (404)'
            } else if (err.errMsg.includes('500')) {
              message = '服务器错误 (500)'
            } else {
              message = '请求失败: ' + err.errMsg
            }
          }

          reject({ code: err.statusCode || 0, message, error: err })
        }
      })
    })
  }

  // GET 请求
  get(url, params = null) {
    return this._request({ url, method: 'GET', params })
  }

  // POST 请求
  post(url, data = null) {
    return this._request({ url, method: 'POST', data })
  }

  // PUT 请求
  put(url, data = null) {
    return this._request({ url, method: 'PUT', data })
  }

  // DELETE 请求
  delete(url, data = null) {
    return this._request({ url, method: 'DELETE', data })
  }
}

// 单例导出
const http = new HttpClient()

export default http
