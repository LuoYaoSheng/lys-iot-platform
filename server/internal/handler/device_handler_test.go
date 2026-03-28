package handler

import (
	"encoding/json"
	"net/http"
	"testing"

	"iot-platform-core/internal/repository"

	"github.com/gin-gonic/gin"
)

func TestDeviceHandlerActivateMQTTAuthAndGetStatus(t *testing.T) {
	gin.SetMode(gin.TestMode)

	db := newHandlerTestDB(t)
	seedHandlerTestProduct(t, db, "switch_v1", 1)

	deviceService := newDeviceServiceForHandlerTests(db)
	authLogRepo := repository.NewMQTTAuthLogRepository(db)
	deviceHandler := NewDeviceHandler(deviceService, authLogRepo)

	router := gin.New()
	router.POST("/api/v1/devices/activate", deviceHandler.Activate)
	router.POST("/api/v1/mqtt/auth", deviceHandler.MQTTAuth)
	router.GET("/api/v1/devices/:deviceId/status", deviceHandler.GetDeviceStatus)

	activateRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/devices/activate", map[string]interface{}{
		"productKey":      "switch_v1",
		"deviceSN":        "SN001",
		"firmwareVersion": "1.0.0",
		"chipModel":       "ESP32",
	}, nil)
	if activateRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", activateRec.Code, activateRec.Body.String())
	}
	activateResp := decodeResponseEnvelope(t, activateRec)
	deviceID, _ := activateResp.Data["deviceId"].(string)
	mqttData, _ := activateResp.Data["mqtt"].(map[string]interface{})
	if deviceID == "" || mqttData["username"] == "" {
		t.Fatalf("unexpected activation response: %+v", activateResp)
	}

	mqttAuthRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/mqtt/auth", map[string]interface{}{
		"username": mqttData["username"],
		"password": mqttData["password"],
		"clientid": mqttData["clientId"],
	}, nil)
	if mqttAuthRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", mqttAuthRec.Code, mqttAuthRec.Body.String())
	}
	var mqttAuthBody map[string]interface{}
	if err := json.Unmarshal(mqttAuthRec.Body.Bytes(), &mqttAuthBody); err != nil {
		t.Fatalf("decode mqtt auth body: %v", err)
	}
	if mqttAuthBody["result"] != "allow" {
		t.Fatalf("expected mqtt auth allow, got %+v", mqttAuthBody)
	}

	statusRec := performJSONRequest(t, router, http.MethodGet, "/api/v1/devices/"+deviceID+"/status", nil, nil)
	if statusRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", statusRec.Code, statusRec.Body.String())
	}
	statusResp := decodeResponseEnvelope(t, statusRec)
	if statusResp.Data["status"] != "online" {
		t.Fatalf("expected online status, got %+v", statusResp)
	}

	activateAgainRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/devices/activate", map[string]interface{}{
		"productKey":      "switch_v1",
		"deviceSN":        "SN001",
		"firmwareVersion": "1.0.1",
		"chipModel":       "ESP32",
	}, nil)
	if activateAgainRec.Code != http.StatusConflict {
		t.Fatalf("expected 409, got %d: %s", activateAgainRec.Code, activateAgainRec.Body.String())
	}
}
