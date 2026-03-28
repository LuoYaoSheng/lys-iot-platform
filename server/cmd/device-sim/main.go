package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type controlMessage struct {
	Method string                 `json:"method"`
	ID     string                 `json:"id"`
	Params map[string]interface{} `json:"params"`
}

type webhookMessageEvent struct {
	Event     string `json:"event"`
	ClientID  string `json:"clientid"`
	Username  string `json:"username"`
	Topic     string `json:"topic"`
	Payload   string `json:"payload"`
	Timestamp int64  `json:"timestamp"`
	QoS       int    `json:"qos"`
}

func main() {
	productKey := mustGetenv("DEVICE_SIM_PRODUCT_KEY")
	deviceID := mustGetenv("DEVICE_SIM_DEVICE_ID")
	username := mustGetenv("DEVICE_SIM_USERNAME")
	password := mustGetenv("DEVICE_SIM_PASSWORD")
	clientID := getEnvOr("DEVICE_SIM_CLIENT_ID", username)
	brokerURL := getEnvOr("DEVICE_SIM_BROKER_URL", "tcp://127.0.0.1:48883")
	apiBaseURL := getEnvOr("DEVICE_SIM_API_BASE_URL", "http://127.0.0.1:48080")
	initialPosition := getEnvOr("DEVICE_SIM_INITIAL_POSITION", "middle")
	keepAliveSec := getEnvIntOr("DEVICE_SIM_KEEPALIVE_SEC", 60)

	propertySetTopic := "/sys/" + productKey + "/" + deviceID + "/thing/service/property/set"
	propertyPostTopic := "/sys/" + productKey + "/" + deviceID + "/thing/event/property/post"

	currentPosition := initialPosition

	opts := mqtt.NewClientOptions()
	opts.AddBroker(brokerURL)
	opts.SetClientID(clientID)
	opts.SetUsername(username)
	opts.SetPassword(password)
	opts.SetAutoReconnect(true)
	opts.SetKeepAlive(time.Duration(keepAliveSec) * time.Second)
	opts.SetConnectTimeout(10 * time.Second)

	opts.OnConnect = func(c mqtt.Client) {
		log.Printf("device-sim connected to %s", brokerURL)

		token := c.Subscribe(propertySetTopic, 1, func(_ mqtt.Client, msg mqtt.Message) {
			log.Printf("received control on %s: %s", msg.Topic(), string(msg.Payload()))

			var cmd controlMessage
			if err := json.Unmarshal(msg.Payload(), &cmd); err != nil {
				log.Printf("decode control message failed: %v", err)
				return
			}

			if action, ok := cmd.Params["action"].(string); ok {
				switch action {
				case "toggle":
					if position, ok := cmd.Params["position"].(string); ok {
						currentPosition = position
					}
				case "pulse":
					// Keep existing position for pulse mode.
				}
			}

			payloadMap := map[string]interface{}{
				"position": currentPosition,
			}
			payloadBytes, _ := json.Marshal(payloadMap)

			pub := c.Publish(propertyPostTopic, 1, false, payloadBytes)
			pub.Wait()
			if err := pub.Error(); err != nil {
				log.Printf("publish property report failed: %v", err)
			}

			if err := postWebhookMessage(apiBaseURL, webhookMessageEvent{
				Event:     "message.publish",
				ClientID:  clientID,
				Username:  username,
				Topic:     propertyPostTopic,
				Payload:   string(payloadBytes),
				Timestamp: time.Now().UnixMilli(),
				QoS:       1,
			}); err != nil {
				log.Printf("webhook mirror failed: %v", err)
			} else {
				log.Printf("mirrored property report: position=%s", currentPosition)
			}
		})
		token.Wait()
		if err := token.Error(); err != nil {
			log.Printf("subscribe failed: %v", err)
			return
		}

		if err := postWebhookMessage(apiBaseURL, webhookMessageEvent{
			Event:     "message.publish",
			ClientID:  clientID,
			Username:  username,
			Topic:     propertyPostTopic,
			Payload:   `{"position":"` + currentPosition + `"}`,
			Timestamp: time.Now().UnixMilli(),
			QoS:       1,
		}); err != nil {
			log.Printf("initial webhook mirror failed: %v", err)
		}
	}

	opts.OnConnectionLost = func(_ mqtt.Client, err error) {
		log.Printf("device-sim connection lost: %v", err)
	}

	client := mqtt.NewClient(opts)
	token := client.Connect()
	token.Wait()
	if err := token.Error(); err != nil {
		log.Fatalf("device-sim connect failed: %v", err)
	}

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh

	log.Println("device-sim shutting down")
	client.Disconnect(1000)
}

func postWebhookMessage(apiBaseURL string, event webhookMessageEvent) error {
	body, err := json.Marshal(event)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, apiBaseURL+"/api/v1/webhook/message", bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		return &httpStatusError{statusCode: resp.StatusCode}
	}

	return nil
}

type httpStatusError struct {
	statusCode int
}

func (e *httpStatusError) Error() string {
	return "unexpected webhook status: " + http.StatusText(e.statusCode)
}

func mustGetenv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("%s is required", key)
	}
	return value
}

func getEnvOr(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getEnvIntOr(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if parsed, err := strconv.Atoi(value); err == nil {
			return parsed
		}
	}
	return fallback
}
