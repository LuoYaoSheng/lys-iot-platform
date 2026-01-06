// MQTT事件Hook
// 作者: 罗耀生
// 日期: 2026-01-06

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
