// 密码重置令牌仓储
// 作者: 罗耀生
// 日期: 2025-01-12

package repository

import (
	"errors"
	"iot-platform-core/internal/model"
	"time"

	"gorm.io/gorm"
)

type PasswordResetTokenRepository struct {
	db *gorm.DB
}

func NewPasswordResetTokenRepository(db *gorm.DB) *PasswordResetTokenRepository {
	return &PasswordResetTokenRepository{db: db}
}

// Create 创建重置令牌
func (r *PasswordResetTokenRepository) Create(token *model.PasswordResetToken) error {
	return r.db.Create(token).Error
}

// FindByToken 根据令牌查找
func (r *PasswordResetTokenRepository) FindByToken(token string) (*model.PasswordResetToken, error) {
	var t model.PasswordResetToken
	err := r.db.Where("token = ?", token).First(&t).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, gorm.ErrRecordNotFound
		}
		return nil, err
	}
	return &t, nil
}

// FindValidByToken 查找有效的未使用令牌
func (r *PasswordResetTokenRepository) FindValidByToken(token string) (*model.PasswordResetToken, error) {
	var t model.PasswordResetToken
	err := r.db.Where("token = ? AND used_at IS NULL AND expires_at > ?", token, time.Now()).First(&t).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, gorm.ErrRecordNotFound
		}
		return nil, err
	}
	return &t, nil
}

// MarkAsUsed 标记令牌已使用
func (r *PasswordResetTokenRepository) MarkAsUsed(token string) error {
	return r.db.Model(&model.PasswordResetToken{}).
		Where("token = ?", token).
		Update("used_at", time.Now()).Error
}

// DeleteExpired 删除过期令牌（清理任务）
func (r *PasswordResetTokenRepository) DeleteExpired() error {
	return r.db.Where("expires_at < ? OR used_at IS NOT NULL", time.Now().Add(-24*time.Hour)).
		Delete(&model.PasswordResetToken{}).Error
}
