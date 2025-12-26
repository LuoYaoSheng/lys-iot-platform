// MQTT 服务层 - 发布设备控制指令
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

// MQTTService MQTT 服务
type MQTTService struct {
	client     mqtt.Client
	broker     string
	port       int
	clientID   string
	username   string
	password   string
	connected  bool
	mu         sync.Mutex
}

// NewMQTTService 创建 MQTT 服务
func NewMQTTService(broker string, port int, clientID, username, password string) *MQTTService {
	return &MQTTService{
		broker:   broker,
		port:     port,
		clientID: clientID,
		username: username,
		password: password,
	}
}

// Connect 连接 MQTT Broker
func (s *MQTTService) Connect() error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.connected && s.client != nil && s.client.IsConnected() {
		return nil
	}

	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("tcp://%s:%d", s.broker, s.port))
	opts.SetClientID(s.clientID)
	if s.username != "" {
		opts.SetUsername(s.username)
		opts.SetPassword(s.password)
	}
	opts.SetAutoReconnect(true)
	opts.SetConnectRetry(true)
	opts.SetConnectRetryInterval(5 * time.Second)
	opts.SetKeepAlive(60 * time.Second)

	opts.SetOnConnectHandler(func(c mqtt.Client) {
		log.Println("[MQTT] Connected to broker")
		s.connected = true
	})

	opts.SetConnectionLostHandler(func(c mqtt.Client, err error) {
		log.Printf("[MQTT] Connection lost: %v", err)
		s.connected = false
	})

	s.client = mqtt.NewClient(opts)
	token := s.client.Connect()
	if token.WaitTimeout(10 * time.Second) {
		if token.Error() != nil {
			return fmt.Errorf("mqtt connect failed: %v", token.Error())
		}
	} else {
		return fmt.Errorf("mqtt connect timeout")
	}

	s.connected = true
	log.Printf("[MQTT] Connected to %s:%d", s.broker, s.port)
	return nil
}

// Disconnect 断开连接
func (s *MQTTService) Disconnect() {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.client != nil && s.client.IsConnected() {
		s.client.Disconnect(1000)
		s.connected = false
		log.Println("[MQTT] Disconnected")
	}
}

// IsConnected 检查连接状态
func (s *MQTTService) IsConnected() bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.connected && s.client != nil && s.client.IsConnected()
}

// Publish 发布消息
func (s *MQTTService) Publish(topic string, payload interface{}, qos byte, retained bool) error {
	if !s.IsConnected() {
		if err := s.Connect(); err != nil {
			return err
		}
	}

	var data []byte
	var err error

	switch v := payload.(type) {
	case []byte:
		data = v
	case string:
		data = []byte(v)
	default:
		data, err = json.Marshal(payload)
		if err != nil {
			return fmt.Errorf("json marshal failed: %v", err)
		}
	}

	token := s.client.Publish(topic, qos, retained, data)
	if token.WaitTimeout(5 * time.Second) {
		if token.Error() != nil {
			return fmt.Errorf("mqtt publish failed: %v", token.Error())
		}
	} else {
		return fmt.Errorf("mqtt publish timeout")
	}

	log.Printf("[MQTT] Published to %s: %s", topic, string(data))
	return nil
}

// DeviceControlMessage 设备控制消息
type DeviceControlMessage struct {
	Method string                 `json:"method"`
	ID     string                 `json:"id"`
	Params map[string]interface{} `json:"params"`
}

// PublishDeviceControl 发布设备控制指令
func (s *MQTTService) PublishDeviceControl(productKey, deviceID string, params map[string]interface{}) error {
	topic := fmt.Sprintf("/sys/%s/%s/thing/service/property/set", productKey, deviceID)

	msg := DeviceControlMessage{
		Method: "thing.service.property.set",
		ID:     fmt.Sprintf("%d", time.Now().UnixMilli()),
		Params: params,
	}

	return s.Publish(topic, msg, 1, false)
}

// Subscribe 订阅主题
func (s *MQTTService) Subscribe(topic string, qos byte, callback mqtt.MessageHandler) error {
	if !s.IsConnected() {
		if err := s.Connect(); err != nil {
			return err
		}
	}

	token := s.client.Subscribe(topic, qos, callback)
	if token.WaitTimeout(5 * time.Second) {
		if token.Error() != nil {
			return fmt.Errorf("mqtt subscribe failed: %v", token.Error())
		}
	} else {
		return fmt.Errorf("mqtt subscribe timeout")
	}

	log.Printf("[MQTT] Subscribed to %s", topic)
	return nil
}
