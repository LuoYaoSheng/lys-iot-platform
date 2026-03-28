// 设备服务层
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
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
)

// ActivationRequest 激活请求
type ActivationRequest struct {
	ProductKey      string `json:"productKey" binding:"required"`
	DeviceSN        string `json:"deviceSN" binding:"required"`
	FirmwareVersion string `json:"firmwareVersion" binding:"required"`
	ChipModel       string `json:"chipModel"`
}

// ActivationResponse 激活响应
type ActivationResponse struct {
	DeviceID     string       `json:"deviceId"`
	DeviceSecret string       `json:"deviceSecret"`
	MQTT         MQTTConfig   `json:"mqtt"`
	Topics       TopicsConfig `json:"topics"`
}

type MQTTConfig struct {
	Server    string `json:"server"`
	Port      int    `json:"port"`
	PortTLS   int    `json:"portTLS"`
	Username  string `json:"username"`
	Password  string `json:"password"`
	ClientID  string `json:"clientId"`
	KeepAlive int    `json:"keepAlive"`
}

type TopicsConfig struct {
	PropertyPost string `json:"propertyPost"`
	PropertySet  string `json:"propertySet"`
	Status       string `json:"status"`
}

// DeviceService 设备服务
type DeviceService struct {
	deviceRepo         *repository.DeviceRepository
	productRepo        *repository.ProductRepository
	mqttBroker         string // 内部地址
	mqttBrokerExternal string // 外部地址 (设备连接用)
	mqttPort           int
}

func NewDeviceService(
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
}

// Activate 设备激活
func (s *DeviceService) Activate(req *ActivationRequest) (*ActivationResponse, bool, error) {
	// 1. 验证产品是否存在
	product, err := s.productRepo.FindByProductKey(req.ProductKey)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, false, errors.New("invalid_product_key")
		}
		return nil, false, err
	}

	if product.Status != 1 {
		return nil, false, errors.New("product_disabled")
	}

	// 2. 检查设备是否已存在
	existingDevice, err := s.deviceRepo.FindByDeviceSN(req.ProductKey, req.DeviceSN)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, false, err
	}

	// 3. 如果设备已存在且已激活，返回现有配置
	if existingDevice != nil && existingDevice.Status != model.DeviceStatusInactive {
		resp := s.buildActivationResponse(existingDevice)
		return resp, true, nil // isAlreadyActivated = true
	}

	// 4. 创建或更新设备
	var device *model.Device
	if existingDevice != nil {
		device = existingDevice
	} else {
		device = &model.Device{
			DeviceID:   s.generateDeviceID(),
			DeviceSN:   req.DeviceSN,
			ProductKey: req.ProductKey,
		}
	}

	// 生成凭证
	device.DeviceSecret = s.generateSecret()
	device.MQTTUsername = fmt.Sprintf("%s&%s", req.ProductKey, device.DeviceID)
	device.MQTTPassword = s.generateToken()
	device.MQTTClientID = fmt.Sprintf("%s&%s", req.ProductKey, device.DeviceID)
	device.FirmwareVersion = req.FirmwareVersion
	device.ChipModel = req.ChipModel
	device.Status = model.DeviceStatusOffline

	now := time.Now()
	device.ActivatedAt = &now

	// 保存设备
	if existingDevice != nil {
		err = s.deviceRepo.Update(device)
	} else {
		err = s.deviceRepo.Create(device)
	}

	if err != nil {
		return nil, false, err
	}

	resp := s.buildActivationResponse(device)
	return resp, false, nil
}

// buildActivationResponse 构建激活响应
func (s *DeviceService) buildActivationResponse(device *model.Device) *ActivationResponse {
	return &ActivationResponse{
		DeviceID:     device.DeviceID,
		DeviceSecret: device.DeviceSecret,
		MQTT: MQTTConfig{
			Server:    s.mqttBrokerExternal, // 使用外部地址
			Port:      s.mqttPort,
			PortTLS:   8883,
			Username:  device.MQTTUsername,
			Password:  device.MQTTPassword,
			ClientID:  device.MQTTClientID,
			KeepAlive: 60,
		},
		Topics: TopicsConfig{
			PropertyPost: fmt.Sprintf("/sys/%s/%s/thing/event/property/post", device.ProductKey, device.DeviceID),
			PropertySet:  fmt.Sprintf("/sys/%s/%s/thing/service/property/set", device.ProductKey, device.DeviceID),
			Status:       fmt.Sprintf("/sys/%s/%s/status", device.ProductKey, device.DeviceID),
		},
	}
}

// generateDeviceID 生成设备ID
func (s *DeviceService) generateDeviceID() string {
	return "dev_" + uuid.New().String()[:8]
}

// generateSecret 生成密钥
func (s *DeviceService) generateSecret() string {
	bytes := make([]byte, 16)
	rand.Read(bytes)
	return "sk_" + hex.EncodeToString(bytes)
}

