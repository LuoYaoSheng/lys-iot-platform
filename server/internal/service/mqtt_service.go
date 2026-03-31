package service

import (
	"encoding/json"
	"fmt"
	"sync"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

// MQTTService wraps a platform-side MQTT client used for publishing control commands.
type MQTTService struct {
	broker   string
	port     int
	clientID string
	username string
	password string

	mu     sync.RWMutex
	client mqtt.Client
}

func NewMQTTService(broker string, port int, clientID, username, password string) *MQTTService {
	return &MQTTService{
		broker:   broker,
		port:     port,
		clientID: clientID,
		username: username,
		password: password,
	}
}

func (s *MQTTService) Connect() error {
	opts := mqtt.NewClientOptions().
		AddBroker(fmt.Sprintf("tcp://%s:%d", s.broker, s.port)).
		SetClientID(s.clientID)

	if s.username != "" {
		opts.SetUsername(s.username)
	}
	if s.password != "" {
		opts.SetPassword(s.password)
	}

	client := mqtt.NewClient(opts)
	token := client.Connect()
	token.Wait()
	if err := token.Error(); err != nil {
		return err
	}

	s.mu.Lock()
	s.client = client
	s.mu.Unlock()
	return nil
}

func (s *MQTTService) Disconnect() {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.client != nil && s.client.IsConnected() {
		s.client.Disconnect(250)
	}
}

func (s *MQTTService) PublishDeviceControl(productKey, deviceID string, params map[string]interface{}) error {
	s.mu.RLock()
	client := s.client
	s.mu.RUnlock()

	if client == nil || !client.IsConnected() {
		return fmt.Errorf("mqtt client not connected")
	}

	payload := map[string]interface{}{
		"method":    "thing.service.property.set",
		"id":        fmt.Sprintf("%d", time.Now().UnixNano()),
		"version":   "1.0",
		"params":    params,
		"timestamp": time.Now().UnixMilli(),
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	topic := fmt.Sprintf("/sys/%s/%s/thing/service/property/set", productKey, deviceID)
	token := client.Publish(topic, 1, false, body)
	token.Wait()
	return token.Error()
}
