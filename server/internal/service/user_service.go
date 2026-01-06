// 用户服务层
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"regexp"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// UserService 用户服务
type UserService struct {
	userRepo         *repository.UserRepository
	apiKeyRepo       *repository.APIKeyRepository
	refreshTokenRepo *repository.RefreshTokenRepository
	jwtSecret        string
	jwtExpireHours   int
}

func NewUserService(
	userRepo *repository.UserRepository,
	apiKeyRepo *repository.APIKeyRepository,
	refreshTokenRepo *repository.RefreshTokenRepository,
	jwtSecret string,
	jwtExpireHours int,
) *UserService {
	if jwtExpireHours <= 0 {
		jwtExpireHours = 24 // 默认24小时
	}
	return &UserService{
		userRepo:         userRepo,
		apiKeyRepo:       apiKeyRepo,
		refreshTokenRepo: refreshTokenRepo,
		jwtSecret:        jwtSecret,
		jwtExpireHours:   jwtExpireHours,
	}
}

// ========== 注册/登录 ==========

// RegisterRequest 注册请求
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8,max=32"`
	Name     string `json:"name" binding:"required"`
	Phone    string `json:"phone"`
}

// RegisterResponse 注册响应
type RegisterResponse struct {
	UserID string `json:"userId"`
	Email  string `json:"email"`
	Name   string `json:"name"`
}

// Register 用户注册
func (s *UserService) Register(req *RegisterRequest) (*RegisterResponse, error) {
	// 验证邮箱格式
	if !isValidEmail(req.Email) {
		return nil, errors.New("invalid_email")
	}

	// 验证密码强度
	if !isStrongPassword(req.Password) {
		return nil, errors.New("weak_password")
	}

	// 检查邮箱是否已注册
	_, err := s.userRepo.FindByEmail(req.Email)
	if err == nil {
		return nil, errors.New("email_exists")
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	// 密码加密
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 创建用户
	user := &model.User{
		UserID:       "user_" + uuid.New().String()[:8],
		Email:        req.Email,
		PasswordHash: string(hashedPassword),
		Name:         req.Name,
		Phone:        req.Phone,
		Status:       model.UserStatusActive,
	}

	if err := s.userRepo.Create(user); err != nil {
		return nil, err
	}

	return &RegisterResponse{
		UserID: user.UserID,
		Email:  user.Email,
		Name:   user.Name,
	}, nil
}

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token        string    `json:"token"`
	RefreshToken string    `json:"refreshToken"`
	ExpiresIn    int       `json:"expiresIn"`
	User         *UserInfo `json:"user"`
}

// UserInfo 用户信息
type UserInfo struct {
	UserID string `json:"userId"`
	Email  string `json:"email"`
	Name   string `json:"name"`
	Phone  string `json:"phone"`
	Avatar string `json:"avatar"`
}

// Login 用户登录
func (s *UserService) Login(req *LoginRequest) (*LoginResponse, error) {
	// 查找用户
	user, err := s.userRepo.FindByEmail(req.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user_not_found")
		}
		return nil, err
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid_password")
	}

	// 验证用户状态
	if user.Status != model.UserStatusActive {
		return nil, errors.New("user_disabled")
	}

	// 生成 JWT
	token, err := s.generateJWT(user)
	if err != nil {
		return nil, err
	}

	// 生成刷新令牌
	refreshToken, err := s.generateRefreshToken(user.UserID)
	if err != nil {
		return nil, err
	}

	// 更新最后登录时间
	s.userRepo.UpdateLastLogin(user.UserID)

	return &LoginResponse{
		Token:        token,
		RefreshToken: refreshToken,
		ExpiresIn:    s.jwtExpireHours * 3600,
		User: &UserInfo{
			UserID: user.UserID,
			Email:  user.Email,
			Name:   user.Name,
			Phone:  user.Phone,
			Avatar: user.Avatar,
		},
	}, nil
}

