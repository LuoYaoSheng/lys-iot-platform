package service

import (
	"strings"
	"testing"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
)

func TestRegisterLoginAndRefreshTokenRoundTrip(t *testing.T) {
	db := newTestDB(t)
	svc := newUserServiceForTest(db)

	registerResp, err := svc.Register(&RegisterRequest{
		Email:    "tester@example.com",
		Password: "StrongPass1",
		Name:     "Tester",
		Phone:    "13800138000",
	})
	if err != nil {
		t.Fatalf("Register returned error: %v", err)
	}
	if registerResp.UserID == "" {
		t.Fatal("expected Register to return user id")
	}

	storedUser, err := repository.NewUserRepository(db).FindByEmail("tester@example.com")
	if err != nil {
		t.Fatalf("FindByEmail returned error: %v", err)
	}
	if storedUser.PasswordHash == "StrongPass1" || storedUser.PasswordHash == "" {
		t.Fatal("expected password to be hashed before storage")
	}

	loginResp, err := svc.Login(&LoginRequest{
		Email:    "tester@example.com",
		Password: "StrongPass1",
	})
	if err != nil {
		t.Fatalf("Login returned error: %v", err)
	}
	if loginResp.Token == "" || loginResp.RefreshToken == "" {
		t.Fatalf("expected login tokens, got %+v", loginResp)
	}

	claims, err := svc.ValidateJWT(loginResp.Token)
	if err != nil {
		t.Fatalf("ValidateJWT returned error: %v", err)
	}
	if claims.UserID != registerResp.UserID {
		t.Fatalf("expected claims user id %q, got %q", registerResp.UserID, claims.UserID)
	}

	refreshResp, err := svc.RefreshToken(&RefreshTokenRequest{
		RefreshToken: loginResp.RefreshToken,
	})
	if err != nil {
		t.Fatalf("RefreshToken returned error: %v", err)
	}
	if refreshResp.Token == "" || refreshResp.ExpiresIn != 7200 {
		t.Fatalf("unexpected refresh response: %+v", refreshResp)
	}
}

func TestIsValidEmail(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name  string
		email string
		want  bool
	}{
		{name: "valid", email: "user@example.com", want: true},
		{name: "missing at", email: "user.example.com", want: false},
		{name: "missing domain", email: "user@", want: false},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := isValidEmail(tc.email); got != tc.want {
				t.Fatalf("isValidEmail(%q) = %v, want %v", tc.email, got, tc.want)
			}
		})
	}
}

func TestIsStrongPassword(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name     string
		password string
		want     bool
	}{
		{name: "valid", password: "StrongPass1", want: true},
		{name: "too short", password: "Aa1", want: false},
		{name: "missing upper", password: "weakpass1", want: false},
		{name: "missing lower", password: "WEAKPASS1", want: false},
		{name: "missing digit", password: "WeakPass", want: false},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := isStrongPassword(tc.password); got != tc.want {
				t.Fatalf("isStrongPassword(%q) = %v, want %v", tc.password, got, tc.want)
			}
		})
	}
}

func TestGenerateRandomStringLength(t *testing.T) {
	t.Parallel()

	got := generateRandomString(16)
	if len(got) != 16 {
		t.Fatalf("expected length 16, got %d", len(got))
	}
}

func TestGenerateAndValidateJWT(t *testing.T) {
	t.Parallel()

	svc := &UserService{
		jwtSecret:      "unit-test-secret",
		jwtExpireHours: 2,
	}
	user := &model.User{
		UserID: "user_12345678",
		Email:  "user@example.com",
	}

	token, err := svc.generateJWT(user)
	if err != nil {
		t.Fatalf("generateJWT returned error: %v", err)
	}
	if token == "" {
		t.Fatal("generateJWT returned empty token")
	}

	claims, err := svc.ValidateJWT(token)
	if err != nil {
		t.Fatalf("ValidateJWT returned error: %v", err)
	}
	if claims.UserID != user.UserID || claims.Email != user.Email {
		t.Fatalf("unexpected claims: %+v", claims)
	}
	if claims.Issuer != "iot-platform-core" {
		t.Fatalf("unexpected issuer %q", claims.Issuer)
	}
}

func TestValidateJWTRejectsWrongSecret(t *testing.T) {
	t.Parallel()

	issuer := &UserService{
		jwtSecret:      "issuer-secret",
		jwtExpireHours: 2,
	}
	validator := &UserService{
		jwtSecret: "validator-secret",
	}

	token, err := issuer.generateJWT(&model.User{
		UserID: "user_87654321",
		Email:  "user@example.com",
	})
	if err != nil {
		t.Fatalf("generateJWT returned error: %v", err)
	}

	if _, err := validator.ValidateJWT(token); err == nil {
		t.Fatal("expected ValidateJWT to fail with wrong secret")
	}
}

func TestGenerateRandomStringLooksHexLike(t *testing.T) {
	t.Parallel()

	got := generateRandomString(24)
	if len(got) != 24 {
		t.Fatalf("expected length 24, got %d", len(got))
	}
	if strings.ToLower(got) != got {
		t.Fatalf("expected lowercase hex string, got %q", got)
	}
}
