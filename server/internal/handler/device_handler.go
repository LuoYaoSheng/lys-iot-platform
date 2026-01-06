// 设备处理器
// 作者: 罗耀生
// 日期: 2025-12-13

package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/mqtt"
	"iot-platform-core/internal/repository"
	"iot-platform-core/internal/service"
	"iot-platform-core/pkg/response"

	"github.com/gin-gonic/gin"
)

type DeviceHandler struct {
	deviceService *service.DeviceService
	authLogRepo   *repository.MQTTAuthLogRepository
	mqttBroker    *mqtt.Broker
}

func NewDeviceHandler(
	deviceService *service.DeviceService,
	authLogRepo *repository.MQTTAuthLogRepository,
) *DeviceHandler {
	return &DeviceHandler{
		deviceService: deviceService,
		authLogRepo:   authLogRepo,
	}
}

// Activate 设备激活接口
// POST /api/v1/devices/activate
func (h *DeviceHandler) Activate(c *gin.Context) {
	var req service.ActivationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[Activate] ProductKey=%s, DeviceSN=%s", req.ProductKey, req.DeviceSN)

	resp, isAlreadyActivated, err := h.deviceService.Activate(&req)
	if err != nil {
		switch err.Error() {
		case "invalid_product_key":
			response.Unauthorized(c, "invalid_product_key")
		case "product_disabled":
			response.Forbidden(c, "product_disabled")
		default:
			log.Printf("[Activate] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	// 如果设备已激活，返回 409
	if isAlreadyActivated {
		response.Conflict(c, "device_already_activated", resp)
		return
	}

	log.Printf("[Activate] Success: DeviceID=%s", resp.DeviceID)
	response.Success(c, resp)
}

// MQTTAuthRequest MQTT认证请求
type MQTTAuthRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	ClientID string `json:"clientid"`
}

// MQTTAuth MQTT认证接口 (EMQX HTTP Auth)
// POST /api/v1/mqtt/auth
func (h *DeviceHandler) MQTTAuth(c *gin.Context) {
	var req MQTTAuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("[MQTTAuth] Invalid request: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"result": "deny"})
		return
	}

	log.Printf("[MQTTAuth] Username=%s, ClientID=%s", req.Username, req.ClientID)

	// Platform internal client bypass
	if req.ClientID == "iot-platform-core" {
		log.Println("[MQTTAuth] Platform internal client, allow as superuser")
		c.JSON(http.StatusOK, gin.H{
			"result":       "allow",
			"is_superuser": true,
		})
		return
	}

	device, err := h.deviceService.ValidateMQTTAuth(req.Username, req.Password, req.ClientID)

	// 记录认证日志
	authLog := &model.MQTTAuthLog{
		ClientID:  req.ClientID,
		Username:  req.Username,
		IPAddress: c.ClientIP(),
		Action:    "connect",
		CreatedAt: time.Now(),
	}

	if err != nil {
		authLog.Result = "deny"
		authLog.Reason = err.Error()
		h.authLogRepo.Create(authLog)

		log.Printf("[MQTTAuth] Denied: %s", err.Error())
		// EMQX 期望返回 200 状态码
		c.JSON(http.StatusOK, gin.H{"result": "deny"})
		return
	}

	authLog.Result = "allow"
	h.authLogRepo.Create(authLog)

	// 更新设备在线状态
	h.deviceService.UpdateDeviceOnline(device.DeviceID, true)

	log.Printf("[MQTTAuth] Allowed: DeviceID=%s", device.DeviceID)
	c.JSON(http.StatusOK, gin.H{
		"result":       "allow",
		"is_superuser": false,
	})
}

// MQTTACLRequest MQTT ACL请求
type MQTTACLRequest struct {
	Username string `json:"username"`
	Topic    string `json:"topic"`
	Action   string `json:"action"` // publish / subscribe
}

// MQTTACL MQTT ACL接口 (EMQX HTTP Authorization)
// POST /api/v1/mqtt/acl
func (h *DeviceHandler) MQTTACL(c *gin.Context) {
	var req MQTTACLRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("[MQTTACL] Invalid request: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"result": "deny"})
		return
	}

	log.Printf("[MQTTACL] Username=%s, Topic=%s, Action=%s", req.Username, req.Topic, req.Action)

	allowed, err := h.deviceService.ValidateMQTTACL(req.Username, req.Topic, req.Action)

	// 记录ACL日志
	authLog := &model.MQTTAuthLog{
		Username:  req.Username,
		IPAddress: c.ClientIP(),
		Action:    req.Action,
		Topic:     req.Topic,
		CreatedAt: time.Now(),
	}

	if err != nil || !allowed {
		authLog.Result = "deny"
		if err != nil {
			authLog.Reason = err.Error()
		} else {
			authLog.Reason = "topic_not_allowed"
		}
		h.authLogRepo.Create(authLog)

		log.Printf("[MQTTACL] Denied: %s", authLog.Reason)
		c.JSON(http.StatusOK, gin.H{"result": "deny"})
		return
	}

	authLog.Result = "allow"
	h.authLogRepo.Create(authLog)

	log.Printf("[MQTTACL] Allowed")
	c.JSON(http.StatusOK, gin.H{"result": "allow"})
}

// HealthCheck 健康检查
// GET /health
func (h *DeviceHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"service": "iot-platform-core",
		"time":    time.Now().Format(time.RFC3339),
	})
}

