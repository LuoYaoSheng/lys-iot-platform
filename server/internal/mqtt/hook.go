// MQTT事件Hook
// 作者: 罗耀生
// 日期: 2026-01-06
// 更新: 2026-01-06 - 添加OnPublished监听设备消息，刷新Redis TTL

package mqtt

import (
	"bytes"
	"log"

	mqtt "github.com/mochi-mqtt/server/v2"
	"github.com/mochi-mqtt/server/v2/packets"
)

// EventHook 事件处理Hook
type EventHook struct {
	mqtt.HookBase
	broker *Broker
}

// ID 返回Hook ID
func (h *EventHook) ID() string {
	return "event-hook"
}

// Provides 声明提供的Hook点
func (h *EventHook) Provides(b byte) bool {
	return bytes.Contains([]byte{
		mqtt.OnConnectAuthenticate,
		mqtt.OnSessionEstablished,
		mqtt.OnDisconnect,
		mqtt.OnPublished, // 监听发布消息，用于刷新Redis TTL
	}, []byte{b})
}

// OnConnectAuthenticate 连接认证
func (h *EventHook) OnConnectAuthenticate(cl *mqtt.Client, pk packets.Packet) bool {
	if h.broker.authFunc == nil {
		return true
	}

	clientID := cl.ID
	username := string(pk.Connect.Username)
	password := string(pk.Connect.Password)

	allowed := h.broker.authFunc(clientID, username, password)
	if allowed {
		log.Printf("[MQTT] Auth success: %s", clientID)
	} else {
		log.Printf("[MQTT] Auth failed: %s", clientID)
	}
	return allowed
}

// OnSessionEstablished 会话建立
func (h *EventHook) OnSessionEstablished(cl *mqtt.Client, pk packets.Packet) {
	h.broker.setOnline(cl.ID, true)
	log.Printf("[MQTT] Client connected: %s", cl.ID)
}

// OnDisconnect 断开连接
func (h *EventHook) OnDisconnect(cl *mqtt.Client, err error, expire bool) {
	h.broker.setOnline(cl.ID, false)
	log.Printf("[MQTT] Client disconnected: %s", cl.ID)
}

// OnPublished 消息发布 - 刷新Redis TTL
// 当设备发布消息（如状态上报）时，刷新Redis TTL，防止长时间连接被误判为离线
func (h *EventHook) OnPublished(cl *mqtt.Client, pk packets.Packet) {
	// 刷新设备在线状态（Redis TTL）
	h.broker.refreshOnline(cl.ID)
}
