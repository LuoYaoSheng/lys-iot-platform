package handler

import (
	"net/http"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestUserHandlerRegisterLoginAndGetMe(t *testing.T) {
	gin.SetMode(gin.TestMode)

	db := newHandlerTestDB(t)
	userService := newUserServiceForHandlerTests(db)
	userHandler := NewUserHandler(userService)

	router := gin.New()
	router.POST("/api/v1/users/register", userHandler.Register)
	router.POST("/api/v1/users/login", userHandler.Login)

	authorized := router.Group("/api/v1")
	authorized.Use(userHandler.AuthMiddleware())
	authorized.GET("/users/me", userHandler.GetMe)

	registerRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/users/register", map[string]interface{}{
		"email":    "handler@example.com",
		"password": "StrongPass1",
		"name":     "Handler User",
	}, nil)
	if registerRec.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d: %s", registerRec.Code, registerRec.Body.String())
	}
	registerResp := decodeResponseEnvelope(t, registerRec)
	if registerResp.Code != 201 || registerResp.Message != "success" {
		t.Fatalf("unexpected register response: %+v", registerResp)
	}

	meUnauthorizedRec := performJSONRequest(t, router, http.MethodGet, "/api/v1/users/me", nil, nil)
	if meUnauthorizedRec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for missing token, got %d", meUnauthorizedRec.Code)
	}

	loginRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/users/login", map[string]interface{}{
		"email":    "handler@example.com",
		"password": "StrongPass1",
	}, nil)
	if loginRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", loginRec.Code, loginRec.Body.String())
	}
	loginResp := decodeResponseEnvelope(t, loginRec)
	token, _ := loginResp.Data["token"].(string)
	if loginResp.Code != 200 || token == "" {
		t.Fatalf("unexpected login response: %+v", loginResp)
	}

	meRec := performJSONRequest(t, router, http.MethodGet, "/api/v1/users/me", nil, map[string]string{
		"Authorization": "Bearer " + token,
	})
	if meRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", meRec.Code, meRec.Body.String())
	}
	meResp := decodeResponseEnvelope(t, meRec)
	if meResp.Data["email"] != "handler@example.com" {
		t.Fatalf("unexpected me response: %+v", meResp)
	}
}
