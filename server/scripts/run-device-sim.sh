#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:48080}"
PRODUCT_KEY="${PRODUCT_KEY:-SW-SERVO-001}"
DEVICE_SN="${DEVICE_SN:-SIM-EMU-$(date +%s)}"
FIRMWARE_VERSION="${FIRMWARE_VERSION:-1.0.0}"
CHIP_MODEL="${CHIP_MODEL:-ESP32}"
BROKER_URL="${BROKER_URL:-tcp://127.0.0.1:48883}"
INITIAL_POSITION="${INITIAL_POSITION:-middle}"

activation_json="$(
  curl -sS -X POST "${API_BASE_URL}/api/v1/devices/activate" \
    -H 'Content-Type: application/json' \
    -d "{\"productKey\":\"${PRODUCT_KEY}\",\"deviceSN\":\"${DEVICE_SN}\",\"firmwareVersion\":\"${FIRMWARE_VERSION}\",\"chipModel\":\"${CHIP_MODEL}\"}"
)"

read_json_field() {
  local expr="$1"
  ACTIVATION_JSON="${activation_json}" ruby -rjson -e 'data = JSON.parse(ENV.fetch("ACTIVATION_JSON")); puts eval(ARGV[0])' "${expr}"
}

device_id="$(read_json_field 'data.fetch("data").fetch("deviceId")')"
username="$(read_json_field 'data.fetch("data").fetch("mqtt").fetch("username")')"
password="$(read_json_field 'data.fetch("data").fetch("mqtt").fetch("password")')"
client_id="$(read_json_field 'data.fetch("data").fetch("mqtt").fetch("clientId")')"

echo "Starting device simulator"
echo "  API:        ${API_BASE_URL}"
echo "  Product:    ${PRODUCT_KEY}"
echo "  Device SN:  ${DEVICE_SN}"
echo "  Device ID:  ${device_id}"
echo "  MQTT User:  ${username}"
echo "  Broker:     ${BROKER_URL}"

cd "${ROOT_DIR}"
DEVICE_SIM_PRODUCT_KEY="${PRODUCT_KEY}" \
DEVICE_SIM_DEVICE_ID="${device_id}" \
DEVICE_SIM_USERNAME="${username}" \
DEVICE_SIM_PASSWORD="${password}" \
DEVICE_SIM_CLIENT_ID="${client_id}" \
DEVICE_SIM_BROKER_URL="${BROKER_URL}" \
DEVICE_SIM_API_BASE_URL="${API_BASE_URL}" \
DEVICE_SIM_INITIAL_POSITION="${INITIAL_POSITION}" \
go run ./cmd/device-sim
