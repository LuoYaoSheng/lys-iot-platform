package config

import "testing"

func TestLoadUsesEnvironmentOverrides(t *testing.T) {
	t.Setenv("SERVER_PORT", "58080")
	t.Setenv("DB_HOST", "db.internal")
	t.Setenv("DB_PORT", "3307")
	t.Setenv("DB_USER", "tester")
	t.Setenv("DB_PASSWORD", "secret")
	t.Setenv("DB_NAME", "iot_test")
	t.Setenv("REDIS_HOST", "redis.internal")
	t.Setenv("REDIS_PORT", "6380")
	t.Setenv("MQTT_BROKER", "mqtt.internal")
	t.Setenv("MQTT_BROKER_EXTERNAL", "mqtt.example.com")
	t.Setenv("MQTT_PORT", "2883")
	t.Setenv("JWT_SECRET", "jwt-test-secret")
	t.Setenv("JWT_EXPIRE_HOURS", "6")
	t.Setenv("EMQX_API_URL", "http://emqx.internal:18083")
	t.Setenv("EMQX_API_USERNAME", "admin")
	t.Setenv("EMQX_API_PASSWORD", "public")
	t.Setenv("EMQX_SYNC_INTERVAL", "9")

	cfg := Load()

	if cfg.Server.Port != "58080" {
		t.Fatalf("expected server port override, got %q", cfg.Server.Port)
	}
	if cfg.Database.Host != "db.internal" || cfg.Database.Port != "3307" {
		t.Fatalf("unexpected database config: %+v", cfg.Database)
	}
	if cfg.Database.Password != "secret" {
		t.Fatalf("expected DB password override, got %q", cfg.Database.Password)
	}
	if cfg.Redis.Host != "redis.internal" || cfg.Redis.Port != "6380" {
		t.Fatalf("unexpected redis config: %+v", cfg.Redis)
	}
	if cfg.MQTT.Broker != "mqtt.internal" || cfg.MQTT.BrokerExternal != "mqtt.example.com" || cfg.MQTT.Port != 2883 {
		t.Fatalf("unexpected mqtt config: %+v", cfg.MQTT)
	}
	if cfg.JWT.Secret != "jwt-test-secret" || cfg.JWT.ExpireHours != 6 {
		t.Fatalf("unexpected jwt config: %+v", cfg.JWT)
	}
	if cfg.EMQX.APIUrl != "http://emqx.internal:18083" || cfg.EMQX.SyncInterval != 9 {
		t.Fatalf("unexpected emqx config: %+v", cfg.EMQX)
	}
}

func TestGetEnvIntFallsBackOnInvalidValue(t *testing.T) {
	t.Setenv("INVALID_INT", "not-a-number")

	if got := getEnvInt("INVALID_INT", 42); got != 42 {
		t.Fatalf("expected fallback value 42, got %d", got)
	}
}
