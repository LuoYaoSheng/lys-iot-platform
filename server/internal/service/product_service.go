// 产品服务层
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
	"errors"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"gorm.io/gorm"
)

// ProductService 产品服务
type ProductService struct {
	productRepo *repository.ProductRepository
}

func NewProductService(productRepo *repository.ProductRepository) *ProductService {
	return &ProductService{
		productRepo: productRepo,
	}
}

// ========== 产品 CRUD ==========

// CreateProductRequest 创建产品请求
type CreateProductRequest struct {
	ProductKey  string `json:"productKey" binding:"required"`
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Category    string `json:"category" binding:"required"`
}

// ProductInfo 产品信息
type ProductInfo struct {
	ID           int64  `json:"id"`
	ProductKey   string `json:"productKey"`
	Name         string `json:"name"`
	Description  string `json:"description,omitempty"`
	Category     string `json:"category,omitempty"`
	DeviceCount  int64  `json:"deviceCount,omitempty"`
	Status       int    `json:"status,omitempty"`
	CreatedAt    string `json:"createdAt,omitempty"`
	// v0.2.0: UI控制相关字段
	ControlMode  string `json:"controlMode,omitempty"`  // toggle/pulse/dimmer/readonly/generic
	UITemplate   string `json:"uiTemplate,omitempty"`   // UI模板名称
	IconName     string `json:"iconName,omitempty"`     // 图标名称(Material Icons)
	IconColor    string `json:"iconColor,omitempty"`    // 图标颜色(HEX，如 #FF6B35)
	Manufacturer string `json:"manufacturer,omitempty"` // 制造商
	Model        string `json:"model,omitempty"`        // 硬件型号
}

// CreateProduct 创建产品
func (s *ProductService) CreateProduct(req *CreateProductRequest) (*ProductInfo, error) {
	// 检查 ProductKey 是否已存在
	_, err := s.productRepo.FindByProductKey(req.ProductKey)
	if err == nil {
		return nil, errors.New("product_key_exists")
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	product := &model.Product{
		ProductKey:  req.ProductKey,
		Name:        req.Name,
		Description: req.Description,
		Category:    req.Category,
		Status:      1,
	}

	if err := s.productRepo.Create(product); err != nil {
		return nil, err
	}

	return &ProductInfo{
		ID:          product.ID,
		ProductKey:  product.ProductKey,
		Name:        product.Name,
		Description: product.Description,
		Category:    product.Category,
		Status:      product.Status,
		CreatedAt:   product.CreatedAt.Format(time.RFC3339),
	}, nil
}

// ProductListResponse 产品列表响应
type ProductListResponse struct {
	Total    int64         `json:"total"`
	Page     int           `json:"page"`
	Size     int           `json:"size"`
	Products []ProductInfo `json:"products"`
}

// GetProductList 获取产品列表
func (s *ProductService) GetProductList(category string, status *int, page, size int) (*ProductListResponse, error) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}

	offset := (page - 1) * size
	products, total, err := s.productRepo.FindAll(category, status, size, offset)
	if err != nil {
		return nil, err
	}

	productInfos := make([]ProductInfo, len(products))
	for i, p := range products {
		deviceCount, _ := s.productRepo.CountDevices(p.ProductKey)
		productInfos[i] = ProductInfo{
			ID:           p.ID,
			ProductKey:   p.ProductKey,
			Name:         p.Name,
			Description:  p.Description,
			Category:     p.Category,
			DeviceCount:  deviceCount,
			Status:       p.Status,
			CreatedAt:    p.CreatedAt.Format(time.RFC3339),
			ControlMode:  p.ControlMode,
			UITemplate:   p.UITemplate,
			IconName:     p.IconName,
			IconColor:    p.IconColor,
			Manufacturer: p.Manufacturer,
			Model:        p.Model,
		}
	}

	return &ProductListResponse{
		Total:    total,
		Page:     page,
		Size:     size,
		Products: productInfos,
	}, nil
}

// GetProductByKey 获取产品详情
func (s *ProductService) GetProductByKey(productKey string) (*ProductInfo, error) {
	product, err := s.productRepo.FindByProductKey(productKey)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product_not_found")
		}
		return nil, err
	}

	deviceCount, _ := s.productRepo.CountDevices(productKey)

	return &ProductInfo{
		ID:           product.ID,
		ProductKey:   product.ProductKey,
		Name:         product.Name,
		Description:  product.Description,
		Category:     product.Category,
		DeviceCount:  deviceCount,
		Status:       product.Status,
		CreatedAt:    product.CreatedAt.Format(time.RFC3339),
		ControlMode:  product.ControlMode,
		UITemplate:   product.UITemplate,
		IconName:     product.IconName,
		IconColor:    product.IconColor,
		Manufacturer: product.Manufacturer,
		Model:        product.Model,
	}, nil
}

// UpdateProductRequest 更新产品请求
type UpdateProductRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Status      *int   `json:"status"`
}

// UpdateProduct 更新产品
func (s *ProductService) UpdateProduct(productKey string, req *UpdateProductRequest) (*ProductInfo, error) {
	product, err := s.productRepo.FindByProductKey(productKey)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("product_not_found")
		}
		return nil, err
	}

	// 更新字段
	if req.Name != "" {
		product.Name = req.Name
	}
	if req.Description != "" {
		product.Description = req.Description
	}
	if req.Status != nil {
		product.Status = *req.Status
	}

	if err := s.productRepo.Update(product); err != nil {
		return nil, err
	}

	deviceCount, _ := s.productRepo.CountDevices(productKey)

	return &ProductInfo{
		ID:           product.ID,
		ProductKey:   product.ProductKey,
		Name:         product.Name,
		Description:  product.Description,
		Category:     product.Category,
		DeviceCount:  deviceCount,
		Status:       product.Status,
		CreatedAt:    product.CreatedAt.Format(time.RFC3339),
		ControlMode:  product.ControlMode,
		UITemplate:   product.UITemplate,
		IconName:     product.IconName,
		IconColor:    product.IconColor,
		Manufacturer: product.Manufacturer,
		Model:        product.Model,
	}, nil
}

// DeleteProduct 删除产品
func (s *ProductService) DeleteProduct(productKey string) error {
	// 检查产品是否存在
	_, err := s.productRepo.FindByProductKey(productKey)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("product_not_found")
		}
		return err
	}

	// 检查是否有关联设备
	deviceCount, err := s.productRepo.CountDevices(productKey)
	if err != nil {
		return err
	}
	if deviceCount > 0 {
		return errors.New("product_has_devices")
	}

	return s.productRepo.Delete(productKey)
}
