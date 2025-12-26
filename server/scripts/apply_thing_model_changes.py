#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 应用物模型服务调用支持的所有必要修改
# 作者: 罗耀生
# 日期: 2025-12-20

import re

def apply_changes():
    file_path = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. 添加 encoding/json 导入
    old_import = '''import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)'''

    new_import = '''import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)'''

    content = content.replace(old_import, new_import)
    print("OK 1. 添加 encoding/json 导入")

    # 2. 更新 DeviceService 结构体
    old_struct = '''// DeviceService 设备服务
type DeviceService struct {
    deviceRepo         *repository.DeviceRepository
    productRepo        *repository.ProductRepository
    mqttBroker         string // 内部地址
    mqttBrokerExternal string // 外部地址 (设备连接用)
    mqttPort           int
}'''

    new_struct = '''// DeviceService 设备服务
type DeviceService struct {
    deviceRepo         *repository.DeviceRepository
    productRepo        *repository.ProductRepository
    thingModelService  *ThingModelService
    db                 *gorm.DB
    mqttBroker         string // 内部地址
    mqttBrokerExternal string // 外部地址 (设备连接用)
    mqttPort           int
}'''

    content = content.replace(old_struct, new_struct)
    print("OK 2. 更新 DeviceService 结构体")

    # 3. 更新 NewDeviceService 构造函数
    old_constructor = '''func NewDeviceService(
    deviceRepo *repository.DeviceRepository,
    productRepo *repository.ProductRepository,
    mqttBroker string,
    mqttBrokerExternal string,
    mqttPort int,
) *DeviceService {
    return &DeviceService{
        deviceRepo:         deviceRepo,
        productRepo:        productRepo,
        mqttBroker:         mqttBroker,
        mqttBrokerExternal: mqttBrokerExternal,
        mqttPort:           mqttPort,
    }
}'''

    new_constructor = '''func NewDeviceService(
    deviceRepo *repository.DeviceRepository,
    productRepo *repository.ProductRepository,
    thingModelService *ThingModelService,
    db *gorm.DB,
    mqttBroker string,
    mqttBrokerExternal string,
    mqttPort int,
) *DeviceService {
    return &DeviceService{
        deviceRepo:         deviceRepo,
        productRepo:        productRepo,
        thingModelService:  thingModelService,
        db:                 db,
        mqttBroker:         mqttBroker,
        mqttBrokerExternal: mqttBrokerExternal,
        mqttPort:           mqttPort,
    }
}'''

    content = content.replace(old_constructor, new_constructor)
    print("OK 3. 更新 NewDeviceService 构造函数")

    # 4. 更新 ControlRequest 结构体
    old_control_req = '''// ControlRequest 控制请求
type ControlRequest struct {
	// 新协议：支持 action 参数
	Action   *string `json:"action"`   // toggle 或 pulse
	Position *string `json:"position"` // toggle 模式：up/middle/down
	Duration *int    `json:"duration"` // pulse 模式：延迟时间（毫秒）

	// 兼容旧协议
	Switch *bool `json:"switch"`
	Angle  *int  `json:"angle"`
}'''

    new_control_req = '''// ControlRequest 控制请求
type ControlRequest struct {
	// v0.3.0: 物模型服务调用
	Service *string                `json:"service"` // 服务标识符
	Params  map[string]interface{} `json:"params"`  // 服务参数

	// v0.2.0: action 参数
	Action   *string `json:"action"`   // toggle 或 pulse
	Position *string `json:"position"` // toggle 模式：up/middle/down
	Duration *int    `json:"duration"` // pulse 模式：延迟时间（毫秒）

	// v0.1.0: 兼容旧协议
	Switch *bool `json:"switch"`
	Angle  *int  `json:"angle"`
}'''

    content = content.replace(old_control_req, new_control_req)
    print("OK 4. 更新 ControlRequest 结构体")

    # 5. 替换 ControlDevice 方法
    # 使用正则表达式找到方法的开始和结束
    pattern = r'// ControlDevice 控制设备（通过 MQTT 发布指令）.*?(?=\\n// |\\n// =|$)'

    new_control_device = '''// ControlDevice 控制设备（通过 MQTT 发布指令）
// v0.3.0: 支持物模型服务调用
func (s *DeviceService) ControlDevice(deviceID string, req *ControlRequest, mqttService *MQTTService) error {
	// 1. 验证设备存在
	device, err := s.deviceRepo.FindByDeviceID(deviceID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("device_not_found")
		}
		return err
	}

	// 2. 验证设备状态
	if device.Status == model.DeviceStatusInactive {
		return errors.New("device_not_activated")
	}
	if device.Status == model.DeviceStatusDisabled {
		return errors.New("device_disabled")
	}

	// 3. 构建控制参数
	params := make(map[string]interface{})
	var serviceIdentifier string
	var invocationID int64

	// v0.3.0: 优先使用物模型服务调用协议
	if req.Service != nil && *req.Service != "" {
		serviceIdentifier = *req.Service

		// 3.1 验证服务是否存在
		productKey := device.ProductKey
		_, err := s.thingModelService.thingModelRepo.FindServiceByIdentifier(productKey, serviceIdentifier)
		if err != nil {
			return fmt.Errorf("service_not_found: %s", serviceIdentifier)
		}

		// 3.2 验证服务参数
		if req.Params == nil {
			req.Params = make(map[string]interface{})
		}
		if err := s.thingModelService.ValidateServiceParams(productKey, serviceIdentifier, req.Params); err != nil {
			return fmt.Errorf("invalid_service_params: %v", err)
		}

		// 3.3 记录服务调用日志（pending 状态）
		invocationLog := &model.ServiceInvocationLog{
			DeviceID:          deviceID,
			ServiceIdentifier: serviceIdentifier,
			Status:            model.ServiceStatusPending,
		}
		if len(req.Params) > 0 {
			paramsJSON, _ := json.Marshal(req.Params)
			paramsStr := string(paramsJSON)
			invocationLog.InputParams = &paramsStr
		}
		if err := s.db.Create(invocationLog).Error; err != nil {
			// 记录日志失败不影响控制指令发送
			fmt.Printf("[WARNING] Failed to create service invocation log: %v\\\n", err)
		} else {
			invocationID = invocationLog.ID
		}

		// 3.4 使用物模型参数
		params = req.Params
		params["service"] = serviceIdentifier

	} else if req.Action != nil {
		// v0.2.0 兼容协议：支持 action 参数
		params["action"] = *req.Action

		if *req.Action == "toggle" && req.Position != nil {
			// toggle 模式：切换到指定位置
			params["position"] = *req.Position
		} else if *req.Action == "pulse" {
			// pulse 模式：触发动作
			if req.Duration != nil {
				params["duration"] = *req.Duration
			} else {
				params["duration"] = 500 // 默认500ms
			}
		}
	} else {
		// v0.1.0 兼容旧协议
		if req.Switch != nil {
			params["switch"] = *req.Switch
		}
		if req.Angle != nil {
			angle := *req.Angle
			if angle < 0 {
				angle = 0
			} else if angle > 180 {
				angle = 180
			}
			params["angle"] = angle
		}
	}

	if len(params) == 0 {
		return errors.New("no_control_params")
	}

	// 4. 发布 MQTT 消息
	err = mqttService.PublishDeviceControl(device.ProductKey, device.DeviceID, params)

	// 5. 更新服务调用日志状态
	if invocationID > 0 {
		updateData := map[string]interface{}{}
		if err != nil {
			updateData["status"] = model.ServiceStatusFailed
			errMsg := err.Error()
			updateData["error_message"] = &errMsg
		} else {
			updateData["status"] = model.ServiceStatusSuccess
		}
		now := time.Now()
		updateData["completed_at"] = &now
		s.db.Model(&model.ServiceInvocationLog{}).Where("id = ?", invocationID).Updates(updateData)
	}

	return err
}'''

    content = re.sub(pattern, new_control_device, content, flags=re.DOTALL)
    print("OK 5. 替换 ControlDevice 方法")

    # 写回文件
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("\\nSUCCESS 所有修改应用成功！")
    print(f"文件已更新: {file_path}")

if __name__ == '__main__':
    apply_changes()
