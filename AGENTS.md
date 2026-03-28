# Repository Guidelines

## Project Structure & Module Organization
This repository is a small IoT monorepo. `server/` contains the Go backend (`cmd/server`, `internal/{config,handler,model,repository,service}`, `pkg/`, and Docker files). `mobile-app/` is the Flutter client, with app code in `lib/` and tests in `test/`. `iot-libs-common/flutter-sdk/` holds the shared Flutter SDK consumed by the app. `firmware/switch/` and `firmware/usb-wakeup/` are PlatformIO firmware projects with source in `src/` and device config headers in `include/`. `smartlink-hub/` contains SmartLink-related docs and release assets.

## Build, Test, and Development Commands
Use module-local commands from the relevant subdirectory:

- `cd server && make docker-up` starts MySQL, Redis, EMQX, and the API stack with Docker Compose.
- `cd server && make run` runs the backend locally; `make build` outputs `bin/iot-core`; `make test` runs `go test -v ./...`.
- `cd mobile-app && flutter pub get` installs app dependencies.
- `cd mobile-app && flutter run` launches the app; `flutter test` runs widget tests; `flutter analyze` applies the configured lints.
- `cd firmware/switch && pio run` or `cd firmware/usb-wakeup && pio run` builds firmware; add `-t upload` to flash a board.

## Coding Style & Naming Conventions
Follow each language’s native conventions. Format Go with `gofmt` and keep package names lowercase. In Flutter and the shared SDK, use `snake_case.dart` filenames, `PascalCase` widgets/classes, and `camelCase` members; the app inherits `flutter_lints` from `mobile-app/analysis_options.yaml`. Firmware uses Arduino-style C++ with `PascalCase` types and `UPPER_SNAKE_CASE` macros/constants in `include/*.h`.

## Testing Guidelines
Flutter tests belong in `mobile-app/test/` and should use the `*_test.dart` suffix; `widget_test.dart` is the current example. The backend currently has no committed `*_test.go` files, so new Go changes should add package-local tests where practical and still pass `cd server && make test`. Firmware changes should at minimum compile with `pio run`; hardware-facing changes should also be smoke-tested on device and, when useful, checked with `pio device monitor`.

## Commit & Pull Request Guidelines
Recent history uses a compact pattern such as `Lys 20251226 修复ArduinoJson版本号`: author tag, date stamp, short summary. Keep commits focused and descriptive in that style. PRs should explain affected modules, list the commands you ran, link the related issue, and include screenshots or serial logs when changing UI flows, BLE provisioning, or device behavior.

## Security & Configuration Tips
Never commit secrets or real environment files. Start server config from `server/.env.example` or `server/.env.simple`; keep `.env` local because `server/.gitignore` excludes it. Treat device credentials, MQTT endpoints, and API keys as sensitive test data.
