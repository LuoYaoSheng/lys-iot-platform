// 产品服务层
// 作者: 罗耀生
// 日期: 2025-12-13

package service

import (
	"errors"

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
	ControlMode string `json:"controlMode"`
	UITemplate  string `json:"uiTemplate"`
	IconName    string `json:"iconName"`
	IconColor   string `json:"iconColor"`
}

// ProductInfo 产品信息
type ProductInfo struct {
	ID          int64  `json:"id"`
	ProductKey  string `json:"productKey"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Category    string `json:"category"`
	ControlMode string `json:"controlMode,omitempty"`
	UITemplate  string `json:"uiTemplate,omitempty"`
	IconName    string `json:"iconName,omitempty"`
	IconColor   string `json:"iconColor,omitempty"`
	DeviceCount int64  `json:"deviceCount"`
	Status      int    `json:"status"`
	CreatedAt   string `json:"createdAt"`
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
		ControlMode: req.ControlMode,
		UITemplate:  req.UITemplate,
		IconName:    req.IconName,
		IconColor:   req.IconColor,
		NodeType:    "device",
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
		ControlMode: product.ControlMode,
		UITemplate:  product.UITemplate,
		IconName:    product.IconName,
		IconColor:   product.IconColor,
		Status:      product.Status,
		CreatedAt:   product.CreatedAt.Format("2006-01-02 15:04:05"),
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
			ID:          p.ID,
			ProductKey:  p.ProductKey,
			Name:        p.Name,
			Description: p.Description,
			Category:    p.Category,
			ControlMode: p.ControlMode,
			UITemplate:  p.UITemplate,
			IconName:    p.IconName,
			IconColor:   p.IconColor,
			DeviceCount: deviceCount,
			Status:      p.Status,
			CreatedAt:   p.CreatedAt.Format("2006-01-02 15:04:05"),
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
		ID:          product.ID,
		ProductKey:  product.ProductKey,
		Name:        product.Name,
		Description: product.Description,
		Category:    product.Category,
		ControlMode: product.ControlMode,
		UITemplate:  product.UITemplate,
		IconName:    product.IconName,
		IconColor:   product.IconColor,
		DeviceCount: deviceCount,
		Status:      product.Status,
		CreatedAt:   product.CreatedAt.Format("2006-01-02 15:04:05"),
	}, nil
}

// UpdateProductRequest 更新产品请求
type UpdateProductRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	ControlMode string `json:"controlMode"`
	UITemplate  string `json:"uiTemplate"`
	IconName    string `json:"iconName"`
	IconColor   string `json:"iconColor"`
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
	if req.ControlMode != "" {
		product.ControlMode = req.ControlMode
	}
	if req.UITemplate != "" {
		product.UITemplate = req.UITemplate
	}
	if req.IconName != "" {
		product.IconName = req.IconName
	}
	if req.IconColor != "" {
		product.IconColor = req.IconColor
	}
	if req.Status != nil {
		product.Status = *req.Status
	}

	if err := s.productRepo.Update(product); err != nil {
		return nil, err
	}

	deviceCount, _ := s.productRepo.CountDevices(productKey)

	return &ProductInfo{
		ID:          product.ID,
		ProductKey:  product.ProductKey,
		Name:        product.Name,
		Description: product.Description,
		Category:    product.Category,
		ControlMode: product.ControlMode,
		UITemplate:  product.UITemplate,
		IconName:    product.IconName,
		IconColor:   product.IconColor,
		DeviceCount: deviceCount,
		Status:      product.Status,
		CreatedAt:   product.CreatedAt.Format("2006-01-02 15:04:05"),
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
