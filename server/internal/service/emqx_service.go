package service

// EMQXService is a minimal placeholder used by the current server entrypoint.
// It keeps the project buildable while the full EMQX integration layer is being
// consolidated.
type EMQXService struct {
	apiURL   string
	username string
	password string
}

func NewEMQXService(apiURL, username, password string) *EMQXService {
	return &EMQXService{
		apiURL:   apiURL,
		username: username,
		password: password,
	}
}

func (s *EMQXService) TestConnection() error {
	return nil
}
