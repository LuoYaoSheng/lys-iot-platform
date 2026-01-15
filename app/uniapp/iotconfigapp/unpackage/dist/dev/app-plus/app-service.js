if (typeof Promise !== "undefined" && !Promise.prototype.finally) {
  Promise.prototype.finally = function(callback) {
    const promise = this.constructor;
    return this.then(
      (value) => promise.resolve(callback()).then(() => value),
      (reason) => promise.resolve(callback()).then(() => {
        throw reason;
      })
    );
  };
}
;
if (typeof uni !== "undefined" && uni && uni.requireGlobal) {
  const global = uni.requireGlobal();
  ArrayBuffer = global.ArrayBuffer;
  Int8Array = global.Int8Array;
  Uint8Array = global.Uint8Array;
  Uint8ClampedArray = global.Uint8ClampedArray;
  Int16Array = global.Int16Array;
  Uint16Array = global.Uint16Array;
  Int32Array = global.Int32Array;
  Uint32Array = global.Uint32Array;
  Float32Array = global.Float32Array;
  Float64Array = global.Float64Array;
  BigInt64Array = global.BigInt64Array;
  BigUint64Array = global.BigUint64Array;
}
;
if (uni.restoreGlobal) {
  uni.restoreGlobal(Vue, weex, plus, setTimeout, clearTimeout, setInterval, clearInterval);
}
(function(vue) {
  "use strict";
  const _export_sfc = (sfc, props) => {
    const target = sfc.__vccOpts || sfc;
    for (const [key, val] of props) {
      target[key] = val;
    }
    return target;
  };
  const ICONS = {
    // 底部导航
    home: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 9.5L12 2.5L21 9.5V20.5C21 21.0523 20.5523 21.5 20 21.5H4C3.44772 21.5 3 21.0523 3 20.5V9.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M9 21.5V12.5H15V21.5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    profile: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2"/></svg>',
    // 设备相关
    device: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 6C4 4.89543 4.89543 4 6 4H18C19.1046 4 20 4.89543 20 6V18C20 19.1046 19.1046 20 18 20H6C4.89543 20 4 19.1046 4 18V6Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M8 10H16M8 14H13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="16" cy="14" r="1.5" fill="currentColor"/></svg>',
    switch: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="8" width="20" height="8" rx="4" stroke="currentColor" stroke-width="2"/><circle cx="8" cy="12" r="2" fill="currentColor"/></svg>',
    servo: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="8" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="2" fill="currentColor"/><path d="M12 4V8M12 16V20M4 12H8M16 12H20" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    // 操作
    add: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 5V19M5 12H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    edit: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.5 4.5L19.5 8.5M14 6L8.5 11.5V14.5H11.5L17 9L14 6Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M4 20H12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    delete: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 6H20M16 6V5C16 3.89543 15.1046 3 14 3H10C8.89543 3 8 3.89543 8 5V6M6 6V19C6 20.1046 6.89543 21 8 21H16C17.1046 21 18 20.1046 18 19V6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M10 11V16M14 11V16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    close: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    copy: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="9" y="9" width="13" height="13" rx="2" stroke="currentColor" stroke-width="2"/><path d="M5 15H4C3.46957 15 2.96086 14.7893 2.58579 14.4142C2.21071 14.0391 2 13.5304 2 13V4C2 3.46957 2.21071 2.96086 2.58579 2.58579C2.96086 2.21071 3.46957 2 4 2H13C13.5304 2 14.0391 2.21071 14.4142 2.58579C14.7893 2.96086 15 3.46957 15 4V5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    // 导航
    arrowBack: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15 5L9 12L15 19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    arrowRight: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9 5L15 12L9 19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    // 设置
    settings: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2"/><path d="M12 3V5M12 19V21M21 12H19M5 12H3M18.4 18.4L17 17M7 7L5.6 5.6M18.4 5.6L17 7M7 17L5.6 18.4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    server: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="3" width="18" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/><rect x="3" y="14" width="18" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/><circle cx="7" cy="6.5" r="1" fill="currentColor"/><circle cx="7" cy="17.5" r="1" fill="currentColor"/></svg>',
    // 信息
    info: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/><path d="M12 16V12M12 8H12.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    // 网络和连接
    wifi: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 18C13.6569 18 15 16.6569 15 15C15 13.3431 13.6569 12 12 12C10.3431 12 9 13.3431 9 15C9 16.6569 10.3431 18 12 18Z" fill="currentColor"/><path d="M5.63623 10.636C8.31923 7.95301 12.5832 7.23201 16.0002 9.00001" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M2.63623 7.63601C6.94923 3.32301 13.8292 2.63601 19.0002 5.63601" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    bluetooth: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7 17L13 12L7 7V17Z" fill="currentColor"/><path d="M13 17L19 12L13 7V17Z" fill="currentColor"/><path d="M13 4V20" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    scan: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="3" width="7" height="7" rx="1" stroke="currentColor" stroke-width="2"/><rect x="14" y="3" width="7" height="7" rx="1" stroke="currentColor" stroke-width="2"/><rect x="3" y="14" width="7" height="7" rx="1" stroke="currentColor" stroke-width="2"/><rect x="14" y="14" width="7" height="7" rx="1" stroke="currentColor" stroke-width="2"/><path d="M12 7V17M7 12H17" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    chat: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M21 11.5C21.0034 12.8199 20.6951 14.1219 20.1 15.3C19.3944 16.7118 18.3098 17.8992 16.9674 18.7293C15.6251 19.5594 14.0782 19.9994 12.5 20C11.1801 20.0035 9.87812 19.6951 8.7 19.1L3 21L4.9 15.3C4.30493 14.1219 3.99656 12.8199 4 11.5C4.00061 9.92179 4.44061 8.37488 5.27072 7.03258C6.10083 5.69028 7.28825 4.6056 8.7 3.90003C9.87812 3.30496 11.1801 2.99659 12.5 3.00003H13C15.0843 3.11502 17.053 3.99479 18.5291 5.47089C20.0052 6.94699 20.885 8.91568 21 11V11.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    // 其他
    user: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="8" r="3" stroke="currentColor" stroke-width="2"/><path d="M5 21C5 16.5817 8.58172 13 13 13C17.4183 13 21 16.5817 21 21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    more: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="1.5" fill="currentColor"/><circle cx="19" cy="12" r="1.5" fill="currentColor"/><circle cx="5" cy="12" r="1.5" fill="currentColor"/></svg>',
    // 密码显隐
    eye: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2"/></svg>',
    eyeOff: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    // 状态图标
    bolt: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    check: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    warning: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><line x1="12" y1="9" x2="12" y2="13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="12" y1="17" x2="12.01" y2="17" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    error: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/><line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    // 导航箭头
    chevronRight: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9 18l6-6-6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    // 电源和设备
    power: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 3V12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M6.34 7.34C4.9 8.78 4 10.78 4 13C4 17.42 7.58 21 12 21C16.42 21 20 17.42 20 13C20 10.78 19.1 8.78 17.66 7.34" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    plug: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 22V15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M9 15H15V12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12V15Z" stroke="currentColor" stroke-width="2"/><path d="M10 9V5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M14 9V5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    // 用户相关
    person: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/><path d="M20 21C20 16.58 16.42 13 12 13C7.58 13 4 16.58 4 21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    // 其他操作
    refresh: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M23 4v6h-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M1 20v-6h6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    link: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    document: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M14 2v6h6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M16 13H8M16 17H8M10 9H8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    license: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 3L2 7l10 4 10-4-10-4z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M2 17l10 4 10-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M2 12l10 4 10-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    inbox: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M22 12h-6l-2 3h-4l-2-3H2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    menu: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="6" cy="12" r="1.5" fill="currentColor"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/><circle cx="18" cy="12" r="1.5" fill="currentColor"/></svg>',
    checkCircle: '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/><path d="M9 12l2 2 4-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  };
  const _sfc_main$c = {
    name: "AppIcon",
    props: {
      // 图标名称
      name: {
        type: String,
        required: true
      },
      // 图标尺寸 (rpx)
      size: {
        type: [String, Number],
        default: 48
      },
      // 图标颜色
      color: {
        type: String,
        default: "#3A3A3C"
      }
    },
    computed: {
      svgContent() {
        return ICONS[this.name] || ICONS.device;
      },
      sizePx() {
        return `${this.size}rpx`;
      }
    }
  };
  function _sfc_render$b(_ctx, _cache, $props, $setup, $data, $options) {
    return vue.openBlock(), vue.createElementBlock("view", {
      class: "app-icon",
      style: vue.normalizeStyle({ color: $props.color, width: $options.sizePx, height: $options.sizePx }),
      innerHTML: $options.svgContent
    }, null, 12, ["innerHTML"]);
  }
  const AppIcon = /* @__PURE__ */ _export_sfc(_sfc_main$c, [["render", _sfc_render$b], ["__scopeId", "data-v-7a8d850c"], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/components/AppIcon.vue"]]);
  const _sfc_main$b = {
    components: { AppIcon },
    onLoad() {
      setTimeout(() => {
        const token = uni.getStorageSync("token");
        if (token) {
          uni.switchTab({ url: "/pages/device-list/device-list" });
        } else {
          uni.redirectTo({ url: "/pages/login/login" });
        }
      }, 1500);
    }
  };
  function _sfc_render$a(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "splash" }, [
      vue.createElementVNode("view", { class: "content" }, [
        vue.createElementVNode("view", { class: "logo" }, [
          vue.createVNode(_component_AppIcon, {
            name: "bolt",
            size: 64,
            color: "#FFFFFF"
          })
        ]),
        vue.createElementVNode("text", { class: "title" }, "Open IoT"),
        vue.createElementVNode("text", { class: "subtitle" }, "智能设备配置工具")
      ]),
      vue.createElementVNode("view", { class: "loading" }, [
        vue.createElementVNode("view", { class: "spinner" })
      ])
    ]);
  }
  const PagesSplashSplash = /* @__PURE__ */ _export_sfc(_sfc_main$b, [["render", _sfc_render$a], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/splash/splash.vue"]]);
  const _sfc_main$a = {
    components: { AppIcon },
    data() {
      return {
        email: "",
        password: "",
        showPwd: false,
        showServerConfig: false,
        serverUrl: ""
      };
    },
    onLoad() {
      this.serverUrl = uni.getStorageSync("serverUrl") || "http://192.168.1.100:48080";
    },
    methods: {
      saveServerConfig() {
        uni.setStorageSync("serverUrl", this.serverUrl);
        this.showServerConfig = false;
        uni.showToast({ title: "已保存", icon: "success" });
      },
      handleLogin() {
        if (!this.email || !this.password) {
          uni.showToast({ title: "请输入邮箱和密码", icon: "none" });
          return;
        }
        uni.setStorageSync("token", "mock_token");
        uni.setStorageSync("userInfo", { email: this.email });
        uni.switchTab({ url: "/pages/device-list/device-list" });
      },
      goRegister() {
        uni.navigateTo({ url: "/pages/register/register" });
      },
      goForgotPassword() {
        uni.navigateTo({ url: "/pages/forgot-password/forgot-password" });
      }
    }
  };
  function _sfc_render$9(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "login" }, [
      vue.createElementVNode("view", {
        class: "settings-btn",
        onClick: _cache[0] || (_cache[0] = ($event) => $data.showServerConfig = true)
      }, [
        vue.createVNode(_component_AppIcon, {
          name: "settings",
          size: 48,
          color: "#8E8E93"
        })
      ]),
      vue.createElementVNode("view", { class: "header" }, [
        vue.createElementVNode("view", { class: "logo" }, [
          vue.createVNode(_component_AppIcon, {
            name: "bolt",
            size: 64,
            color: "#FFFFFF"
          })
        ]),
        vue.createElementVNode("text", { class: "title" }, "Open IoT"),
        vue.createElementVNode("text", { class: "subtitle" }, "欢迎回来，请登录")
      ]),
      vue.createElementVNode("view", { class: "form" }, [
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              type: "text",
              placeholder: "邮箱",
              "onUpdate:modelValue": _cache[1] || (_cache[1] = ($event) => $data.email = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.email]
          ])
        ]),
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.withDirectives(vue.createElementVNode("input", {
            class: "input",
            type: $data.showPwd ? "text" : "password",
            placeholder: "密码",
            "onUpdate:modelValue": _cache[2] || (_cache[2] = ($event) => $data.password = $event)
          }, null, 8, ["type"]), [
            [vue.vModelDynamic, $data.password]
          ]),
          vue.createElementVNode("view", {
            class: "input-action",
            onClick: _cache[3] || (_cache[3] = ($event) => $data.showPwd = !$data.showPwd)
          }, [
            vue.createVNode(_component_AppIcon, {
              name: $data.showPwd ? "eyeOff" : "eye",
              size: 40,
              color: "#8E8E93"
            }, null, 8, ["name"])
          ])
        ]),
        vue.createElementVNode("view", { class: "form-footer" }, [
          vue.createElementVNode("text", {
            class: "link",
            onClick: _cache[4] || (_cache[4] = (...args) => $options.goForgotPassword && $options.goForgotPassword(...args))
          }, "忘记密码？")
        ]),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[5] || (_cache[5] = (...args) => $options.handleLogin && $options.handleLogin(...args))
        }, "登录"),
        vue.createElementVNode("view", { class: "register-row" }, [
          vue.createElementVNode("text", { class: "text" }, "还没有账号？"),
          vue.createElementVNode("text", {
            class: "link",
            onClick: _cache[6] || (_cache[6] = (...args) => $options.goRegister && $options.goRegister(...args))
          }, "立即注册")
        ])
      ]),
      $data.showServerConfig ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "modal-mask",
        onClick: _cache[10] || (_cache[10] = ($event) => $data.showServerConfig = false)
      }, [
        vue.createElementVNode("view", {
          class: "modal-content",
          onClick: _cache[9] || (_cache[9] = vue.withModifiers(() => {
          }, ["stop"]))
        }, [
          vue.createElementVNode("view", { class: "modal-handle" }),
          vue.createElementVNode("text", { class: "modal-title" }, "服务器配置"),
          vue.createElementVNode("view", { class: "modal-form" }, [
            vue.createElementVNode("text", { class: "modal-label" }, "API 服务器地址"),
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "modal-input",
                type: "text",
                "onUpdate:modelValue": _cache[7] || (_cache[7] = ($event) => $data.serverUrl = $event),
                placeholder: "http://192.168.1.100:48080"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.serverUrl]
            ])
          ]),
          vue.createElementVNode("button", {
            class: "btn-primary",
            onClick: _cache[8] || (_cache[8] = (...args) => $options.saveServerConfig && $options.saveServerConfig(...args))
          }, "保存配置")
        ])
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesLoginLogin = /* @__PURE__ */ _export_sfc(_sfc_main$a, [["render", _sfc_render$9], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/login/login.vue"]]);
  const _sfc_main$9 = {
    components: { AppIcon },
    data() {
      return {
        email: "",
        password: "",
        confirmPassword: "",
        showPwd: false
      };
    },
    methods: {
      handleRegister() {
        if (!this.email || !this.password || !this.confirmPassword) {
          uni.showToast({ title: "请填写完整信息", icon: "none" });
          return;
        }
        if (this.password !== this.confirmPassword) {
          uni.showToast({ title: "两次密码不一致", icon: "none" });
          return;
        }
        uni.showToast({ title: "注册成功", icon: "success" });
        setTimeout(() => uni.navigateBack(), 1500);
      },
      goBack() {
        uni.navigateBack();
      }
    }
  };
  function _sfc_render$8(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "register" }, [
      vue.createElementVNode("view", { class: "form" }, [
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "邮箱"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              type: "text",
              placeholder: "请输入邮箱",
              "onUpdate:modelValue": _cache[0] || (_cache[0] = ($event) => $data.email = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.email]
          ])
        ]),
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "密码"),
          vue.withDirectives(vue.createElementVNode("input", {
            class: "input",
            type: $data.showPwd ? "text" : "password",
            placeholder: "请输入密码",
            "onUpdate:modelValue": _cache[1] || (_cache[1] = ($event) => $data.password = $event)
          }, null, 8, ["type"]), [
            [vue.vModelDynamic, $data.password]
          ]),
          vue.createElementVNode("view", {
            class: "input-action",
            onClick: _cache[2] || (_cache[2] = ($event) => $data.showPwd = !$data.showPwd)
          }, [
            vue.createVNode(_component_AppIcon, {
              name: $data.showPwd ? "eyeOff" : "eye",
              size: 40,
              color: "#8E8E93"
            }, null, 8, ["name"])
          ])
        ]),
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "确认密码"),
          vue.withDirectives(vue.createElementVNode("input", {
            class: "input",
            type: $data.showPwd ? "text" : "password",
            placeholder: "请再次输入密码",
            "onUpdate:modelValue": _cache[3] || (_cache[3] = ($event) => $data.confirmPassword = $event)
          }, null, 8, ["type"]), [
            [vue.vModelDynamic, $data.confirmPassword]
          ])
        ]),
        vue.createElementVNode("view", { class: "tip" }, [
          vue.createVNode(_component_AppIcon, {
            name: "warning",
            size: 32,
            color: "#FF9500"
          }),
          vue.createElementVNode("text", { class: "tip-text" }, "密码至少8位，包含字母和数字")
        ]),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[4] || (_cache[4] = (...args) => $options.handleRegister && $options.handleRegister(...args))
        }, "注册"),
        vue.createElementVNode("view", { class: "footer" }, [
          vue.createElementVNode("text", { class: "text" }, "已有账号？"),
          vue.createElementVNode("text", {
            class: "link",
            onClick: _cache[5] || (_cache[5] = (...args) => $options.goBack && $options.goBack(...args))
          }, "返回登录")
        ])
      ])
    ]);
  }
  const PagesRegisterRegister = /* @__PURE__ */ _export_sfc(_sfc_main$9, [["render", _sfc_render$8], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/register/register.vue"]]);
  const _sfc_main$8 = {
    data() {
      return {
        email: ""
      };
    },
    methods: {
      handleSubmit() {
        if (!this.email) {
          uni.showToast({ title: "请输入邮箱", icon: "none" });
          return;
        }
        uni.showToast({ title: "重置链接已发送", icon: "success" });
        setTimeout(() => uni.navigateBack(), 1500);
      },
      goBack() {
        uni.navigateBack();
      }
    }
  };
  function _sfc_render$7(_ctx, _cache, $props, $setup, $data, $options) {
    return vue.openBlock(), vue.createElementBlock("view", { class: "forgot" }, [
      vue.createElementVNode("view", { class: "desc" }, [
        vue.createElementVNode("text", { class: "desc-text" }, "请输入您的注册邮箱，我们将发送密码重置链接。")
      ]),
      vue.createElementVNode("view", { class: "form" }, [
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "邮箱"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              type: "text",
              placeholder: "请输入邮箱",
              "onUpdate:modelValue": _cache[0] || (_cache[0] = ($event) => $data.email = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.email]
          ])
        ]),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[1] || (_cache[1] = (...args) => $options.handleSubmit && $options.handleSubmit(...args))
        }, "发送重置链接"),
        vue.createElementVNode("view", { class: "footer" }, [
          vue.createElementVNode("text", {
            class: "link",
            onClick: _cache[2] || (_cache[2] = (...args) => $options.goBack && $options.goBack(...args))
          }, "返回登录")
        ])
      ])
    ]);
  }
  const PagesForgotPasswordForgotPassword = /* @__PURE__ */ _export_sfc(_sfc_main$8, [["render", _sfc_render$7], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/forgot-password/forgot-password.vue"]]);
  const mockDevices = [
    { id: "1", name: "IoT-Switch-A1B2", type: "servo", status: "online", firmware: "v1.2.0" },
    { id: "2", name: "IoT-Wakeup-C3D4", type: "wakeup", status: "online", firmware: "v1.0.0" },
    { id: "3", name: "IoT-Switch-E5F6", type: "servo", status: "offline", firmware: "v1.1.0" }
  ];
  const _sfc_main$7 = {
    components: { AppIcon },
    data() {
      return {
        devices: [],
        showModal: false,
        currentDevice: null
      };
    },
    onShow() {
      this.loadDevices();
    },
    methods: {
      loadDevices() {
        const saved = uni.getStorageSync("devices");
        this.devices = saved || mockDevices;
        if (!saved)
          uni.setStorageSync("devices", mockDevices);
      },
      statusText(status) {
        return { online: "在线", offline: "离线", configuring: "配置中" }[status] || "未知";
      },
      goScan() {
        uni.navigateTo({ url: "/pages/scan/scan" });
      },
      goControl(device) {
        uni.navigateTo({ url: "/pages/device-control/device-control?id=" + device.id });
      },
      showDelete(device) {
        this.currentDevice = device;
        this.showModal = true;
      },
      doDelete() {
        this.devices = this.devices.filter((d) => d.id !== this.currentDevice.id);
        uni.setStorageSync("devices", this.devices);
        this.showModal = false;
        uni.showToast({ title: "已删除", icon: "success" });
      }
    }
  };
  function _sfc_render$6(_ctx, _cache, $props, $setup, $data, $options) {
    var _a;
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "device-list" }, [
      vue.createElementVNode("scroll-view", {
        class: "list",
        "scroll-y": ""
      }, [
        $data.devices.length === 0 ? (vue.openBlock(), vue.createElementBlock("view", {
          key: 0,
          class: "empty"
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "device",
            size: 120,
            color: "#C7C7CC"
          }),
          vue.createElementVNode("text", { class: "empty-text" }, "暂无设备"),
          vue.createElementVNode("button", {
            class: "btn-add",
            onClick: _cache[0] || (_cache[0] = (...args) => $options.goScan && $options.goScan(...args))
          }, "添加设备")
        ])) : vue.createCommentVNode("v-if", true),
        (vue.openBlock(true), vue.createElementBlock(
          vue.Fragment,
          null,
          vue.renderList($data.devices, (device) => {
            return vue.openBlock(), vue.createElementBlock("view", {
              key: device.id,
              class: "device-card",
              onClick: ($event) => $options.goControl(device),
              onLongpress: ($event) => $options.showDelete(device)
            }, [
              vue.createElementVNode("view", { class: "card-header" }, [
                vue.createElementVNode(
                  "view",
                  {
                    class: vue.normalizeClass(["status-dot", device.status])
                  },
                  null,
                  2
                  /* CLASS */
                ),
                vue.createElementVNode(
                  "text",
                  { class: "device-name" },
                  vue.toDisplayString(device.name),
                  1
                  /* TEXT */
                ),
                vue.createElementVNode(
                  "text",
                  {
                    class: vue.normalizeClass(["device-status", device.status])
                  },
                  vue.toDisplayString($options.statusText(device.status)),
                  3
                  /* TEXT, CLASS */
                )
              ]),
              vue.createElementVNode("view", { class: "card-footer" }, [
                vue.createElementVNode(
                  "text",
                  { class: "device-info" },
                  vue.toDisplayString(device.type === "servo" ? "舵机开关" : "USB唤醒"),
                  1
                  /* TEXT */
                ),
                vue.createElementVNode(
                  "text",
                  { class: "device-info" },
                  "固件: " + vue.toDisplayString(device.firmware),
                  1
                  /* TEXT */
                )
              ])
            ], 40, ["onClick", "onLongpress"]);
          }),
          128
          /* KEYED_FRAGMENT */
        )),
        $data.devices.length > 0 ? (vue.openBlock(), vue.createElementBlock("view", {
          key: 1,
          class: "tip"
        }, "长按设备可删除")) : vue.createCommentVNode("v-if", true)
      ]),
      vue.createElementVNode("view", {
        class: "fab",
        onClick: _cache[1] || (_cache[1] = (...args) => $options.goScan && $options.goScan(...args))
      }, [
        vue.createElementVNode("text", { class: "fab-icon" }, "+")
      ]),
      $data.showModal ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "modal",
        onClick: _cache[5] || (_cache[5] = ($event) => $data.showModal = false)
      }, [
        vue.createElementVNode("view", {
          class: "modal-content",
          onClick: _cache[4] || (_cache[4] = vue.withModifiers(() => {
          }, ["stop"]))
        }, [
          vue.createElementVNode("text", { class: "modal-title" }, "删除设备"),
          vue.createElementVNode(
            "text",
            { class: "modal-msg" },
            "确定删除「" + vue.toDisplayString((_a = $data.currentDevice) == null ? void 0 : _a.name) + "」？",
            1
            /* TEXT */
          ),
          vue.createElementVNode("view", { class: "modal-btns" }, [
            vue.createElementVNode("button", {
              class: "btn-cancel",
              onClick: _cache[2] || (_cache[2] = ($event) => $data.showModal = false)
            }, "取消"),
            vue.createElementVNode("button", {
              class: "btn-delete",
              onClick: _cache[3] || (_cache[3] = (...args) => $options.doDelete && $options.doDelete(...args))
            }, "删除")
          ])
        ])
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesDeviceListDeviceList = /* @__PURE__ */ _export_sfc(_sfc_main$7, [["render", _sfc_render$6], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/device-list/device-list.vue"]]);
  const _sfc_main$6 = {
    components: { AppIcon },
    data() {
      return {
        devices: [
          { name: "IoT-Switch-A1B2", type: "舵机开关", icon: "plug", signal: 4 },
          { name: "IoT-Wakeup-C3D4", type: "USB唤醒", icon: "bolt", signal: 5 },
          { name: "IoT-Switch-E5F6", type: "舵机开关", icon: "plug", signal: 2 }
        ]
      };
    },
    methods: {
      connectDevice(device) {
        uni.navigateTo({ url: "/pages/config/config?name=" + device.name + "&type=" + device.type });
      }
    }
  };
  function _sfc_render$5(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "scan" }, [
      vue.createElementVNode("view", { class: "scanning" }, [
        vue.createElementVNode("view", { class: "spinner" }),
        vue.createElementVNode("text", { class: "scanning-text" }, "正在扫描附近的设备...")
      ]),
      vue.createElementVNode("view", { class: "device-list" }, [
        (vue.openBlock(true), vue.createElementBlock(
          vue.Fragment,
          null,
          vue.renderList($data.devices, (device, index) => {
            return vue.openBlock(), vue.createElementBlock("view", {
              key: index,
              class: "device-item",
              onClick: ($event) => $options.connectDevice(device)
            }, [
              vue.createVNode(_component_AppIcon, {
                name: device.icon,
                size: 48,
                color: "#007AFF"
              }, null, 8, ["name"]),
              vue.createElementVNode("view", { class: "device-info" }, [
                vue.createElementVNode(
                  "text",
                  { class: "device-name" },
                  vue.toDisplayString(device.name),
                  1
                  /* TEXT */
                ),
                vue.createElementVNode(
                  "text",
                  { class: "device-type" },
                  vue.toDisplayString(device.type),
                  1
                  /* TEXT */
                )
              ]),
              vue.createElementVNode("view", { class: "signal" }, [
                (vue.openBlock(), vue.createElementBlock(
                  vue.Fragment,
                  null,
                  vue.renderList(5, (n) => {
                    return vue.createElementVNode(
                      "view",
                      {
                        key: n,
                        class: vue.normalizeClass(["bar", { active: n <= device.signal }]),
                        style: vue.normalizeStyle({ height: n * 6 + 4 + "rpx" })
                      },
                      null,
                      6
                      /* CLASS, STYLE */
                    );
                  }),
                  64
                  /* STABLE_FRAGMENT */
                ))
              ]),
              vue.createElementVNode("view", { class: "connect-btn" }, "连接")
            ], 8, ["onClick"]);
          }),
          128
          /* KEYED_FRAGMENT */
        ))
      ]),
      $data.devices.length === 0 ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "empty"
      }, [
        vue.createElementVNode("text", { class: "empty-text" }, "未发现设备，请确保设备已开启")
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesScanScan = /* @__PURE__ */ _export_sfc(_sfc_main$6, [["render", _sfc_render$5], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/scan/scan.vue"]]);
  const _sfc_main$5 = {
    components: { AppIcon },
    data() {
      return {
        step: 1,
        deviceName: "",
        deviceType: "",
        wifiName: "MyHome_5G",
        wifiPassword: "",
        customName: "",
        location: ""
      };
    },
    onLoad(options) {
      this.deviceName = options.name || "IoT-Device";
      this.deviceType = options.type || "舵机开关";
      this.customName = this.deviceName;
    },
    methods: {
      selectWifi() {
        uni.showToast({ title: "选择WiFi功能开发中", icon: "none" });
      },
      nextStep() {
        if (this.step === 1 && !this.wifiPassword) {
          uni.showToast({ title: "请输入WiFi密码", icon: "none" });
          return;
        }
        if (this.step === 2 && !this.customName) {
          uni.showToast({ title: "请输入设备名称", icon: "none" });
          return;
        }
        if (this.step === 2) {
          this.saveDevice();
        }
        this.step++;
      },
      saveDevice() {
        const devices = uni.getStorageSync("devices") || [];
        const newDevice = {
          id: Date.now().toString(),
          name: this.customName,
          type: this.deviceType === "USB唤醒" ? "wakeup" : "servo",
          status: "online",
          firmware: "v1.0.0",
          location: this.location
        };
        devices.push(newDevice);
        uni.setStorageSync("devices", devices);
      },
      goDeviceList() {
        uni.switchTab({ url: "/pages/device-list/device-list" });
      }
    }
  };
  function _sfc_render$4(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "config" }, [
      vue.createElementVNode("view", { class: "stepper" }, [
        vue.createElementVNode(
          "view",
          {
            class: vue.normalizeClass(["step", { current: $data.step === 1, done: $data.step > 1 }])
          },
          [
            vue.createElementVNode("view", { class: "circle" }, "1"),
            vue.createElementVNode("text", { class: "step-text" }, "WiFi")
          ],
          2
          /* CLASS */
        ),
        vue.createElementVNode("view", { class: "line" }),
        vue.createElementVNode(
          "view",
          {
            class: vue.normalizeClass(["step", { current: $data.step === 2, done: $data.step > 2 }])
          },
          [
            vue.createElementVNode("view", { class: "circle" }, "2"),
            vue.createElementVNode("text", { class: "step-text" }, "名称")
          ],
          2
          /* CLASS */
        ),
        vue.createElementVNode("view", { class: "line" }),
        vue.createElementVNode(
          "view",
          {
            class: vue.normalizeClass(["step", { current: $data.step === 3 }])
          },
          [
            vue.createElementVNode("view", { class: "circle" }, "3"),
            vue.createElementVNode("text", { class: "step-text" }, "完成")
          ],
          2
          /* CLASS */
        )
      ]),
      vue.createElementVNode("view", { class: "device-card" }, [
        vue.createVNode(_component_AppIcon, {
          name: $data.deviceType === "USB唤醒" ? "bolt" : "plug",
          size: 48,
          color: "#007AFF"
        }, null, 8, ["name"]),
        vue.createElementVNode("view", { class: "device-info" }, [
          vue.createElementVNode(
            "text",
            { class: "device-name" },
            vue.toDisplayString($data.deviceName),
            1
            /* TEXT */
          ),
          vue.createElementVNode(
            "text",
            { class: "device-type" },
            vue.toDisplayString($data.deviceType),
            1
            /* TEXT */
          )
        ])
      ]),
      $data.step === 1 ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "form-card"
      }, [
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "WiFi 网络"),
          vue.createElementVNode("view", {
            class: "select",
            onClick: _cache[0] || (_cache[0] = (...args) => $options.selectWifi && $options.selectWifi(...args))
          }, [
            vue.createElementVNode(
              "text",
              null,
              vue.toDisplayString($data.wifiName || "选择WiFi"),
              1
              /* TEXT */
            ),
            vue.createElementVNode("text", { class: "arrow" }, "›")
          ])
        ]),
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "WiFi 密码"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              type: "password",
              placeholder: "请输入WiFi密码",
              "onUpdate:modelValue": _cache[1] || (_cache[1] = ($event) => $data.wifiPassword = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.wifiPassword]
          ])
        ]),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[2] || (_cache[2] = (...args) => $options.nextStep && $options.nextStep(...args))
        }, "下一步")
      ])) : vue.createCommentVNode("v-if", true),
      $data.step === 2 ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 1,
        class: "form-card"
      }, [
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "设备名称"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              placeholder: "请输入设备名称",
              "onUpdate:modelValue": _cache[3] || (_cache[3] = ($event) => $data.customName = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.customName]
          ])
        ]),
        vue.createElementVNode("view", { class: "input-group" }, [
          vue.createElementVNode("text", { class: "label" }, "设备位置（可选）"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "input",
              placeholder: "如：客厅、卧室",
              "onUpdate:modelValue": _cache[4] || (_cache[4] = ($event) => $data.location = $event)
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.location]
          ])
        ]),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[5] || (_cache[5] = (...args) => $options.nextStep && $options.nextStep(...args))
        }, "下一步")
      ])) : vue.createCommentVNode("v-if", true),
      $data.step === 3 ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 2,
        class: "success-card"
      }, [
        vue.createVNode(_component_AppIcon, {
          name: "check",
          size: 64,
          color: "#FFFFFF"
        }),
        vue.createElementVNode("text", { class: "success-title" }, "配置成功"),
        vue.createElementVNode("text", { class: "success-desc" }, "设备已添加到您的设备列表"),
        vue.createElementVNode("button", {
          class: "btn-primary",
          onClick: _cache[6] || (_cache[6] = (...args) => $options.goDeviceList && $options.goDeviceList(...args))
        }, "返回设备列表")
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesConfigConfig = /* @__PURE__ */ _export_sfc(_sfc_main$5, [["render", _sfc_render$4], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/config/config.vue"]]);
  const _imports_0 = "/static/icons/power.svg";
  const _sfc_main$4 = {
    components: { AppIcon },
    data() {
      return {
        device: { id: "", name: "", type: "servo", status: "online", firmware: "v1.0.0" },
        position: "middle",
        pulseSending: false,
        pulseSuccess: false,
        showAdvanced: false,
        pulseDuration: 500,
        showEditModal: false,
        editName: ""
      };
    },
    computed: {
      positionText() {
        return { up: "上", middle: "中", down: "下" }[this.position];
      }
    },
    onLoad(options) {
      if (options.id) {
        this.loadDevice(options.id);
      }
    },
    methods: {
      loadDevice(id) {
        const devices = uni.getStorageSync("devices") || [];
        const device = devices.find((d) => d.id === id);
        if (device)
          this.device = device;
      },
      statusText(status) {
        return { online: "在线", offline: "离线", configuring: "配置中" }[status] || "未知";
      },
      setPosition(pos) {
        this.position = pos;
        uni.showToast({ title: "已设置到" + this.positionText, icon: "success" });
      },
      onDurationChange(e) {
        this.pulseDuration = e.detail.value;
      },
      triggerPulse() {
        if (this.pulseSending)
          return;
        this.pulseSending = true;
        this.pulseSuccess = false;
        setTimeout(() => {
          this.pulseSending = false;
          this.pulseSuccess = true;
          setTimeout(() => {
            this.pulseSuccess = false;
          }, 2e3);
        }, this.pulseDuration);
      },
      triggerWakeup() {
        uni.showToast({ title: "唤醒信号已发送", icon: "success" });
      },
      editDeviceName() {
        this.editName = this.device.name;
        this.showEditModal = true;
      },
      saveDeviceName() {
        const newName = this.editName.trim();
        if (!newName) {
          uni.showToast({ title: "名称不能为空", icon: "none" });
          return;
        }
        const devices = uni.getStorageSync("devices") || [];
        const index = devices.findIndex((d) => d.id === this.device.id);
        if (index !== -1) {
          devices[index].name = newName;
          uni.setStorageSync("devices", devices);
          this.device.name = newName;
        }
        this.showEditModal = false;
        uni.showToast({ title: "修改成功", icon: "success" });
      },
      confirmDelete() {
        uni.showModal({
          title: "删除设备",
          content: "确定要删除「" + this.device.name + "」吗？",
          success: (res) => {
            if (res.confirm) {
              const devices = uni.getStorageSync("devices") || [];
              const newDevices = devices.filter((d) => d.id !== this.device.id);
              uni.setStorageSync("devices", newDevices);
              uni.showToast({ title: "已删除", icon: "success" });
              setTimeout(() => uni.navigateBack(), 1500);
            }
          }
        });
      }
    }
  };
  function _sfc_render$3(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "control" }, [
      vue.createElementVNode("view", { class: "status-card" }, [
        vue.createElementVNode(
          "view",
          {
            class: vue.normalizeClass(["status-dot", $data.device.status])
          },
          null,
          2
          /* CLASS */
        ),
        vue.createElementVNode(
          "text",
          {
            class: vue.normalizeClass(["status-text", $data.device.status])
          },
          vue.toDisplayString($options.statusText($data.device.status)),
          3
          /* TEXT, CLASS */
        ),
        vue.createElementVNode(
          "text",
          { class: "firmware" },
          "固件: " + vue.toDisplayString($data.device.firmware),
          1
          /* TEXT */
        )
      ]),
      $data.device.type === "servo" ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "control-section"
      }, [
        vue.createElementVNode("text", { class: "section-title" }, "位置控制"),
        vue.createElementVNode("view", { class: "position-display" }, [
          vue.createElementVNode("text", { class: "position-label" }, "当前位置"),
          vue.createElementVNode(
            "text",
            { class: "position-value" },
            vue.toDisplayString($options.positionText),
            1
            /* TEXT */
          )
        ]),
        vue.createElementVNode("view", { class: "position-buttons" }, [
          vue.createElementVNode(
            "button",
            {
              class: vue.normalizeClass(["pos-btn", { active: $data.position === "up" }]),
              onClick: _cache[0] || (_cache[0] = ($event) => $options.setPosition("up"))
            },
            "上",
            2
            /* CLASS */
          ),
          vue.createElementVNode(
            "button",
            {
              class: vue.normalizeClass(["pos-btn", { active: $data.position === "middle" }]),
              onClick: _cache[1] || (_cache[1] = ($event) => $options.setPosition("middle"))
            },
            "中",
            2
            /* CLASS */
          ),
          vue.createElementVNode(
            "button",
            {
              class: vue.normalizeClass(["pos-btn", { active: $data.position === "down" }]),
              onClick: _cache[2] || (_cache[2] = ($event) => $options.setPosition("down"))
            },
            "下",
            2
            /* CLASS */
          )
        ]),
        vue.createElementVNode("view", { class: "pulse-section" }, [
          vue.createElementVNode("text", { class: "section-title" }, "脉冲触发"),
          vue.createElementVNode("view", {
            class: "advanced-toggle",
            onClick: _cache[3] || (_cache[3] = ($event) => $data.showAdvanced = !$data.showAdvanced)
          }, [
            vue.createElementVNode(
              "view",
              {
                class: vue.normalizeClass(["checkbox", { checked: $data.showAdvanced }])
              },
              [
                $data.showAdvanced ? (vue.openBlock(), vue.createBlock(_component_AppIcon, {
                  key: 0,
                  name: "check",
                  size: 24,
                  color: "#FFFFFF"
                })) : vue.createCommentVNode("v-if", true)
              ],
              2
              /* CLASS */
            ),
            vue.createElementVNode("text", { class: "toggle-text" }, "高级选项")
          ]),
          $data.showAdvanced ? (vue.openBlock(), vue.createElementBlock("view", {
            key: 0,
            class: "advanced-options"
          }, [
            vue.createElementVNode("view", { class: "option-row" }, [
              vue.createElementVNode("text", { class: "option-label" }, "脉冲时长"),
              vue.createElementVNode(
                "text",
                { class: "option-value" },
                vue.toDisplayString($data.pulseDuration) + "ms",
                1
                /* TEXT */
              )
            ]),
            vue.createElementVNode("slider", {
              class: "duration-slider",
              value: $data.pulseDuration,
              min: 100,
              max: 2e3,
              step: 100,
              activeColor: "#007AFF",
              onChange: _cache[4] || (_cache[4] = (...args) => $options.onDurationChange && $options.onDurationChange(...args))
            }, null, 40, ["value"]),
            vue.createElementVNode("view", { class: "duration-hints" }, [
              vue.createElementVNode("text", { class: "hint" }, "100ms"),
              vue.createElementVNode("text", { class: "hint" }, "2000ms")
            ]),
            vue.createElementVNode("view", { class: "preset-btns" }, [
              vue.createElementVNode(
                "view",
                {
                  class: vue.normalizeClass(["preset-btn", { active: $data.pulseDuration === 200 }]),
                  onClick: _cache[5] || (_cache[5] = ($event) => $data.pulseDuration = 200)
                },
                "快速",
                2
                /* CLASS */
              ),
              vue.createElementVNode(
                "view",
                {
                  class: vue.normalizeClass(["preset-btn", { active: $data.pulseDuration === 500 }]),
                  onClick: _cache[6] || (_cache[6] = ($event) => $data.pulseDuration = 500)
                },
                "标准",
                2
                /* CLASS */
              ),
              vue.createElementVNode(
                "view",
                {
                  class: vue.normalizeClass(["preset-btn", { active: $data.pulseDuration === 1e3 }]),
                  onClick: _cache[7] || (_cache[7] = ($event) => $data.pulseDuration = 1e3)
                },
                "慢速",
                2
                /* CLASS */
              )
            ])
          ])) : vue.createCommentVNode("v-if", true),
          vue.createElementVNode(
            "button",
            {
              class: vue.normalizeClass(["pulse-btn", { sending: $data.pulseSending, success: $data.pulseSuccess }]),
              onClick: _cache[8] || (_cache[8] = (...args) => $options.triggerPulse && $options.triggerPulse(...args))
            },
            vue.toDisplayString($data.pulseSending ? "发送中..." : $data.pulseSuccess ? "✓ 已触发" : "触发脉冲"),
            3
            /* TEXT, CLASS */
          ),
          vue.createElementVNode("text", { class: "pulse-hint" }, "短暂触发后自动恢复")
        ])
      ])) : (vue.openBlock(), vue.createElementBlock("view", {
        key: 1,
        class: "control-section"
      }, [
        vue.createElementVNode("text", { class: "section-title" }, "电脑唤醒"),
        vue.createElementVNode("view", {
          class: "wakeup-card",
          onClick: _cache[9] || (_cache[9] = (...args) => $options.triggerWakeup && $options.triggerWakeup(...args))
        }, [
          vue.createElementVNode("view", { class: "wakeup-icon" }, [
            vue.createElementVNode("image", {
              src: _imports_0,
              class: "power-img",
              mode: "aspectFit"
            })
          ]),
          vue.createElementVNode("text", { class: "wakeup-label" }, "点击唤醒"),
          vue.createElementVNode("text", { class: "wakeup-hint" }, "电脑将立即启动")
        ])
      ])),
      vue.createElementVNode("view", { class: "info-section" }, [
        vue.createElementVNode("text", { class: "section-title" }, "设备信息"),
        vue.createElementVNode("view", { class: "info-card" }, [
          vue.createElementVNode("view", {
            class: "info-item editable",
            onClick: _cache[10] || (_cache[10] = (...args) => $options.editDeviceName && $options.editDeviceName(...args))
          }, [
            vue.createElementVNode("text", { class: "info-label" }, "设备名称"),
            vue.createElementVNode("view", { class: "info-right" }, [
              vue.createElementVNode(
                "text",
                { class: "info-value" },
                vue.toDisplayString($data.device.name),
                1
                /* TEXT */
              ),
              vue.createElementVNode("text", { class: "edit-icon" }, "›")
            ])
          ]),
          vue.createElementVNode("view", { class: "info-item" }, [
            vue.createElementVNode("text", { class: "info-label" }, "设备ID"),
            vue.createElementVNode(
              "text",
              { class: "info-value" },
              vue.toDisplayString($data.device.id),
              1
              /* TEXT */
            )
          ]),
          vue.createElementVNode("view", { class: "info-item" }, [
            vue.createElementVNode("text", { class: "info-label" }, "设备类型"),
            vue.createElementVNode(
              "text",
              { class: "info-value" },
              vue.toDisplayString($data.device.type === "servo" ? "舵机开关" : "USB唤醒"),
              1
              /* TEXT */
            )
          ])
        ])
      ]),
      vue.createElementVNode("view", { class: "delete-section" }, [
        vue.createElementVNode("button", {
          class: "btn-delete",
          onClick: _cache[11] || (_cache[11] = (...args) => $options.confirmDelete && $options.confirmDelete(...args))
        }, "删除设备")
      ]),
      $data.showEditModal ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 2,
        class: "modal",
        onClick: _cache[16] || (_cache[16] = ($event) => $data.showEditModal = false)
      }, [
        vue.createElementVNode("view", {
          class: "modal-content",
          onClick: _cache[15] || (_cache[15] = vue.withModifiers(() => {
          }, ["stop"]))
        }, [
          vue.createElementVNode("text", { class: "modal-title" }, "修改设备名称"),
          vue.withDirectives(vue.createElementVNode(
            "input",
            {
              class: "modal-input",
              "onUpdate:modelValue": _cache[12] || (_cache[12] = ($event) => $data.editName = $event),
              placeholder: "请输入设备名称",
              maxlength: "20"
            },
            null,
            512
            /* NEED_PATCH */
          ), [
            [vue.vModelText, $data.editName]
          ]),
          vue.createElementVNode("view", { class: "modal-btns" }, [
            vue.createElementVNode("button", {
              class: "btn-cancel",
              onClick: _cache[13] || (_cache[13] = ($event) => $data.showEditModal = false)
            }, "取消"),
            vue.createElementVNode("button", {
              class: "btn-confirm",
              onClick: _cache[14] || (_cache[14] = (...args) => $options.saveDeviceName && $options.saveDeviceName(...args))
            }, "确定")
          ])
        ])
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesDeviceControlDeviceControl = /* @__PURE__ */ _export_sfc(_sfc_main$4, [["render", _sfc_render$3], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/device-control/device-control.vue"]]);
  const _sfc_main$3 = {
    data() {
      return {
        showServerModal: false,
        serverUrl: "http://192.168.1.100:48080"
      };
    },
    onLoad() {
      const saved = uni.getStorageSync("serverUrl");
      if (saved)
        this.serverUrl = saved;
    },
    methods: {
      saveServer() {
        uni.setStorageSync("serverUrl", this.serverUrl);
        this.showServerModal = false;
        uni.showToast({ title: "已保存", icon: "success" });
      },
      goAbout() {
        uni.navigateTo({ url: "/pages/about/about" });
      },
      handleLogout() {
        uni.showModal({
          title: "确认退出",
          content: "确定要退出登录吗？",
          success: (res) => {
            if (res.confirm) {
              uni.removeStorageSync("token");
              uni.reLaunch({ url: "/pages/login/login" });
            }
          }
        });
      }
    }
  };
  function _sfc_render$2(_ctx, _cache, $props, $setup, $data, $options) {
    return vue.openBlock(), vue.createElementBlock("view", { class: "settings" }, [
      vue.createElementVNode("view", { class: "user-card" }, [
        vue.createElementVNode("view", { class: "avatar" }, [
          vue.createElementVNode("text", { class: "avatar-text" }, "U")
        ]),
        vue.createElementVNode("view", { class: "user-info" }, [
          vue.createElementVNode("text", { class: "user-name" }, "用户"),
          vue.createElementVNode("text", { class: "user-email" }, "user@example.com")
        ])
      ]),
      vue.createElementVNode("text", { class: "group-title" }, "服务器配置"),
      vue.createElementVNode("view", { class: "menu-section" }, [
        vue.createElementVNode("view", {
          class: "menu-item",
          onClick: _cache[0] || (_cache[0] = ($event) => $data.showServerModal = true)
        }, [
          vue.createElementVNode("text", { class: "menu-label" }, "API 服务器"),
          vue.createElementVNode(
            "text",
            { class: "menu-value" },
            vue.toDisplayString($data.serverUrl),
            1
            /* TEXT */
          ),
          vue.createElementVNode("text", { class: "menu-arrow" }, "›")
        ])
      ]),
      vue.createElementVNode("text", { class: "group-title" }, "其他"),
      vue.createElementVNode("view", { class: "menu-section" }, [
        vue.createElementVNode("view", {
          class: "menu-item",
          onClick: _cache[1] || (_cache[1] = (...args) => $options.goAbout && $options.goAbout(...args))
        }, [
          vue.createElementVNode("text", { class: "menu-label" }, "关于"),
          vue.createElementVNode("text", { class: "menu-value" }, "v1.0.0"),
          vue.createElementVNode("text", { class: "menu-arrow" }, "›")
        ])
      ]),
      vue.createElementVNode("view", { class: "logout-section" }, [
        vue.createElementVNode("button", {
          class: "btn-logout",
          onClick: _cache[2] || (_cache[2] = (...args) => $options.handleLogout && $options.handleLogout(...args))
        }, "退出登录")
      ]),
      $data.showServerModal ? (vue.openBlock(), vue.createElementBlock("view", {
        key: 0,
        class: "modal",
        onClick: _cache[6] || (_cache[6] = ($event) => $data.showServerModal = false)
      }, [
        vue.createElementVNode("view", {
          class: "modal-content",
          onClick: _cache[5] || (_cache[5] = vue.withModifiers(() => {
          }, ["stop"]))
        }, [
          vue.createElementVNode("text", { class: "modal-title" }, "服务器配置"),
          vue.createElementVNode("view", { class: "input-group" }, [
            vue.createElementVNode("text", { class: "label" }, "API 服务器地址"),
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[3] || (_cache[3] = ($event) => $data.serverUrl = $event),
                placeholder: "http://192.168.1.100:48080"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.serverUrl]
            ])
          ]),
          vue.createElementVNode("button", {
            class: "btn-save",
            onClick: _cache[4] || (_cache[4] = (...args) => $options.saveServer && $options.saveServer(...args))
          }, "保存配置")
        ])
      ])) : vue.createCommentVNode("v-if", true)
    ]);
  }
  const PagesSettingsSettings = /* @__PURE__ */ _export_sfc(_sfc_main$3, [["render", _sfc_render$2], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/settings/settings.vue"]]);
  const _sfc_main$2 = {
    components: { AppIcon },
    methods: {
      openLink(type) {
        const urls = {
          github: "https://github.com/user/open-iot-platform",
          changelog: "https://github.com/user/open-iot-platform/blob/main/CHANGELOG.md",
          license: "https://github.com/user/open-iot-platform/blob/main/LICENSE"
        };
        plus.runtime.openURL(urls[type]);
      }
    }
  };
  function _sfc_render$1(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "about" }, [
      vue.createElementVNode("view", { class: "logo-section" }, [
        vue.createElementVNode("view", { class: "logo" }, [
          vue.createVNode(_component_AppIcon, {
            name: "bolt",
            size: 64,
            color: "#FFFFFF"
          })
        ]),
        vue.createElementVNode("text", { class: "app-name" }, "Open IoT Platform"),
        vue.createElementVNode("text", { class: "app-desc" }, "轻量级开源 IoT 设备管理平台")
      ]),
      vue.createElementVNode("view", { class: "card" }, [
        vue.createElementVNode("view", { class: "info-item" }, [
          vue.createElementVNode("text", { class: "info-label" }, "版本号"),
          vue.createElementVNode("text", { class: "info-value" }, "v1.0.0")
        ]),
        vue.createElementVNode("view", { class: "info-item" }, [
          vue.createElementVNode("text", { class: "info-label" }, "构建日期"),
          vue.createElementVNode("text", { class: "info-value" }, "2026-01-14")
        ])
      ]),
      vue.createElementVNode("text", { class: "group-title" }, "相关链接"),
      vue.createElementVNode("view", { class: "card" }, [
        vue.createElementVNode("view", {
          class: "link-item",
          onClick: _cache[0] || (_cache[0] = ($event) => $options.openLink("github"))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "link",
            size: 32,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "link-label" }, "GitHub"),
          vue.createElementVNode("text", { class: "link-arrow" }, "›")
        ]),
        vue.createElementVNode("view", {
          class: "link-item",
          onClick: _cache[1] || (_cache[1] = ($event) => $options.openLink("changelog"))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "document",
            size: 32,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "link-label" }, "更新日志"),
          vue.createElementVNode("text", { class: "link-arrow" }, "›")
        ]),
        vue.createElementVNode("view", {
          class: "link-item",
          onClick: _cache[2] || (_cache[2] = ($event) => $options.openLink("license"))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "license",
            size: 32,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "link-label" }, "开源协议"),
          vue.createElementVNode("text", { class: "link-value" }, "GPL v3"),
          vue.createElementVNode("text", { class: "link-arrow" }, "›")
        ])
      ]),
      vue.createElementVNode("text", { class: "group-title" }, "作者"),
      vue.createElementVNode("view", { class: "card" }, [
        vue.createElementVNode("view", { class: "info-item" }, [
          vue.createElementVNode("text", { class: "info-label" }, "作者"),
          vue.createElementVNode("text", { class: "info-value" }, "罗耀生")
        ]),
        vue.createElementVNode("view", { class: "info-item" }, [
          vue.createElementVNode("text", { class: "info-label" }, "邮箱"),
          vue.createElementVNode("text", { class: "info-value email" }, "contact@i2kai.com")
        ])
      ]),
      vue.createElementVNode("text", { class: "group-title" }, "技术栈"),
      vue.createElementVNode("view", { class: "card" }, [
        vue.createElementVNode("view", { class: "tech-list" }, [
          vue.createElementVNode("text", { class: "tech-chip" }, "Flutter"),
          vue.createElementVNode("text", { class: "tech-chip" }, "UniApp"),
          vue.createElementVNode("text", { class: "tech-chip" }, "Go"),
          vue.createElementVNode("text", { class: "tech-chip" }, "MQTT"),
          vue.createElementVNode("text", { class: "tech-chip" }, "MySQL")
        ])
      ]),
      vue.createElementVNode("view", { class: "footer" }, [
        vue.createElementVNode("text", { class: "copyright" }, "© 2026 Open IoT Platform"),
        vue.createElementVNode("text", { class: "copyright" }, "All rights reserved")
      ])
    ]);
  }
  const PagesAboutAbout = /* @__PURE__ */ _export_sfc(_sfc_main$2, [["render", _sfc_render$1], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/about/about.vue"]]);
  const _sfc_main$1 = {
    components: { AppIcon },
    data() {
      return {
        deviceCount: 0,
        onlineCount: 0
      };
    },
    onShow() {
      this.loadStats();
    },
    methods: {
      loadStats() {
        const devices = uni.getStorageSync("devices") || [];
        this.deviceCount = devices.length;
        this.onlineCount = devices.filter((d) => d.status === "online").length;
      },
      goDeviceList() {
        uni.switchTab({ url: "/pages/device-list/device-list" });
      },
      goSettings() {
        uni.navigateTo({ url: "/pages/settings/settings" });
      },
      goAbout() {
        uni.navigateTo({ url: "/pages/about/about" });
      },
      handleLogout() {
        uni.showModal({
          title: "确认退出",
          content: "确定要退出登录吗？",
          success: (res) => {
            if (res.confirm) {
              uni.removeStorageSync("token");
              uni.reLaunch({ url: "/pages/login/login" });
            }
          }
        });
      }
    }
  };
  function _sfc_render(_ctx, _cache, $props, $setup, $data, $options) {
    const _component_AppIcon = vue.resolveComponent("AppIcon");
    return vue.openBlock(), vue.createElementBlock("view", { class: "profile" }, [
      vue.createElementVNode("view", { class: "header" }, [
        vue.createElementVNode("view", { class: "avatar" }, [
          vue.createElementVNode("text", { class: "avatar-text" }, "U")
        ]),
        vue.createElementVNode("text", { class: "user-name" }, "用户"),
        vue.createElementVNode("text", { class: "user-email" }, "user@example.com")
      ]),
      vue.createElementVNode("view", { class: "stats" }, [
        vue.createElementVNode("view", { class: "stat-item" }, [
          vue.createElementVNode(
            "text",
            { class: "stat-value" },
            vue.toDisplayString($data.deviceCount),
            1
            /* TEXT */
          ),
          vue.createElementVNode("text", { class: "stat-label" }, "设备总数")
        ]),
        vue.createElementVNode("view", { class: "stat-item" }, [
          vue.createElementVNode(
            "text",
            { class: "stat-value online" },
            vue.toDisplayString($data.onlineCount),
            1
            /* TEXT */
          ),
          vue.createElementVNode("text", { class: "stat-label" }, "在线设备")
        ]),
        vue.createElementVNode("view", { class: "stat-item" }, [
          vue.createElementVNode("text", { class: "stat-value" }, "1.0"),
          vue.createElementVNode("text", { class: "stat-label" }, "版本")
        ])
      ]),
      vue.createElementVNode("view", { class: "menu-section" }, [
        vue.createElementVNode("view", {
          class: "menu-item",
          onClick: _cache[0] || (_cache[0] = (...args) => $options.goDeviceList && $options.goDeviceList(...args))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "device",
            size: 40,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "menu-label" }, "设备管理"),
          vue.createElementVNode(
            "text",
            { class: "menu-value" },
            vue.toDisplayString($data.deviceCount) + " 台",
            1
            /* TEXT */
          ),
          vue.createElementVNode("text", { class: "menu-arrow" }, "›")
        ])
      ]),
      vue.createElementVNode("view", { class: "menu-section" }, [
        vue.createElementVNode("view", {
          class: "menu-item",
          onClick: _cache[1] || (_cache[1] = (...args) => $options.goSettings && $options.goSettings(...args))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "settings",
            size: 40,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "menu-label" }, "设置"),
          vue.createElementVNode("text", { class: "menu-arrow" }, "›")
        ]),
        vue.createElementVNode("view", {
          class: "menu-item",
          onClick: _cache[2] || (_cache[2] = (...args) => $options.goAbout && $options.goAbout(...args))
        }, [
          vue.createVNode(_component_AppIcon, {
            name: "info",
            size: 40,
            color: "#8E8E93"
          }),
          vue.createElementVNode("text", { class: "menu-label" }, "关于"),
          vue.createElementVNode("text", { class: "menu-value" }, "v1.0.0"),
          vue.createElementVNode("text", { class: "menu-arrow" }, "›")
        ])
      ]),
      vue.createElementVNode("view", { class: "logout-section" }, [
        vue.createElementVNode("button", {
          class: "btn-logout",
          onClick: _cache[3] || (_cache[3] = (...args) => $options.handleLogout && $options.handleLogout(...args))
        }, "退出登录")
      ])
    ]);
  }
  const PagesProfileProfile = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["render", _sfc_render], ["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/pages/profile/profile.vue"]]);
  __definePage("pages/splash/splash", PagesSplashSplash);
  __definePage("pages/login/login", PagesLoginLogin);
  __definePage("pages/register/register", PagesRegisterRegister);
  __definePage("pages/forgot-password/forgot-password", PagesForgotPasswordForgotPassword);
  __definePage("pages/device-list/device-list", PagesDeviceListDeviceList);
  __definePage("pages/scan/scan", PagesScanScan);
  __definePage("pages/config/config", PagesConfigConfig);
  __definePage("pages/device-control/device-control", PagesDeviceControlDeviceControl);
  __definePage("pages/settings/settings", PagesSettingsSettings);
  __definePage("pages/about/about", PagesAboutAbout);
  __definePage("pages/profile/profile", PagesProfileProfile);
  function formatAppLog(type, filename, ...args) {
    if (uni.__log__) {
      uni.__log__(type, filename, ...args);
    } else {
      console[type].apply(console, [...args, filename]);
    }
  }
  const _sfc_main = {
    onLaunch: function() {
      formatAppLog("log", "at App.vue:4", "App Launch");
    },
    onShow: function() {
      formatAppLog("log", "at App.vue:7", "App Show");
    },
    onHide: function() {
      formatAppLog("log", "at App.vue:10", "App Hide");
    }
  };
  const App = /* @__PURE__ */ _export_sfc(_sfc_main, [["__file", "E:/project/xf/IOT/open-iot-platform/app/uniapp/iotconfigapp/App.vue"]]);
  function createApp() {
    const app = vue.createVueApp(App);
    return {
      app
    };
  }
  const { app: __app__, Vuex: __Vuex__, Pinia: __Pinia__ } = createApp();
  uni.Vuex = __Vuex__;
  uni.Pinia = __Pinia__;
  __app__.provide("__globalStyles", __uniConfig.styles);
  __app__._component.mpType = "app";
  __app__._component.render = () => {
  };
  __app__.mount("#app");
})(Vue);