// generateToken 生成Token
func (s *DeviceService) generateToken() string {
	bytes := make([]byte, 24)
	rand.Read(bytes)
	return "tk_" + hex.EncodeToString(bytes)
}

// ValidateMQTTAuth 验证MQTT认证
func (s *DeviceService) ValidateMQTTAuth(username, password, clientID string) (*model.Device, error) {
	device, err := s.deviceRepo.FindByMQTTUsername(username)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("device_not_found")
		}
		return nil, err
	}

	// 验证密码
	if device.MQTTPassword != password {
		return nil, errors.New("invalid_password")
	}

	// 验证 ClientID
	if device.MQTTClientID != clientID {
		return nil, errors.New("invalid_client_id")
	}

	// 验证设备状态
	if device.Status == model.DeviceStatusDisabled {
		return nil, errors.New("device_disabled")
	}

	return device, nil
}

// ValidateMQTTACL 验证MQTT ACL
func (s *DeviceService) ValidateMQTTACL(username, topic, action string) (bool, error) {
	device, err := s.deviceRepo.FindByMQTTUsername(username)
	if err != nil {
		return false, err
	}

	// 构建允许的topic前缀
	allowedPrefix := fmt.Sprintf("/sys/%s/%s/", device.ProductKey, device.DeviceID)

	// 检查topic是否在允许范围内
	if len(topic) >= len(allowedPrefix) && topic[:len(allowedPrefix)] == allowedPrefix {
		return true, nil
	}

	return false, nil
}

// UpdateDeviceOnline 更新设备在线状态
func (s *DeviceService) UpdateDeviceOnline(deviceID string, online bool) error {
	var status model.DeviceStatus
	if online {
		status = model.DeviceStatusOnline
	} else {
		status = model.DeviceStatusOffline
	}
	return s.deviceRepo.UpdateStatus(deviceID, status)
}

// ========== 新增：设备列表和详情 ==========

// DeviceListResponse 设备列表响应
// 字段命名遵循 SDK PagedResponse 标准格式
type DeviceListResponse struct {
	Total int64        `json:"total"`
	Page  int          `json:"page"`
	Size  int          `json:"size"`
	List  []DeviceInfo `json:"list"` // SDK 标准字段名
}

// DeviceInfo 设备信息
type DeviceInfo struct {
	DeviceID        string          `json:"deviceId"`
	DeviceSN        string          `json:"deviceSN"` // 与 SDK Device 模型一致
	ProductKey      string          `json:"productKey"`
	Name            string          `json:"name"`
	Product         *ProductSummary `json:"product,omitempty"`
	Status          string          `json:"status"` // 字符串类型: inactive/online/offline/disabled
	StatusText      string          `json:"statusText"`
	FirmwareVersion string          `json:"firmwareVersion"`
	ChipModel       string          `json:"chipModel"`
	LastOnlineAt    *string         `json:"lastOnlineAt"`
	ActivatedAt     *string         `json:"activatedAt"`
	CreatedAt       string          `json:"createdAt"`
}

type ProductSummary struct {
	ProductKey   string                 `json:"productKey"`
	Name         string                 `json:"name"`
	Description  string                 `json:"description,omitempty"`
	Category     string                 `json:"category"`
	ControlMode  string                 `json:"controlMode,omitempty"`
	UITemplate   string                 `json:"uiTemplate,omitempty"`
	IconName     string                 `json:"iconName,omitempty"`
	IconColor    string                 `json:"iconColor,omitempty"`
	Capabilities map[string]interface{} `json:"capabilities,omitempty"`
	NodeType     string                 `json:"nodeType,omitempty"`
	Status       int                    `json:"status"`
}

// GetDeviceList 获取设备列表
func (s *DeviceService) GetDeviceList(productKey string, status *model.DeviceStatus, page, size int) (*DeviceListResponse, error) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}

	offset := (page - 1) * size
	devices, total, err := s.deviceRepo.FindAll(productKey, status, size, offset)
	if err != nil {
		return nil, err
	}

	// 转换为响应格式
	deviceInfos := make([]DeviceInfo, len(devices))
	for i, d := range devices {
		deviceInfos[i] = s.toDeviceInfo(&d)
	}

	return &DeviceListResponse{
		Total: total,
		Page:  page,
		Size:  size,
		List:  deviceInfos,
	}, nil
}

// GetDeviceByID 获取设备详情
func (s *DeviceService) GetDeviceByID(deviceID string) (*DeviceInfo, error) {
	device, err := s.deviceRepo.FindByDeviceID(deviceID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("device_not_found")
		}
		return nil, err
	}

	info := s.toDeviceInfo(device)
	return &info, nil
}

