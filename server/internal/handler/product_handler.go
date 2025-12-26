// 产品处理器
// 作者: 罗耀生
// 日期: 2025-12-13

package handler

import (
	"fmt"
	"log"
	"net/http"

	"iot-platform-core/internal/service"
	"iot-platform-core/pkg/response"

	"github.com/gin-gonic/gin"
)

type ProductHandler struct {
	productService *service.ProductService
}

func NewProductHandler(productService *service.ProductService) *ProductHandler {
	return &ProductHandler{
		productService: productService,
	}
}

// CreateProduct 创建产品
// POST /api/v1/products
func (h *ProductHandler) CreateProduct(c *gin.Context) {
	var req service.CreateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[CreateProduct] ProductKey=%s, Name=%s", req.ProductKey, req.Name)

	resp, err := h.productService.CreateProduct(&req)
	if err != nil {
		switch err.Error() {
		case "product_key_exists":
			response.Conflict(c, "product_key_exists", nil)
		default:
			log.Printf("[CreateProduct] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	log.Printf("[CreateProduct] Success: ProductKey=%s", resp.ProductKey)
	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "success",
		"data":    resp,
	})
}

// GetProductList 获取产品列表
// GET /api/v1/products
func (h *ProductHandler) GetProductList(c *gin.Context) {
	category := c.Query("category")
	statusStr := c.Query("status")
	pageStr := c.DefaultQuery("page", "1")
	sizeStr := c.DefaultQuery("size", "20")

	page := 1
	size := 20
	fmt.Sscanf(pageStr, "%d", &page)
	fmt.Sscanf(sizeStr, "%d", &size)

	var status *int
	if statusStr != "" {
		var s int
		fmt.Sscanf(statusStr, "%d", &s)
		status = &s
	}

	resp, err := h.productService.GetProductList(category, status, page, size)
	if err != nil {
		log.Printf("[GetProductList] Error: %v", err)
		response.InternalError(c, "internal_error")
		return
	}

	response.Success(c, resp)
}

// GetProduct 获取产品详情
// GET /api/v1/products/:productKey
func (h *ProductHandler) GetProduct(c *gin.Context) {
	productKey := c.Param("productKey")
	if productKey == "" {
		response.BadRequest(c, "product_key_required")
		return
	}

	info, err := h.productService.GetProductByKey(productKey)
	if err != nil {
		switch err.Error() {
		case "product_not_found":
			response.NotFound(c, "product_not_found")
		default:
			log.Printf("[GetProduct] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, info)
}

// UpdateProduct 更新产品
// PUT /api/v1/products/:productKey
func (h *ProductHandler) UpdateProduct(c *gin.Context) {
	productKey := c.Param("productKey")
	if productKey == "" {
		response.BadRequest(c, "product_key_required")
		return
	}

	var req service.UpdateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	log.Printf("[UpdateProduct] ProductKey=%s", productKey)

	info, err := h.productService.UpdateProduct(productKey, &req)
	if err != nil {
		switch err.Error() {
		case "product_not_found":
			response.NotFound(c, "product_not_found")
		default:
			log.Printf("[UpdateProduct] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, info)
}

// DeleteProduct 删除产品
// DELETE /api/v1/products/:productKey
func (h *ProductHandler) DeleteProduct(c *gin.Context) {
	productKey := c.Param("productKey")
	if productKey == "" {
		response.BadRequest(c, "product_key_required")
		return
	}

	log.Printf("[DeleteProduct] ProductKey=%s", productKey)

	err := h.productService.DeleteProduct(productKey)
	if err != nil {
		switch err.Error() {
		case "product_not_found":
			response.NotFound(c, "product_not_found")
		case "product_has_devices":
			response.BadRequest(c, "product_has_devices")
		default:
			log.Printf("[DeleteProduct] Error: %v", err)
			response.InternalError(c, "internal_error")
		}
		return
	}

	response.Success(c, gin.H{"message": "deleted"})
}
