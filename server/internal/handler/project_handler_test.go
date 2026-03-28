package handler

import (
	"net/http"
	"testing"

	"iot-platform-core/internal/service"

	"github.com/gin-gonic/gin"
)

func TestProjectHandlerSupportsBearerAndAPIKeyAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	db := newHandlerTestDB(t)
	userService := newUserServiceForHandlerTests(db)
	projectService := newProjectServiceForHandlerTests(db)
	userHandler := NewUserHandler(userService)
	projectHandler := NewProjectHandler(projectService)

	_, loginResp := registerAndLoginTestUser(t, userService)

	apiKeyResp, err := userService.CreateAPIKey(loginResp.User.UserID, &service.CreateAPIKeyRequest{
		Name:        "ci-key",
		Permissions: []string{"projects:read"},
	})
	if err != nil {
		t.Fatalf("CreateAPIKey returned error: %v", err)
	}

	router := gin.New()
	protected := router.Group("/api/v1/projects")
	protected.Use(userHandler.CombinedAuthMiddleware())
	protected.POST("", projectHandler.CreateProject)
	protected.GET("", projectHandler.GetProjectList)

	unauthorizedRec := performJSONRequest(t, router, http.MethodGet, "/api/v1/projects", nil, nil)
	if unauthorizedRec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", unauthorizedRec.Code)
	}

	createRec := performJSONRequest(t, router, http.MethodPost, "/api/v1/projects", map[string]interface{}{
		"name":        "Home Lab",
		"description": "integration test project",
	}, map[string]string{
		"Authorization": "Bearer " + loginResp.Token,
	})
	if createRec.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d: %s", createRec.Code, createRec.Body.String())
	}
	createResp := decodeResponseEnvelope(t, createRec)
	if createResp.Message != "created" || createResp.Data["name"] != "Home Lab" {
		t.Fatalf("unexpected create response: %+v", createResp)
	}

	listRec := performJSONRequest(t, router, http.MethodGet, "/api/v1/projects?page=1&size=20", nil, map[string]string{
		"X-API-Key":    apiKeyResp.APIKey,
		"X-API-Secret": apiKeyResp.APISecret,
	})
	if listRec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", listRec.Code, listRec.Body.String())
	}
	listResp := decodeResponseEnvelope(t, listRec)
	if listResp.Data["total"].(float64) < 1 {
		t.Fatalf("expected at least one project, got %+v", listResp)
	}
}
