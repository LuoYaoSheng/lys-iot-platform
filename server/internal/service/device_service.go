// 设备服务层
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"strings"
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
	deviceRepo  *repository.DeviceRepository
	productRepo *repository.ProductRepository
	mqttPort    int
}

func NewDeviceService(
	deviceRepo *repository.DeviceRepository,
	productRepo *repository.ProductRepository,
	mqttPort int,
) *DeviceService {
	return &DeviceService{
		deviceRepo:  deviceRepo,
		productRepo: productRepo,
		mqttPort:    mqttPort,
	}
}

// Activate 设备激活（向后兼容方法，使用默认主机名）
func (s *DeviceService) Activate(req *ActivationRequest) (*ActivationResponse, bool, error) {
	return s.ActivateWithHost(req, "")
}

// ActivateWithHost 设备激活（指定主机名）
func (s *DeviceService) ActivateWithHost(req *ActivationRequest, mqttHost string) (*ActivationResponse, bool, error) {
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
		resp := s.buildActivationResponse(existingDevice, mqttHost)
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

	// 保存设备（处理并发导致的唯一约束冲突）
	if existingDevice != nil {
		err = s.deviceRepo.Update(device)
	} else {
		err = s.deviceRepo.Create(device)
		// 如果遇到唯一约束冲突（MySQL 1062），说明并发创建了相同设备
		// 重新查询并更新
		if err != nil && isDuplicateKeyError(err) {
			log.Printf("[Activate] Duplicate key detected for %s/%s, re-querying...", req.ProductKey, req.DeviceSN)
			existingDevice, err = s.deviceRepo.FindByDeviceSN(req.ProductKey, req.DeviceSN)
			if err != nil {
				return nil, false, err
			}
			// 使用已存在的设备
			device = existingDevice
			// 更新凭证
			device.DeviceSecret = s.generateSecret()
			device.MQTTUsername = fmt.Sprintf("%s&%s", req.ProductKey, device.DeviceID)
			device.MQTTPassword = s.generateToken()
			device.MQTTClientID = fmt.Sprintf("%s&%s", req.ProductKey, device.DeviceID)
			device.FirmwareVersion = req.FirmwareVersion
			device.ChipModel = req.ChipModel
			device.Status = model.DeviceStatusOffline
			device.ActivatedAt = &now
			err = s.deviceRepo.Update(device)
		}
	}

	if err != nil {
		return nil, false, err
	}

	resp := s.buildActivationResponse(device, mqttHost)
	return resp, false, nil
}

// isDuplicateKeyError 检查是否是唯一约束冲突错误
func isDuplicateKeyError(err error) bool {
	if err == nil {
		return false
	}
	// MySQL duplicate key error code is 1062
	return strings.Contains(err.Error(), "Error 1062") ||
		strings.Contains(err.Error(), "duplicate key") ||
		strings.Contains(err.Error(), "Duplicate entry")
}

