// EMQX Webhook 处理器
// 作者: 罗耀生
// 日期: 2025-12-14
// 用于接收 EMQX 的消息事件和客户端上下线事件

package handler

import (
	"encoding/json"
	"log"
	"strings"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
	"iot-platform-core/pkg/response"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// WebhookHandler Webhook处理器
type WebhookHandler struct {
	db         *gorm.DB
	deviceRepo *repository.DeviceRepository
}

func NewWebhookHandler(db *gorm.DB, deviceRepo *repository.DeviceRepository) *WebhookHandler {
	return &WebhookHandler{
		db:         db,
		deviceRepo: deviceRepo,
	}
}

// ========== EMQX Webhook 数据结构 ==========

// EMQXClientEvent 客户端上下线事件
// 支持EMQX默认Webhook格式和自定义格式
type EMQXClientEvent struct {
	Event          string `json:"event"`                    // client.connected / client.disconnected
	ClientID       string `json:"clientid"`                 // 客户端ID
	Username       string `json:"username"`                 // 用户名
	IPAddress      string `json:"ipaddress"`                // IP地址（自定义格式）
	PeerHost       string `json:"peerhost"`                 // IP地址（EMQX默认格式）
	Timestamp      int64  `json:"timestamp"`                // 时间戳(毫秒)
	Reason         string `json:"reason"`                   // 断开原因（仅断开时有）
	ConnectedAt    int64  `json:"connected_at,omitempty"`   // 连接时间
	DisconnectedAt int64  `json:"disconnected_at,omitempty"` // 断开时间
}

// EMQXMessageEvent 消息事件
type EMQXMessageEvent struct {
	Event     string `json:"event"`     // message.publish
	ClientID  string `json:"clientid"`  // 客户端ID
	Username  string `json:"username"`  // 用户名
	Topic     string `json:"topic"`     // 主题
	Payload   string `json:"payload"`   // 消息内容
	Timestamp int64  `json:"timestamp"` // 时间戳(毫秒)
	QoS       int    `json:"qos"`       // QoS等级
}

// ========== Webhook 端点 ==========

// HandleClientEvent 处理客户端上下线事件
// POST /api/v1/webhook/client
func (h *WebhookHandler) HandleClientEvent(c *gin.Context) {
	var event EMQXClientEvent
	if err := c.ShouldBindJSON(&event); err != nil {
		log.Printf("[Webhook] 解析客户端事件失败: %v", err)
		response.BadRequest(c, "invalid_request")
		return
	}

	// 兼容EMQX默认格式（peerhost）和自定义格式（ipaddress）
	if event.PeerHost != "" && event.IPAddress == "" {
		event.IPAddress = event.PeerHost
	}

	log.Printf("[Webhook] 客户端事件: %s, clientId=%s, username=%s, ip=%s",
		event.Event, event.ClientID, event.Username, event.IPAddress)

	// 解析 username 获取设备信息 (格式: productKey&deviceId)
	parts := strings.Split(event.Username, "&")
	if len(parts) != 2 {
		log.Printf("[Webhook] 无效的 username 格式: %s", event.Username)
		response.Success(c, gin.H{"message": "ignored"})
		return
	}

	productKey := parts[0]
	deviceID := parts[1]

	// 获取设备
	device, err := h.deviceRepo.FindByProductKeyAndDeviceID(productKey, deviceID)
	if err != nil {
		log.Printf("[Webhook] 设备不存在: productKey=%s, deviceId=%s", productKey, deviceID)
		response.Success(c, gin.H{"message": "device_not_found"})
		return
	}

	now := time.Now()
	eventTime := time.UnixMilli(event.Timestamp)

	switch event.Event {
	case "client.connected":
		// 设备上线
		device.Status = model.DeviceStatusOnline
		device.LastOnlineAt = &now
		h.db.Save(device)

		// 记录事件
		h.saveDeviceEvent(device.DeviceID, "online", gin.H{
			"ip":          event.IPAddress,
			"connectedAt": eventTime.Format(time.RFC3339),
		})

		log.Printf("[Webhook] 设备上线: %s", device.DeviceID)

	case "client.disconnected":
		// 设备下线
		device.Status = model.DeviceStatusOffline
		h.db.Save(device)

		// 记录事件
		h.saveDeviceEvent(device.DeviceID, "offline", gin.H{
			"reason":         event.Reason,
			"disconnectedAt": eventTime.Format(time.RFC3339),
		})

		log.Printf("[Webhook] 设备下线: %s, reason=%s", device.DeviceID, event.Reason)
	}

	response.Success(c, gin.H{"message": "ok"})
}

// HandleMessageEvent 处理消息事件
// POST /api/v1/webhook/message
func (h *WebhookHandler) HandleMessageEvent(c *gin.Context) {
	var event EMQXMessageEvent
	if err := c.ShouldBindJSON(&event); err != nil {
		log.Printf("[Webhook] 解析消息事件失败: %v", err)
		response.BadRequest(c, "invalid_request")
		return
	}

	log.Printf("[Webhook] 消息事件: topic=%s, clientId=%s", event.Topic, event.ClientID)

	// 解析 topic 获取设备信息
	// 格式: /sys/{productKey}/{deviceId}/thing/event/property/post
	topicParts := strings.Split(event.Topic, "/")
	if len(topicParts) < 4 {
		log.Printf("[Webhook] 无效的 topic 格式: %s", event.Topic)
		response.Success(c, gin.H{"message": "ignored"})
		return
	}

	productKey := topicParts[2]
	deviceID := topicParts[3]

	// 验证设备存在
	device, err := h.deviceRepo.FindByProductKeyAndDeviceID(productKey, deviceID)
	if err != nil {
		log.Printf("[Webhook] 设备不存在: productKey=%s, deviceId=%s", productKey, deviceID)
		response.Success(c, gin.H{"message": "device_not_found"})
		return
	}

	// 解析消息内容
	var payload map[string]interface{}
	if err := json.Unmarshal([]byte(event.Payload), &payload); err != nil {
		log.Printf("[Webhook] 解析 payload 失败: %v", err)
		// 如果不是JSON，直接存储原始内容
		payload = map[string]interface{}{"raw": event.Payload}
	}

	// 判断消息类型
	if strings.Contains(event.Topic, "/thing/event/property/post") {
		// 属性上报
		h.handlePropertyReport(device.DeviceID, payload)
	} else if strings.Contains(event.Topic, "/thing/event/") {
		// 事件上报
		h.handleEventReport(device.DeviceID, event.Topic, payload)
	}

	response.Success(c, gin.H{"message": "ok"})
}

// handlePropertyReport 处理属性上报
func (h *WebhookHandler) handlePropertyReport(deviceID string, payload map[string]interface{}) {
	now := time.Now()

	for key, value := range payload {
		// 跳过时间戳等元数据
		if key == "timestamp" || key == "id" || key == "version" {
			continue
		}

		valueBytes, _ := json.Marshal(value)
		valueStr := string(valueBytes)

		// 更新或插入属性
		var prop model.DeviceProperty
		err := h.db.Where("device_id = ? AND property_id = ?", deviceID, key).First(&prop).Error

		if err == gorm.ErrRecordNotFound {
			// 新建
			prop = model.DeviceProperty{
				DeviceID:   deviceID,
				PropertyID: key,
				Value:      valueStr,
				ReportedAt: now,
			}
			h.db.Create(&prop)
		} else if err == nil {
			// 更新
			prop.Value = valueStr
			prop.ReportedAt = now
			h.db.Save(&prop)
		}

		log.Printf("[Webhook] 属性更新: deviceId=%s, %s=%s", deviceID, key, valueStr)
	}

	// 记录事件
	h.saveDeviceEvent(deviceID, "property_report", payload)
}

// handleEventReport 处理事件上报
func (h *WebhookHandler) handleEventReport(deviceID, topic string, payload map[string]interface{}) {
	// 从 topic 提取事件类型
	// /sys/{pk}/{did}/thing/event/{eventId}/post
	parts := strings.Split(topic, "/")
	eventType := "unknown"
	for i, p := range parts {
		if p == "event" && i+1 < len(parts) {
			eventType = parts[i+1]
			break
		}
	}

	h.saveDeviceEvent(deviceID, eventType, payload)
	log.Printf("[Webhook] 事件上报: deviceId=%s, type=%s", deviceID, eventType)
}

// saveDeviceEvent 保存设备事件
func (h *WebhookHandler) saveDeviceEvent(deviceID, eventType string, payload interface{}) {
	payloadBytes, _ := json.Marshal(payload)

	event := &model.DeviceEvent{
		DeviceID:  deviceID,
		EventType: eventType,
		Payload:   string(payloadBytes),
		CreatedAt: time.Now(),
	}

	if err := h.db.Create(event).Error; err != nil {
		log.Printf("[Webhook] 保存事件失败: %v", err)
	}
}

// GetDeviceProperties 获取设备最新属性
// GET /api/v1/devices/:deviceId/properties
func (h *WebhookHandler) GetDeviceProperties(c *gin.Context) {
	deviceID := c.Param("deviceId")
	if deviceID == "" {
		response.BadRequest(c, "device_id_required")
		return
	}

	var properties []model.DeviceProperty
	if err := h.db.Where("device_id = ?", deviceID).Find(&properties).Error; err != nil {
		response.InternalError(c, err.Error())
		return
	}

	// 转换为 map 格式
	result := make(map[string]interface{})
	for _, prop := range properties {
		var value interface{}
		if err := json.Unmarshal([]byte(prop.Value), &value); err != nil {
			value = prop.Value
		}
		result[prop.PropertyID] = gin.H{
			"value":      value,
			"reportedAt": prop.ReportedAt.Format("2006-01-02 15:04:05"),
		}
	}

	response.Success(c, result)
}

// GetDeviceEvents 获取设备事件列表
// GET /api/v1/devices/:deviceId/events
func (h *WebhookHandler) GetDeviceEvents(c *gin.Context) {
	deviceID := c.Param("deviceId")
	if deviceID == "" {
		response.BadRequest(c, "device_id_required")
		return
	}

	limit := 50 // 默认返回最近50条
	var events []model.DeviceEvent
	if err := h.db.Where("device_id = ?", deviceID).
		Order("created_at DESC").
		Limit(limit).
		Find(&events).Error; err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.Success(c, events)
}
