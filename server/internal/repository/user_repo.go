// 用户仓库层
// 作者: 罗耀生
// 日期: 2025-12-13

package repository

import (
	"iot-platform-core/internal/model"

	"gorm.io/gorm"
)

// UserRepository 用户仓库
type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

// FindByUserID 根据用户ID查找
func (r *UserRepository) FindByUserID(userID string) (*model.User, error) {
	var user model.User
	err := r.db.Where("user_id = ?", userID).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByEmail 根据邮箱查找
func (r *UserRepository) FindByEmail(email string) (*model.User, error) {
	var user model.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Create 创建用户
func (r *UserRepository) Create(user *model.User) error {
	return r.db.Create(user).Error
}

// Update 更新用户
func (r *UserRepository) Update(user *model.User) error {
	return r.db.Save(user).Error
}

// UpdateLastLogin 更新最后登录时间
func (r *UserRepository) UpdateLastLogin(userID string) error {
	return r.db.Model(&model.User{}).
		Where("user_id = ?", userID).
		Update("last_login_at", gorm.Expr("NOW()")).Error
}

// APIKeyRepository API密钥仓库
type APIKeyRepository struct {
	db *gorm.DB
}

func NewAPIKeyRepository(db *gorm.DB) *APIKeyRepository {
	return &APIKeyRepository{db: db}
}

// FindByAPIKey 根据APIKey查找
func (r *APIKeyRepository) FindByAPIKey(apiKey string) (*model.APIKey, error) {
	var key model.APIKey
	err := r.db.Where("api_key = ? AND status = 1", apiKey).First(&key).Error
	if err != nil {
		return nil, err
	}
	return &key, nil
}

// FindByKeyID 根据KeyID查找
func (r *APIKeyRepository) FindByKeyID(keyID string) (*model.APIKey, error) {
	var key model.APIKey
	err := r.db.Where("key_id = ?", keyID).First(&key).Error
	if err != nil {
		return nil, err
	}
	return &key, nil
}

// FindByUserID 根据用户ID查找所有API Key
func (r *APIKeyRepository) FindByUserID(userID string) ([]model.APIKey, error) {
	var keys []model.APIKey
	err := r.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&keys).Error
	if err != nil {
		return nil, err
	}
	return keys, nil
}

// Create 创建API Key
func (r *APIKeyRepository) Create(key *model.APIKey) error {
	return r.db.Create(key).Error
}

// Delete 删除API Key
func (r *APIKeyRepository) Delete(keyID string) error {
	return r.db.Where("key_id = ?", keyID).Delete(&model.APIKey{}).Error
}

// UpdateLastUsed 更新最后使用时间
func (r *APIKeyRepository) UpdateLastUsed(keyID string) error {
	return r.db.Model(&model.APIKey{}).
		Where("key_id = ?", keyID).
		Update("last_used_at", gorm.Expr("NOW()")).Error
}

// RefreshTokenRepository 刷新令牌仓库
type RefreshTokenRepository struct {
	db *gorm.DB
}

func NewRefreshTokenRepository(db *gorm.DB) *RefreshTokenRepository {
	return &RefreshTokenRepository{db: db}
}

// FindByToken 根据Token查找
func (r *RefreshTokenRepository) FindByToken(token string) (*model.RefreshToken, error) {
	var rt model.RefreshToken
	err := r.db.Where("token = ?", token).First(&rt).Error
	if err != nil {
		return nil, err
	}
	return &rt, nil
}

// Create 创建刷新令牌
func (r *RefreshTokenRepository) Create(token *model.RefreshToken) error {
	return r.db.Create(token).Error
}

// DeleteByUserID 删除用户的所有刷新令牌
func (r *RefreshTokenRepository) DeleteByUserID(userID string) error {
	return r.db.Where("user_id = ?", userID).Delete(&model.RefreshToken{}).Error
}

// DeleteByToken 删除指定令牌
func (r *RefreshTokenRepository) DeleteByToken(token string) error {
	return r.db.Where("token = ?", token).Delete(&model.RefreshToken{}).Error
}

// DeleteExpired 删除过期令牌
func (r *RefreshTokenRepository) DeleteExpired() error {
	return r.db.Where("expires_at < NOW()").Delete(&model.RefreshToken{}).Error
}