// toDeviceInfo 转换设备信息
func (s *DeviceService) toDeviceInfo(d *model.Device) DeviceInfo {
	info := DeviceInfo{
		DeviceID:        d.DeviceID,
		DeviceSN:        d.DeviceSN,
		ProductKey:      d.ProductKey,
		Name:            d.Name,
		Status:          s.getStatusString(d.Status), // 返回字符串状态
		StatusText:      s.getStatusText(d.Status),
		FirmwareVersion: d.FirmwareVersion,
		ChipModel:       d.ChipModel,
		CreatedAt:       d.CreatedAt.Format("2006-01-02 15:04:05"),
	}

	if d.Product != nil {
		info.Product = toProductSummary(d.Product)
	} else if s.productRepo != nil {
		if product, err := s.productRepo.FindByProductKey(d.ProductKey); err == nil {
			info.Product = toProductSummary(product)
		}
	}

	if d.LastOnlineAt != nil {
		t := d.LastOnlineAt.Format("2006-01-02 15:04:05")
		info.LastOnlineAt = &t
	}
	if d.ActivatedAt != nil {
		t := d.ActivatedAt.Format("2006-01-02 15:04:05")
		info.ActivatedAt = &t
	}

	return info
}

func toProductSummary(product *model.Product) *ProductSummary {
	summary := &ProductSummary{
		ProductKey:  product.ProductKey,
		Name:        product.Name,
		Description: product.Description,
		Category:    product.Category,
		ControlMode: product.ControlMode,
		UITemplate:  product.UITemplate,
		IconName:    product.IconName,
		IconColor:   product.IconColor,
		NodeType:    product.NodeType,
		Status:      product.Status,
	}

	if product.Capabilities != "" {
		var capabilities map[string]interface{}
		if err := json.Unmarshal([]byte(product.Capabilities), &capabilities); err == nil {
			summary.Capabilities = capabilities
		}
	}

	return summary
}

// getStatusString 获取状态字符串 (SDK 格式)
func (s *DeviceService) getStatusString(status model.DeviceStatus) string {
	switch status {
	case model.DeviceStatusInactive:
		return "inactive"
	case model.DeviceStatusOnline:
		return "online"
	case model.DeviceStatusOffline:
		return "offline"
	case model.DeviceStatusDisabled:
		return "disabled"
	default:
		return "inactive"
	}
}

// getStatusText 获取状态文本
func (s *DeviceService) getStatusText(status model.DeviceStatus) string {
	switch status {
	case model.DeviceStatusInactive:
		return "未激活"
	case model.DeviceStatusOnline:
		return "在线"
	case model.DeviceStatusOffline:
		return "离线"
	case model.DeviceStatusDisabled:
		return "已禁用"
	default:
		return "未知"
	}
}

// ========== 新增：设备控制 ==========

// ControlRequest 控制请求
type ControlRequest struct {
	// 新协议：支持 action 参数
	Action   *string `json:"action"`   // toggle 或 pulse
	Position *string `json:"position"` // toggle 模式：up/middle/down
	Duration *int    `json:"duration"` // pulse 模式：延迟时间（毫秒）

	// 兼容旧协议
	Switch *bool `json:"switch"`
	Angle  *int  `json:"angle"`
}

// ControlDevice 控制设备（通过 MQTT 发布指令）
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

	// 新协议：支持 action 参数
	if req.Action != nil {
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
		// 兼容旧协议
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
	return mqttService.PublishDeviceControl(device.ProductKey, device.DeviceID, params)
}

// GetDeviceStatus 获取设备状态
func (s *DeviceService) GetDeviceStatus(deviceID string) (map[string]interface{}, error) {
	// 1. 获取设备基本信息
	device, err := s.deviceRepo.FindByDeviceID(deviceID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("device_not_found")
		}
		return nil, err
	}

	// 2. 获取设备属性（position）
	property, err := s.deviceRepo.GetDeviceProperty(deviceID, "position")
	position := "middle" // 默认值
	if err == nil && property != nil {
		if decoded, ok := decodeStoredStringValue(property.Value); ok && decoded != "" {
			position = decoded
		} else if property.Value != "" {
			position = property.Value
		}
	}

	// 3. 构建响应
	status := map[string]interface{}{
		"deviceId":   device.DeviceID,
		"deviceName": device.Name,
		"online":     device.Status == model.DeviceStatusOnline,
		"position":   position,
		"status":     s.getStatusString(device.Status),
	}

	if device.LastOnlineAt != nil {
		status["lastOnlineAt"] = device.LastOnlineAt.Format(time.RFC3339)
	}

	return status, nil
}

func decodeStoredStringValue(raw string) (string, bool) {
	var decoded string
	if err := json.Unmarshal([]byte(raw), &decoded); err == nil {
		return decoded, true
	}
	return "", false
}

// UpdateDeviceProperty 更新设备属性
func (s *DeviceService) UpdateDeviceProperty(deviceID, propertyID, value string) error {
	return s.deviceRepo.UpdateDeviceProperty(deviceID, propertyID, value)
}

// DeleteDevice 删除设备
func (s *DeviceService) DeleteDevice(deviceID string) error {
	device, err := s.deviceRepo.FindByDeviceID(deviceID)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return errors.New("device_not_found")
		}
		return err
	}

	return s.deviceRepo.Delete(device.ID)
}
