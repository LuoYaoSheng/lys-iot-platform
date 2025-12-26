// EMQX API 客户端服务
// 作者: 罗耀生
// 日期: 2025-12-16
// 用于调用 EMQX 管理 API 查询在线设备

package service

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"
)

// EMQXService EMQX API 客户端
type EMQXService struct {
	apiURL   string // EMQX API 地址，例如: http://localhost:18083
	username string // 管理员用户名
	password string // 管理员密码
	client   *http.Client
}

// NewEMQXService 创建 EMQX 服务
func NewEMQXService(apiURL, username, password string) *EMQXService {
	return &EMQXService{
		apiURL:   strings.TrimSuffix(apiURL, "/"),
		username: username,
		password: password,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// EMQXClient EMQX 客户端信息
type EMQXClient struct {
	ClientID    string `json:"clientid"`
	Username    string `json:"username"`
	IPAddress   string `json:"ip_address"`
	ConnectedAt string `json:"connected_at"`
	Node        string `json:"node"`
}

// EMQXClientsResponse EMQX客户端列表响应
type EMQXClientsResponse struct {
	Data []EMQXClient `json:"data"`
	Meta struct {
		Page  int `json:"page"`
		Limit int `json:"limit"`
		Count int `json:"count"`
	} `json:"meta"`
}

// GetOnlineClients 获取所有在线客户端
func (s *EMQXService) GetOnlineClients() ([]EMQXClient, error) {
	url := fmt.Sprintf("%s/api/v5/clients", s.apiURL)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %v", err)
	}

	req.SetBasicAuth(s.username, s.password)
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("请求EMQX API失败: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("EMQX API返回错误: %d, %s", resp.StatusCode, string(body))
	}

	var result EMQXClientsResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	log.Printf("[EMQX] 查询到 %d 个在线客户端", len(result.Data))
	return result.Data, nil
}

// GetClientByClientID 根据ClientID查询客户端信息
func (s *EMQXService) GetClientByClientID(clientID string) (*EMQXClient, error) {
	url := fmt.Sprintf("%s/api/v5/clients/%s", s.apiURL, clientID)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %v", err)
	}

	req.SetBasicAuth(s.username, s.password)
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("请求EMQX API失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return nil, nil // 客户端不在线
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("EMQX API返回错误: %d, %s", resp.StatusCode, string(body))
	}

	var client EMQXClient
	if err := json.Unmarshal(body, &client); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	return &client, nil
}

// KickClient 踢出客户端
func (s *EMQXService) KickClient(clientID string) error {
	url := fmt.Sprintf("%s/api/v5/clients/%s", s.apiURL, clientID)

	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %v", err)
	}

	req.SetBasicAuth(s.username, s.password)

	resp, err := s.client.Do(req)
	if err != nil {
		return fmt.Errorf("请求EMQX API失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("EMQX API返回错误: %d, %s", resp.StatusCode, string(body))
	}

	log.Printf("[EMQX] 成功踢出客户端: %s", clientID)
	return nil
}

// EMQXWebhookConfig Webhook 配置
type EMQXWebhookConfig struct {
	Name        string            `json:"name"`
	Enable      bool              `json:"enable"`
	Type        string            `json:"type"`
	URL         string            `json:"url"`
	Method      string            `json:"method"`
	Headers     map[string]string `json:"headers"`
	Body        string            `json:"body,omitempty"`
	ConnectTimeout int            `json:"connect_timeout"`
	RequestTimeout int            `json:"request_timeout"`
}

// CreateOrUpdateWebhook 创建或更新Webhook (EMQX 5.x使用Actions)
// 注意：此方法提供参考，实际配置建议通过EMQX Dashboard或配置文件完成
func (s *EMQXService) CreateOrUpdateWebhook(hookName, targetURL string, events []string) error {
	log.Printf("[EMQX] Webhook配置建议通过EMQX Dashboard手动配置")
	log.Printf("[EMQX] 目标URL: %s", targetURL)
	log.Printf("[EMQX] 需要配置的事件: %v", events)

	// EMQX 5.x 使用 Rules + Actions 代替旧版 Webhooks
	// 建议通过 Dashboard 配置：
	// 1. 创建 Action: Integration -> Data Integration -> Actions -> HTTP Server
	// 2. 创建 Rule: Integration -> Data Integration -> Rules
	//    - client.connected 事件规则: SELECT * FROM "$events/client_connected"
	//    - client.disconnected 事件规则: SELECT * FROM "$events/client_disconnected"

	return fmt.Errorf("请通过EMQX Dashboard配置Webhook规则")
}

// TestConnection 测试EMQX API连接
func (s *EMQXService) TestConnection() error {
	url := fmt.Sprintf("%s/api/v5/nodes", s.apiURL)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %v", err)
	}

	req.SetBasicAuth(s.username, s.password)

	resp, err := s.client.Do(req)
	if err != nil {
		return fmt.Errorf("连接EMQX API失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("EMQX API认证失败: %d, %s", resp.StatusCode, string(body))
	}

	log.Println("[EMQX] API连接测试成功")
	return nil
}