// RefreshTokenRequest 刷新令牌请求
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" binding:"required"`
}

// RefreshTokenResponse 刷新令牌响应
type RefreshTokenResponse struct {
	Token     string `json:"token"`
	ExpiresIn int    `json:"expiresIn"`
}

// RefreshToken 刷新令牌
func (s *UserService) RefreshToken(req *RefreshTokenRequest) (*RefreshTokenResponse, error) {
	// 查找刷新令牌
	rt, err := s.refreshTokenRepo.FindByToken(req.RefreshToken)
	if err != nil {
		return nil, errors.New("invalid_refresh_token")
	}

	// 检查是否过期
	if time.Now().After(rt.ExpiresAt) {
		s.refreshTokenRepo.DeleteByToken(req.RefreshToken)
		return nil, errors.New("refresh_token_expired")
	}

	// 查找用户
	user, err := s.userRepo.FindByUserID(rt.UserID)
	if err != nil {
		return nil, err
	}

	// 生成新 JWT
	token, err := s.generateJWT(user)
	if err != nil {
		return nil, err
	}

	return &RefreshTokenResponse{
		Token:     token,
		ExpiresIn: s.jwtExpireHours * 3600,
	}, nil
}

// GetUserByID 获取用户信息
func (s *UserService) GetUserByID(userID string) (*UserInfo, error) {
	user, err := s.userRepo.FindByUserID(userID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user_not_found")
		}
		return nil, err
	}

	return &UserInfo{
		UserID: user.UserID,
		Email:  user.Email,
		Name:   user.Name,
		Phone:  user.Phone,
		Avatar: user.Avatar,
	}, nil
}

// ========== JWT 相关 ==========

