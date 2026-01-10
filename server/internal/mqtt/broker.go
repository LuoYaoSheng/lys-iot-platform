// 内置 MQTT Broker - 集成 Redis 设备状态管理
// 作者: 罗耀生
// 日期: 2026-01-06

package mqtt

import (
	"log"
	"sync"

	mqtt "github.com/mochi-mqtt/server/v2"
	"github.com/mochi-mqtt/server/v2/hooks/auth"
	"github.com/mochi-mqtt/server/v2/listeners"
	"iot-platform-core/internal/redis"
)

// DeviceAuthFunc 设备认证函数类型
type DeviceAuthFunc func(clientID, username, password string) bool

// DeviceStatusUpdateFunc 设备状态更新函数类型
type DeviceStatusUpdateFunc func(clientID string, online bool)

// Broker 内置MQTT Broker
type Broker struct {
	server       *mqtt.Server
	authFunc     DeviceAuthFunc
	statusUpdate DeviceStatusUpdateFunc // 设备状态更新回调（数据库）
	redisClient  *redis.Client          // Redis 客户端
	mu           sync.RWMutex
	// 在线设备 clientID -> true（内存缓存，用于快速查询）
	onlineDevices map[string]bool
}

// NewBroker 创建Broker
func NewBroker(authFunc DeviceAuthFunc) *Broker {
	return &Broker{
		authFunc:      authFunc,
		onlineDevices: make(map[string]bool),
	}
}

// SetRedisClient 设置 Redis 客户端
func (b *Broker) SetRedisClient(client *redis.Client) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.redisClient = client
}

// SetStatusUpdate 设置状态更新回调
func (b *Broker) SetStatusUpdate(fn DeviceStatusUpdateFunc) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.statusUpdate = fn
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

// IsOnline 检查设备是否在线（查询 Redis）
func (b *Broker) IsOnline(deviceID string) bool {
	b.mu.RLock()
	redisClient := b.redisClient
	b.mu.RUnlock()

	if redisClient != nil {
		return redisClient.IsDeviceOnline(deviceID)
	}
	// Redis 未启用时回退到内存缓存
	b.mu.RLock()
	defer b.mu.RUnlock()
	return b.onlineDevices[deviceID]
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

// setOnline 设置设备在线状态（更新内存缓存、Redis、触发数据库回调）
func (b *Broker) setOnline(clientID string, online bool) {
	deviceID := extractDeviceID(clientID)
	if deviceID == "" {
		return
	}

	b.mu.Lock()
	// 更新内存缓存
	if online {
		b.onlineDevices[clientID] = true
	} else {
		delete(b.onlineDevices, clientID)
	}
	redisClient := b.redisClient
	statusUpdate := b.statusUpdate
	b.mu.Unlock()

	// 更新 Redis（同步执行，确保状态一致性）
	if redisClient != nil {
		log.Printf("[MQTT] Redis client found, updating device %s status to %v", deviceID, online)
		if online {
			if err := redisClient.SetDeviceOnline(deviceID); err != nil {
				log.Printf("[MQTT] Failed to set device online in Redis: %v", err)
			}
		} else {
			if err := redisClient.SetDeviceOffline(deviceID); err != nil {
				log.Printf("[MQTT] Failed to set device offline in Redis: %v", err)
			}
		}
	} else {
		log.Printf("[MQTT] Redis client is NIL!")
	}

	// 异步更新数据库状态
	if statusUpdate != nil {
		go statusUpdate(deviceID, online)
	}
}

// refreshOnline 刷新设备在线状态（由 OnPublished 回调调用）
// 当设备发布消息时调用，刷新 Redis TTL 防止被误判为离线
func (b *Broker) refreshOnline(clientID string) {
	deviceID := extractDeviceID(clientID)
	if deviceID == "" {
		return
	}

	b.mu.RLock()
	redisClient := b.redisClient
	b.mu.RUnlock()

	if redisClient != nil {
		if err := redisClient.RefreshDeviceOnline(deviceID); err != nil {
			log.Printf("[MQTT] Failed to refresh device online: %v", err)
		}
	}
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
