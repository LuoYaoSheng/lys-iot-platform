// 用户处理器
// 作者: 罗耀生
// 日期: 2025-12-13

package handler

import (
	"log"
	"net/http"
	"strings"

	"iot-platform-core/internal/service"
	"iot-platform-core/pkg/response"

	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	userService *service.UserService
}

func NewUserHandler(userService *service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// Register 用户注册
// POST /api/v1/users/register
func (h *UserHandler) Register(c *gin.Context) {
	var req service.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[Register] Email=%s, Name=%s", req.Email, req.Name)

	resp, err := h.userService.Register(&req)
	if err != nil {
		switch err.Error() {
		case "invalid_email":
			response.BadRequest(c, "invalid_email")
		case "weak_password":
			response.BadRequest(c, "weak_password")
		case "email_exists":
			response.Conflict(c, "email_exists", nil)
		default:
			log.Printf("[Register] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	log.Printf("[Register] Success: UserID=%s", resp.UserID)
	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "success",
		"data":    resp,
	})
}

// Login 用户登录
// POST /api/v1/users/login
func (h *UserHandler) Login(c *gin.Context) {
	var req service.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[Login] Email=%s", req.Email)

	resp, err := h.userService.Login(&req)
	if err != nil {
		switch err.Error() {
		case "user_not_found", "invalid_password":
			response.Unauthorized(c, "invalid_credentials")
		case "user_disabled":
			response.Forbidden(c, "user_disabled")
		default:
			log.Printf("[Login] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	log.Printf("[Login] Success: UserID=%s", resp.User.UserID)
	response.Success(c, resp)
}

// RefreshToken 刷新令牌
// POST /api/v1/users/refresh-token
func (h *UserHandler) RefreshToken(c *gin.Context) {
	var req service.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	resp, err := h.userService.RefreshToken(&req)
	if err != nil {
		switch err.Error() {
		case "invalid_refresh_token", "refresh_token_expired":
			response.Unauthorized(c, err.Error())
		default:
			log.Printf("[RefreshToken] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, resp)
}

// GetMe 获取当前用户信息
// GET /api/v1/users/me
func (h *UserHandler) GetMe(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	info, err := h.userService.GetUserByID(userID)
	if err != nil {
		switch err.Error() {
		case "user_not_found":
			response.NotFound(c, "user_not_found")
		default:
			log.Printf("[GetMe] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, info)
}

// ========== API Key 相关 ==========

// CreateAPIKey 创建 API Key
// POST /api/v1/users/api-keys
func (h *UserHandler) CreateAPIKey(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	var req service.CreateAPIKeyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[CreateAPIKey] UserID=%s, Name=%s", userID, req.Name)

	resp, err := h.userService.CreateAPIKey(userID, &req)
	if err != nil {
		log.Printf("[CreateAPIKey] Error: %v", err)
		response.InternalError(c, "internal_error")
		return
	}

	log.Printf("[CreateAPIKey] Success: KeyID=%s", resp.KeyID)
	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "success",
		"data":    resp,
	})
}

// GetAPIKeys 获取 API Key 列表
// GET /api/v1/users/api-keys
func (h *UserHandler) GetAPIKeys(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	keys, err := h.userService.GetAPIKeys(userID)
	if err != nil {
		log.Printf("[GetAPIKeys] Error: %v", err)
		response.InternalError(c, "internal_error")
		return
	}

	response.Success(c, gin.H{"keys": keys})
}

// DeleteAPIKey 删除 API Key
// DELETE /api/v1/users/api-keys/:keyId
func (h *UserHandler) DeleteAPIKey(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	keyID := c.Param("keyId")
	if keyID == "" {
		response.BadRequest(c, "key_id_required")
		return
	}

	log.Printf("[DeleteAPIKey] UserID=%s, KeyID=%s", userID, keyID)

	err := h.userService.DeleteAPIKey(userID, keyID)
	if err != nil {
		switch err.Error() {
		case "key_not_found":
			response.NotFound(c, "key_not_found")
		case "forbidden":
			response.Forbidden(c, "forbidden")
		default:
			log.Printf("[DeleteAPIKey] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, gin.H{"message": "deleted"})
}

// ========== 认证中间件 ==========

// AuthMiddleware JWT 认证中间件
func (h *UserHandler) AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			response.Unauthorized(c, "missing_token")
			c.Abort()
			return
		}

		// Bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			response.Unauthorized(c, "invalid_token_format")
			c.Abort()
			return
		}

		claims, err := h.userService.ValidateJWT(parts[1])
		if err != nil {
			response.Unauthorized(c, "invalid_token")
			c.Abort()
			return
		}

		// 将用户ID存入上下文
		c.Set("userID", claims.UserID)
		c.Set("email", claims.Email)
		c.Next()
	}
}

// APIKeyMiddleware API Key 认证中间件
func (h *UserHandler) APIKeyMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		apiKey := c.GetHeader("X-API-Key")
		apiSecret := c.GetHeader("X-API-Secret")

		if apiKey == "" || apiSecret == "" {
			response.Unauthorized(c, "missing_api_key")
			c.Abort()
			return
		}

		key, err := h.userService.ValidateAPIKey(apiKey, apiSecret)
		if err != nil {
			response.Unauthorized(c, err.Error())
			c.Abort()
			return
		}

		// 将用户ID存入上下文
		c.Set("userID", key.UserID)
		c.Set("apiKeyID", key.KeyID)
		c.Next()
	}
}

// CombinedAuthMiddleware 组合认证中间件（支持 Bearer Token 和 API Key）
func (h *UserHandler) CombinedAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		apiKey := c.GetHeader("X-API-Key")

		// 优先使用 Bearer Token
		if authHeader != "" {
			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) == 2 && parts[0] == "Bearer" {
				claims, err := h.userService.ValidateJWT(parts[1])
				if err == nil {
					c.Set("userID", claims.UserID)
					c.Set("email", claims.Email)
					c.Next()
					return
				}
			}
		}

		// 尝试使用 API Key
		if apiKey != "" {
			apiSecret := c.GetHeader("X-API-Secret")
			if apiSecret != "" {
				key, err := h.userService.ValidateAPIKey(apiKey, apiSecret)
				if err == nil {
					c.Set("userID", key.UserID)
					c.Set("apiKeyID", key.KeyID)
					c.Next()
					return
				}
			}
		}

		response.Unauthorized(c, "unauthorized")
		c.Abort()
	}
}