// JWTClaims JWT 声明
type JWTClaims struct {
	UserID string `json:"userId"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

// generateJWT 生成 JWT
func (s *UserService) generateJWT(user *model.User) (string, error) {
	claims := JWTClaims{
		UserID: user.UserID,
		Email:  user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Duration(s.jwtExpireHours) * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "iot-platform-core",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

// ValidateJWT 验证 JWT
func (s *UserService) ValidateJWT(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.jwtSecret), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid_token")
}

// generateRefreshToken 生成刷新令牌
func (s *UserService) generateRefreshToken(userID string) (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	token := "rt_" + hex.EncodeToString(bytes)

	rt := &model.RefreshToken{
		Token:     token,
		UserID:    userID,
		ExpiresAt: time.Now().Add(7 * 24 * time.Hour), // 7天过期
	}

	if err := s.refreshTokenRepo.Create(rt); err != nil {
		return "", err
	}

	return token, nil
}

// ========== API Key 相关 ==========

// CreateAPIKeyRequest 创建 API Key 请求
type CreateAPIKeyRequest struct {
	Name        string   `json:"name" binding:"required"`
	Permissions []string `json:"permissions"`
	ExpiresAt   string   `json:"expiresAt"`
}

// CreateAPIKeyResponse 创建 API Key 响应
type CreateAPIKeyResponse struct {
	KeyID     string `json:"keyId"`
	APIKey    string `json:"apiKey"`
	APISecret string `json:"apiSecret"`
	Name      string `json:"name"`
	CreatedAt string `json:"createdAt"`
}

// CreateAPIKey 创建 API Key
func (s *UserService) CreateAPIKey(userID string, req *CreateAPIKeyRequest) (*CreateAPIKeyResponse, error) {
	// 生成 API Key
	apiKey := "ak_" + generateRandomString(16)
	apiSecret := "sk_" + generateRandomString(32)

	// 解析过期时间
	var expiresAt *time.Time
	if req.ExpiresAt != "" {
		t, err := time.Parse("2006-01-02", req.ExpiresAt)
		if err == nil {
			expiresAt = &t
		}
	}

	// 将权限转为 JSON 字符串
	permissions := ""
	if len(req.Permissions) > 0 {
		// 简单处理：逗号分隔
		for i, p := range req.Permissions {
			if i > 0 {
				permissions += ","
			}
			permissions += p
		}
	}

	key := &model.APIKey{
		KeyID:       "key_" + uuid.New().String()[:8],
		UserID:      userID,
		APIKey:      apiKey,
		APISecret:   apiSecret,
		Name:        req.Name,
		Permissions: permissions,
		ExpiresAt:   expiresAt,
		Status:      1,
	}

	if err := s.apiKeyRepo.Create(key); err != nil {
		return nil, err
	}

	return &CreateAPIKeyResponse{
		KeyID:     key.KeyID,
		APIKey:    apiKey,
		APISecret: apiSecret,
		Name:      key.Name,
		CreatedAt: key.CreatedAt.Format("2006-01-02 15:04:05"),
	}, nil
}

// APIKeyInfo API Key 信息
type APIKeyInfo struct {
	KeyID       string  `json:"keyId"`
	APIKey      string  `json:"apiKey"`
	Name        string  `json:"name"`
	Permissions string  `json:"permissions"`
	LastUsedAt  *string `json:"lastUsedAt"`
	CreatedAt   string  `json:"createdAt"`
}

// GetAPIKeys 获取 API Key 列表
func (s *UserService) GetAPIKeys(userID string) ([]APIKeyInfo, error) {
	keys, err := s.apiKeyRepo.FindByUserID(userID)
	if err != nil {
		return nil, err
	}

	result := make([]APIKeyInfo, len(keys))
	for i, k := range keys {
		// 隐藏中间部分
		maskedKey := k.APIKey[:7] + "****" + k.APIKey[len(k.APIKey)-4:]
		result[i] = APIKeyInfo{
			KeyID:       k.KeyID,
			APIKey:      maskedKey,
			Name:        k.Name,
			Permissions: k.Permissions,
			CreatedAt:   k.CreatedAt.Format("2006-01-02 15:04:05"),
		}
		if k.LastUsedAt != nil {
			t := k.LastUsedAt.Format("2006-01-02 15:04:05")
			result[i].LastUsedAt = &t
		}
	}

	return result, nil
}

// DeleteAPIKey 删除 API Key
func (s *UserService) DeleteAPIKey(userID, keyID string) error {
	// 验证 Key 属于该用户
	key, err := s.apiKeyRepo.FindByKeyID(keyID)
	if err != nil {
		return errors.New("key_not_found")
	}

	if key.UserID != userID {
		return errors.New("forbidden")
	}

	return s.apiKeyRepo.Delete(keyID)
}

// ValidateAPIKey 验证 API Key
func (s *UserService) ValidateAPIKey(apiKey, apiSecret string) (*model.APIKey, error) {
	key, err := s.apiKeyRepo.FindByAPIKey(apiKey)
	if err != nil {
		return nil, errors.New("invalid_api_key")
	}

	// 验证 Secret
	if key.APISecret != apiSecret {
		return nil, errors.New("invalid_api_secret")
	}

	// 检查是否过期
	if key.ExpiresAt != nil && time.Now().After(*key.ExpiresAt) {
		return nil, errors.New("api_key_expired")
	}

	// 更新最后使用时间
	s.apiKeyRepo.UpdateLastUsed(key.KeyID)

	return key, nil
}

// ========== 辅助函数 ==========

func isValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	matched, _ := regexp.MatchString(pattern, email)
	return matched
}

func isStrongPassword(password string) bool {
	// 至少8位，包含大小写字母和数字
	if len(password) < 8 {
		return false
	}
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
	hasLower := regexp.MustCompile(`[a-z]`).MatchString(password)
	hasDigit := regexp.MustCompile(`[0-9]`).MatchString(password)
	return hasUpper && hasLower && hasDigit
}

func generateRandomString(length int) string {
	bytes := make([]byte, length)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)[:length]
}
