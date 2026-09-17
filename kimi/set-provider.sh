#!/usr/bin/env bash
set -euo pipefail

set_provider() {
  BASE_URL="$1"
  MODEL_NAME="$2"
  API_KEY="$3"
  PROVIDER_NAME="$4"
  PROVIDER_TYPE="${5:-openai}"

  # Kimi Code CLI provider types (docs/en/configuration/providers.md).
  # Legacy kimi-cli names map as: openai_legacy -> openai, gemini -> google-genai.
  case "$PROVIDER_TYPE" in
    openai) TYPE="openai_responses" ;;
    openai_legacy) TYPE="openai" ;;
    anthropic|claude) TYPE="anthropic" ;;
    google|gemini) TYPE="google-genai" ;;
    kimi) TYPE="kimi" ;;
    vertex) TYPE="vertexai" ;;
    *) TYPE="openai_responses" ;;
  esac

  # Escape backslash and double-quote for TOML basic strings.
  esc() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf '%s' "$s"
  }

  KIMI_DIR="${KIMI_CODE_HOME:-${HOME}/.kimi-code}"
  mkdir -p "$KIMI_DIR"

  PROVIDER_NAME_ESC="$(esc "$PROVIDER_NAME")"
  MODEL_KEY_ESC="$(esc "${PROVIDER_NAME}/${MODEL_NAME}")"

  cat > "${KIMI_DIR}/config.toml" <<TOML
default_model = "${MODEL_KEY_ESC}"

[providers."${PROVIDER_NAME_ESC}"]
type = "${TYPE}"
base_url = "$(esc "$BASE_URL")"
api_key = "$(esc "$API_KEY")"

[models."${MODEL_KEY_ESC}"]
provider = "${PROVIDER_NAME_ESC}"
model = "$(esc "$MODEL_NAME")"
max_context_size = 200000
TOML

  echo "OK: Kimi provider set to ${PROVIDER_NAME}/${MODEL_NAME} (${TYPE}) via ${BASE_URL}"
}

if ! set_provider "$@"; then
  echo "ERROR: failed to set Kimi provider" >&2
  exit 1
fi
