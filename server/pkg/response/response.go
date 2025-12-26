// 统一响应格式
// 作者: 罗耀生
// 日期: 2025-12-13

package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Response 统一响应结构
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// Success 成功响应
func Success(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "success",
		Data:    data,
	})
}

// Created 创建成功响应 (201)
func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, Response{
		Code:    201,
		Message: "created",
		Data:    data,
	})
}

// Error 错误响应
func Error(c *gin.Context, httpCode int, code int, message string) {
	c.JSON(httpCode, Response{
		Code:    code,
		Message: message,
	})
}

// SimpleError 简化的错误响应 (httpCode = code)
func SimpleError(c *gin.Context, httpCode int, message string) {
	Error(c, httpCode, httpCode, message)
}

// ErrorWithData 带数据的错误响应
func ErrorWithData(c *gin.Context, httpCode int, code int, message string, data interface{}) {
	c.JSON(httpCode, Response{
		Code:    code,
		Message: message,
		Data:    data,
	})
}

// BadRequest 请求参数错误
func BadRequest(c *gin.Context, message string) {
	Error(c, http.StatusBadRequest, 400, message)
}

// Unauthorized 未授权
func Unauthorized(c *gin.Context, message string) {
	Error(c, http.StatusUnauthorized, 401, message)
}

// Forbidden 禁止访问
func Forbidden(c *gin.Context, message string) {
	Error(c, http.StatusForbidden, 403, message)
}

// NotFound 资源不存在
func NotFound(c *gin.Context, message string) {
	Error(c, http.StatusNotFound, 404, message)
}

// Conflict 资源冲突
func Conflict(c *gin.Context, message string, data interface{}) {
	ErrorWithData(c, http.StatusConflict, 409, message, data)
}

// InternalError 服务器内部错误
func InternalError(c *gin.Context, message string) {
	Error(c, http.StatusInternalServerError, 500, message)
}