// buildActivationResponse 构建激活响应
func (s *DeviceService) buildActivationResponse(device *model.Device, mqttHost string) *ActivationResponse {
	// 如果未指定主机名，使用 localhost（默认情况）
	if mqttHost == "" {
		mqttHost = "localhost"
	}

	return &ActivationResponse{
		DeviceID:     device.DeviceID,
		DeviceSecret: device.DeviceSecret,
		MQTT: MQTTConfig{
			Server:    mqttHost, // 使用传入的主机名
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

// UpdateLastOnline 更新设备最后在线时间
func (s *DeviceService) UpdateLastOnline(deviceID string) error {
	return s.deviceRepo.UpdateLastOnline(deviceID)
}

// CheckOfflineDevices 检查离线设备（超过 timeout 时间未活动的设备标记为离线）
func (s *DeviceService) CheckOfflineDevices(timeout time.Duration) ([]string, error) {
	// 获取所有在线设备
	devices, err := s.deviceRepo.FindByStatus(model.DeviceStatusOnline)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	offlineDevices := make([]string, 0)

	for _, device := range devices {
		// 检查最后在线时间
		if device.LastOnlineAt == nil {
			// 没有最后在线时间记录，标记为离线
			offlineDevices = append(offlineDevices, device.DeviceID)
			s.deviceRepo.UpdateStatus(device.DeviceID, model.DeviceStatusOffline)
			log.Printf("[Device] Device %s marked offline (no last_online)", device.DeviceID)
			continue
		}

		// 如果超过 timeout 时间未活动，标记为离线
		if now.Sub(*device.LastOnlineAt) > timeout {
			offlineDevices = append(offlineDevices, device.DeviceID)
			s.deviceRepo.UpdateStatus(device.DeviceID, model.DeviceStatusOffline)
			log.Printf("[Device] Device %s marked offline (inactive for %v)", device.DeviceID, now.Sub(*device.LastOnlineAt))
		}
	}

	return offlineDevices, nil
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
	DeviceID        string        `json:"deviceId"`
	DeviceSN        string        `json:"deviceSN"` // 与 SDK Device 模型一致
	ProductKey      string        `json:"productKey"`
	ProjectID       string        `json:"projectId"`
	Name            string        `json:"name"`
	Status          string        `json:"status"` // 字符串类型: inactive/online/offline/disabled
	StatusText      string        `json:"statusText"`
	FirmwareVersion string        `json:"firmwareVersion"`
	ChipModel       string        `json:"chipModel"`
	LastOnlineAt    *string       `json:"lastOnlineAt"`
	ActivatedAt     *string       `json:"activatedAt"`
	CreatedAt       string        `json:"createdAt"`
	Product         *ProductInfo  `json:"product,omitempty"` // v0.2.0: 产品信息
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
		Total:   total,
		Page:    page,
		Size:    size,
		List: deviceInfos,
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
		ProjectID:       d.ProjectID,
		Name:            d.Name,
		Status:          s.getStatusString(d.Status), // 返回字符串状态
		StatusText:      s.getStatusText(d.Status),
		FirmwareVersion: d.FirmwareVersion,
		ChipModel:       d.ChipModel,
		CreatedAt:       d.CreatedAt.Format(time.RFC3339),
	}

	if d.LastOnlineAt != nil {
		t := d.LastOnlineAt.Format(time.RFC3339)
		info.LastOnlineAt = &t
	}
	if d.ActivatedAt != nil {
		t := d.ActivatedAt.Format(time.RFC3339)
		info.ActivatedAt = &t
	}

	// 查询产品信息
	product, err := s.productRepo.FindByProductKey(d.ProductKey)
	if err == nil {
		info.Product = &ProductInfo{
			ID:           product.ID,
			ProductKey:   product.ProductKey,
			Name:         product.Name,
			Description:  product.Description,
			Category:     product.Category,
			ControlMode:  product.ControlMode,
			UITemplate:   product.UITemplate,
			IconName:     product.IconName,
			IconColor:    product.IconColor,
			Manufacturer: product.Manufacturer,
			Model:        product.Model,
		}
	}

	return info
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

// BuildControlMessage 构建控制消息（返回topic和payload）
func (s *DeviceService) BuildControlMessage(deviceID string, req *ControlRequest) (string, map[string]interface{}, error) {
	// 1. 验证设备存在
	device, err := s.deviceRepo.FindByDeviceID(deviceID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", nil, errors.New("device_not_found")
		}
		return "", nil, err
	}

	// 2. 验证设备状态
	if device.Status == model.DeviceStatusInactive {
		return "", nil, errors.New("device_not_activated")
	}
	if device.Status == model.DeviceStatusDisabled {
		return "", nil, errors.New("device_disabled")
	}

	// 3. 构建控制参数
	params := make(map[string]interface{})

	// 新协议：支持 action 参数
	if req.Action != nil {
		// trigger 操作转换为 wakeup 命令（USB唤醒设备）
		if *req.Action == "trigger" {
			params["wakeup"] = true
		} else {
			params["action"] = *req.Action

			if *req.Action == "toggle" && req.Position != nil {
				params["position"] = *req.Position
			} else if *req.Action == "pulse" {
				if req.Duration != nil {
					params["duration"] = *req.Duration
				} else {
					params["duration"] = 500
				}
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
		return "", nil, errors.New("no_control_params")
	}

	// 4. 构建topic和payload
	topic := fmt.Sprintf("/sys/%s/%s/thing/service/property/set", device.ProductKey, device.DeviceID)
	payload := map[string]interface{}{
		"method": "thing.service.property.set",
		"id":     fmt.Sprintf("%d", time.Now().UnixMilli()),
		"params": params,
	}

	return topic, payload, nil
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
		position = property.Value
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
