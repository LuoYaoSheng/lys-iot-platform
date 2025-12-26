#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def modify_control_request():
    file_path = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 精确替换 ControlRequest 结构
    old_struct = '''// ControlRequest 控制请求
type ControlRequest struct {
	// 新协议:支持 action 参数
	Action   *string `json:"action"`   // toggle 或 pulse
	Position *string `json:"position"` // toggle 模式:up/middle/down
	Duration *int    `json:"duration"` // pulse 模式:延迟时间(毫秒)

	// 兼容旧协议
	Switch *bool `json:"switch"`
	Angle  *int  `json:"angle"`
}'''

    new_struct = '''// ControlRequest 控制请求
type ControlRequest struct {
	// v0.3.0 Thing Model service invocation protocol
	Service *string                `json:"service,omitempty"` // Service identifier, e.g. "toggle", "pulse", "setColor"
	Params  map[string]interface{} `json:"params,omitempty"`  // Service parameters, validated against Thing Model

	// v0.2.0 Compatible protocol: action parameter
	Action   *string `json:"action,omitempty"`   // toggle or pulse
	Position *string `json:"position,omitempty"` // toggle mode: up/middle/down
	Duration *int    `json:"duration,omitempty"` // pulse mode: delay time (ms)

	// v0.1.0 Compatible old protocol
	Switch *bool `json:"switch,omitempty"`
	Angle  *int  `json:"angle,omitempty"`
}'''

    # 替换 (注意处理中文冒号)
    content = content.replace(old_struct.replace(':','：'), new_struct)
    # 如果上面没匹配到,尝试英文冒号版本
    content = content.replace(old_struct, new_struct)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("SUCCESS: ControlRequest structure modified with Thing Model support")

if __name__ == '__main__':
    modify_control_request()