// ========== 设备列表和详情 ==========

// GetDeviceList 获取设备列表
// GET /api/v1/devices
func (h *DeviceHandler) GetDeviceList(c *gin.Context) {
	productKey := c.Query("productKey")
	statusStr := c.Query("status")
	pageStr := c.DefaultQuery("page", "1")
	sizeStr := c.DefaultQuery("size", "20")

	page := 1
	size := 20
	fmt.Sscanf(pageStr, "%d", &page)
	fmt.Sscanf(sizeStr, "%d", &size)

	var status *model.DeviceStatus
	if statusStr != "" {
		var s int
		fmt.Sscanf(statusStr, "%d", &s)
		ds := model.DeviceStatus(s)
		status = &ds
	}

	resp, err := h.deviceService.GetDeviceList(productKey, status, page, size)
	if err != nil {
		log.Printf("[GetDeviceList] Error: %v", err)
		response.InternalError(c, "internal_error")
		return
	}

	response.Success(c, resp)
}

// GetDevice 获取设备详情
// GET /api/v1/devices/:deviceId
func (h *DeviceHandler) GetDevice(c *gin.Context) {
	deviceID := c.Param("deviceId")
	if deviceID == "" {
		response.BadRequest(c, "device_id_required")
		return
	}

	info, err := h.deviceService.GetDeviceByID(deviceID)
	if err != nil {
		switch err.Error() {
		case "device_not_found":
			response.NotFound(c, "device_not_found")
		default:
			log.Printf("[GetDevice] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, info)
}

// ========== 设备控制 ==========

// SetMQTTBroker 设置 MQTT Broker（供 main.go 调用）
func (h *DeviceHandler) SetMQTTBroker(broker *mqtt.Broker) {
	h.mqttBroker = broker
}

// ControlDevice 控制设备
// POST /api/v1/devices/:deviceId/control
func (h *DeviceHandler) ControlDevice(c *gin.Context) {
	deviceID := c.Param("deviceId")
	if deviceID == "" {
		response.BadRequest(c, "device_id_required")
		return
	}

	var req service.ControlRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	if h.mqttBroker == nil {
		log.Println("[ControlDevice] MQTT broker not initialized")
		response.InternalError(c, "mqtt_broker_unavailable")
		return
	}

	log.Printf("[ControlDevice] DeviceID=%s, Switch=%v, Angle=%v", deviceID, req.Switch, req.Angle)

	// 构建控制消息并发布
	topic, payload, err := h.deviceService.BuildControlMessage(deviceID, &req)
	if err != nil {
		switch err.Error() {
		case "device_not_found":
			response.NotFound(c, "device_not_found")
		case "device_not_activated":
			response.BadRequest(c, "device_not_activated")
		case "device_disabled":
			response.Forbidden(c, "device_disabled")
		case "no_control_params":
			response.BadRequest(c, "no_control_params")
		default:
			log.Printf("[ControlDevice] Error: %v", err)
			response.InternalError(c, "control_failed: "+err.Error())
		}
		return
	}

	// 通过内置Broker发布消息
	data, _ := json.Marshal(payload)
	if err := h.mqttBroker.Publish(topic, data, false); err != nil {
		log.Printf("[ControlDevice] Publish error: %v", err)
		response.InternalError(c, "publish_failed")
		return
	}

	response.Success(c, gin.H{
		"message": "command_sent",
	})
}

// GetDeviceStatus 获取设备状态
// GET /api/v1/devices/:deviceId/status
func (h *DeviceHandler) GetDeviceStatus(c *gin.Context) {
	deviceID := c.Param("deviceId")
	if deviceID == "" {
		response.BadRequest(c, "device_id_required")
		return
	}

	status, err := h.deviceService.GetDeviceStatus(deviceID)
	if err != nil {
		switch err.Error() {
		case "device_not_found":
			response.NotFound(c, "device_not_found")
		default:
			log.Printf("[GetDeviceStatus] Error: %v", err)
			response.InternalError(c, "get_status_failed")
		}
		return
	}

	response.Success(c, status)
}

// DeleteDevice 删除设备
// DELETE /api/v1/devices/:deviceId
func (h *DeviceHandler) DeleteDevice(c *gin.Context) {
	deviceID := c.Param("deviceId")

	// 从上下文中获取用户ID（通过认证中间件设置）
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	log.Printf("[DeleteDevice] UserID=%v, DeviceID=%s", userID, deviceID)

	// 调用服务层删除设备
	err := h.deviceService.DeleteDevice(deviceID)
	if err != nil {
		switch err.Error() {
		case "device_not_found":
			response.NotFound(c, "device_not_found")
		default:
			log.Printf("[DeleteDevice] Error: %v", err)
			response.InternalError(c, "delete_failed: "+err.Error())
		}
		return
	}

	log.Printf("[DeleteDevice] Device deleted successfully: %s", deviceID)
	response.Success(c, gin.H{
		"message": "device_deleted",
	})
}
