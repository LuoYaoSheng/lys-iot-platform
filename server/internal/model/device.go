// 设备模型
// 作者: 罗耀生
// 日期: 2025-12-13

package model

import (
	"time"
)

// DeviceStatus 设备状态
type DeviceStatus int

const (
	DeviceStatusInactive DeviceStatus = 0 // 未激活
	DeviceStatusOnline   DeviceStatus = 1 // 在线
	DeviceStatusOffline  DeviceStatus = 2 // 离线
	DeviceStatusDisabled DeviceStatus = 3 // 禁用
)

// Product 产品
type Product struct {
	ID          int64     `gorm:"primaryKey" json:"id"`
	ProductKey  string    `gorm:"uniqueIndex;size:64" json:"productKey"`
	Name        string    `gorm:"size:128" json:"name"`
	Description string    `gorm:"type:text" json:"description"`
	Category    string    `gorm:"size:64" json:"category"`

	// v0.2.0 UI控制相关字段
	ControlMode  string `gorm:"size:32" json:"controlMode"`           // toggle/pulse/dimmer/readonly/generic
	UITemplate   string `gorm:"size:64" json:"uiTemplate"`            // UI模板名称
	IconName     string `gorm:"size:64" json:"iconName"`              // 图标名称(Material Icons)
	IconColor    string `gorm:"size:16" json:"iconColor"`             // 图标颜色(HEX，如 #FF6B35)
	Capabilities string `gorm:"type:text" json:"capabilities"`        // 产品能力定义(JSON)
	MQTTTopics   string `gorm:"type:text" json:"mqttTopics"`          // MQTT主题配置(JSON)
	Manufacturer string `gorm:"size:128" json:"manufacturer"`         // 制造商
	Model        string `gorm:"size:64" json:"model"`                 // 硬件型号

	Status    int       `gorm:"default:1" json:"status"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func (Product) TableName() string {
	return "products"
}

// Device 设备
type Device struct {
	ID              int64        `gorm:"primaryKey" json:"id"`
	DeviceID        string       `gorm:"uniqueIndex;size:64" json:"deviceId"`
	DeviceSN        string       `gorm:"size:64;uniqueIndex:idx_product_device" json:"deviceSN"`
	DeviceSecret    string       `gorm:"size:128" json:"-"`
	ProductKey      string       `gorm:"size:64;uniqueIndex:idx_product_device" json:"productKey"`
	ProjectID       string       `gorm:"index;size:64" json:"projectId"` // 所属项目
	Name            string       `gorm:"size:128" json:"name"`
	Status          DeviceStatus `gorm:"default:0" json:"status"`
	FirmwareVersion string       `gorm:"size:32" json:"firmwareVersion"`
	ChipModel       string       `gorm:"size:32" json:"chipModel"`
	MQTTUsername    string       `gorm:"size:128" json:"mqttUsername"`
	MQTTPassword    string       `gorm:"size:256" json:"-"`
	MQTTClientID    string       `gorm:"size:128" json:"mqttClientId"`
	LastOnlineAt    *time.Time   `json:"lastOnlineAt"`
	ActivatedAt     *time.Time   `json:"activatedAt"`
	CreatedAt       time.Time    `json:"createdAt"`
	UpdatedAt       time.Time    `json:"updatedAt"`
}

func (Device) TableName() string {
	return "devices"
}

// DeviceProperty 设备属性数据（设备上报的最新数据）
type DeviceProperty struct {
	ID         int64     `gorm:"primaryKey" json:"id"`
	DeviceID   string    `gorm:"uniqueIndex:idx_device_property;size:64" json:"deviceId"`
	PropertyID string    `gorm:"uniqueIndex:idx_device_property;size:64" json:"propertyId"` // 属性标识符
	Value      string    `gorm:"type:text" json:"value"`                                    // 属性值（JSON）
	ReportedAt time.Time `gorm:"index" json:"reportedAt"`                                   // 上报时间
	CreatedAt  time.Time `json:"createdAt"`
	UpdatedAt  time.Time `json:"updatedAt"`
}

func (DeviceProperty) TableName() string {
	return "device_properties"
}

// DeviceEvent 设备事件记录
type DeviceEvent struct {
	ID        int64     `gorm:"primaryKey" json:"id"`
	DeviceID  string    `gorm:"index;size:64" json:"deviceId"`
	EventType string    `gorm:"index;size:64" json:"eventType"` // 事件类型：online/offline/alert/property_report
	Payload   string    `gorm:"type:text" json:"payload"`       // 事件数据（JSON）
	CreatedAt time.Time `gorm:"index" json:"createdAt"`
}

func (DeviceEvent) TableName() string {
	return "device_events"
}

// MQTTAuthLog MQTT认证日志
type MQTTAuthLog struct {
	ID        int64     `gorm:"primaryKey" json:"id"`
	ClientID  string    `gorm:"index;size:128" json:"clientId"`
	Username  string    `gorm:"size:128" json:"username"`
	IPAddress string    `gorm:"size:64" json:"ipAddress"`
	Action    string    `gorm:"size:32" json:"action"`
	Topic     string    `gorm:"size:256" json:"topic"`
	Result    string    `gorm:"size:32" json:"result"`
	Reason    string    `gorm:"size:256" json:"reason"`
	CreatedAt time.Time `gorm:"index" json:"createdAt"`
}

func (MQTTAuthLog) TableName() string {
	return "mqtt_auth_logs"
}
