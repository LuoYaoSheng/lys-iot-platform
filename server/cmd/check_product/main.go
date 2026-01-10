// 临时检查产品数据
package main

import (
	"fmt"
	"iot-platform-core/internal/config"
	"iot-platform-core/internal/repository"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	cfg := config.Load()
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		cfg.Database.User, cfg.Database.Password, cfg.Database.Host, cfg.Database.Port, cfg.Database.DBName)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Printf("DB error: %v\n", err)
		return
	}

	repo := repository.NewProductRepository(db)
	p, err := repo.FindByProductKey("SW-SERVO-001")
	if err != nil {
		fmt.Printf("Product not found: %v\n", err)
		return
	}

	// 更新产品名称为英文，避免编码问题
	p.Name = "Smart Servo Switch"
	p.Description = "ESP32 Smart Servo Switch with BLE provisioning"
	fmt.Printf("Updating product: %s\n", p.ProductKey)
	db.Save(&p)

	fmt.Printf("ProductKey: %s\n", p.ProductKey)
	fmt.Printf("Name: %s\n", p.Name)
	fmt.Printf("Description: %s\n", p.Description)
	fmt.Printf("ControlMode: %s\n", p.ControlMode)
	fmt.Printf("UITemplate: %s\n", p.UITemplate)
	fmt.Printf("IconName: %s\n", p.IconName)
	fmt.Printf("IconColor: %s\n", p.IconColor)
}
