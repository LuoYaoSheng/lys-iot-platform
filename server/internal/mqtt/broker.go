// 内置 MQTT Broker
// 作者: 罗耀生
// 日期: 2026-01-06

package mqtt

import (
	"log"
	"sync"

	mqtt "github.com/mochi-mqtt/server/v2"
	"github.com/mochi-mqtt/server/v2/hooks/auth"
	"github.com/mochi-mqtt/server/v2/listeners"
)

// DeviceAuthFunc 设备认证函数类型
type DeviceAuthFunc func(clientID, username, password string) bool

// DeviceStatusUpdateFunc 设备状态更新函数类型
type DeviceStatusUpdateFunc func(clientID string, online bool)

// Broker 内置MQTT Broker
type Broker struct {
	server          *mqtt.Server
	authFunc        DeviceAuthFunc
	statusUpdate    DeviceStatusUpdateFunc // 设备状态更新回调
	lastOnlineUpdate func(deviceID string)   // 最后在线时间更新回调
	mu              sync.RWMutex
	// 在线设备 clientID -> true
	onlineDevices map[string]bool
}

// NewBroker 创建Broker
func NewBroker(authFunc DeviceAuthFunc) *Broker {
	return &Broker{
		authFunc:      authFunc,
		onlineDevices: make(map[string]bool),
	}
}

// Start 启动Broker
func (b *Broker) Start(tcpAddr, wsAddr string) error {
	b.server = mqtt.New(&mqtt.Options{
		InlineClient: true,
	})

	// 添加认证Hook
	if err := b.server.AddHook(new(auth.Hook), &auth.Options{
		Ledger: &auth.Ledger{
			Auth: auth.AuthRules{
				{Username: auth.RString("*"), Password: auth.RString("*"), Allow: true},
			},
		},
	}); err != nil {
		return err
	}

	// 添加自定义Hook处理连接事件
	if err := b.server.AddHook(&EventHook{broker: b}, nil); err != nil {
		return err
	}

	// TCP监听
	if tcpAddr != "" {
		tcp := listeners.NewTCP(listeners.Config{ID: "tcp", Address: tcpAddr})
		if err := b.server.AddListener(tcp); err != nil {
			return err
		}
		log.Printf("[MQTT Broker] TCP listening on %s", tcpAddr)
	}

	// WebSocket监听
	if wsAddr != "" {
		ws := listeners.NewWebsocket(listeners.Config{ID: "ws", Address: wsAddr})
		if err := b.server.AddListener(ws); err != nil {
			return err
		}
		log.Printf("[MQTT Broker] WebSocket listening on %s", wsAddr)
	}

	go func() {
		if err := b.server.Serve(); err != nil {
			log.Printf("[MQTT Broker] Server error: %v", err)
		}
	}()

	log.Println("[MQTT Broker] Started")
	return nil
}

// Stop 停止Broker
func (b *Broker) Stop() error {
	if b.server != nil {
		return b.server.Close()
	}
	return nil
}

// Publish 发布消息
func (b *Broker) Publish(topic string, payload []byte, retain bool) error {
	return b.server.Publish(topic, payload, retain, 1)
}

// IsOnline 检查设备是否在线
func (b *Broker) IsOnline(clientID string) bool {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return b.onlineDevices[clientID]
}

// GetOnlineDevices 获取所有在线设备
func (b *Broker) GetOnlineDevices() []string {
	b.mu.RLock()
	defer b.mu.RUnlock()
	devices := make([]string, 0, len(b.onlineDevices))
	for id := range b.onlineDevices {
		devices = append(devices, id)
	}
	return devices
}

// setOnline 设置设备在线状态
func (b *Broker) setOnline(clientID string, online bool) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if online {
		b.onlineDevices[clientID] = true
	} else {
		delete(b.onlineDevices, clientID)
	}

	// 同时更新数据库状态
	if b.statusUpdate != nil {
		// 从 clientID 中提取 deviceID (格式: ProductKey&deviceID)
		deviceID := extractDeviceID(clientID)
		if deviceID != "" {
			go b.statusUpdate(deviceID, online)
		}
	}

	// 更新最后在线时间（仅在线时）
	if online && b.lastOnlineUpdate != nil {
		deviceID := extractDeviceID(clientID)
		if deviceID != "" {
			go b.lastOnlineUpdate(deviceID)
		}
	}
}

// SetStatusUpdate 设置状态更新回调
func (b *Broker) SetStatusUpdate(fn DeviceStatusUpdateFunc) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.statusUpdate = fn
}

// SetLastOnlineUpdate 设置最后在线时间更新回调
func (b *Broker) SetLastOnlineUpdate(fn func(deviceID string)) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.lastOnlineUpdate = fn
}

// extractDeviceID 从 clientID 中提取 deviceID
// clientID 格式: "ProductKey&deviceID"
func extractDeviceID(clientID string) string {
	for i := len(clientID) - 1; i >= 0; i-- {
		if clientID[i] == '&' {
			return clientID[i+1:]
		}
	}
	return ""
}
