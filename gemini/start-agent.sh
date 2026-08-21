#!/usr/bin/env bash
set -euo pipefail

# Runtime configuration is injected by the orchestrator through environment
# variables (e.g. `docker exec --user agent -e TERMINAL_PORT=7681 ...`).
# BYOK settings persisted by set_provider live in the agent's home (a writable
# location) and are sourced here, so nothing writes to read-only paths like
# /opt or /usr/local.
ENV_FILE="${HOME}/.config/codepods.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1091
  set -a
  . "$ENV_FILE"
  set +a
fi

# Prefer a user-local git proxy (installed by set_git_proxy) over system git.
export PATH="${HOME}/.local/bin:${PATH}"

PID_FILE="/tmp/start-agent.pid"
TERMINAL_PORT="${TERMINAL_PORT:-${CODEPODS_TERMINAL_PORT:-7681}}"
if [ -z "$TERMINAL_PORT" ]; then
  echo "ERROR: Terminal port not configured. Please set CODEPODS_TERMINAL_PORT." >&2
  exit 1
fi

FONT_OPTION="fontSize=${TERM_FONT_SIZE:-14}"

# Push runtime configuration into the tmux environment so the CLI running
# inside the session inherits it without writing any file.
set_tmux_env() {
  tmux start-server 2>/dev/null || true
  local var val
  for var in "$@"; do
    val="${!var-}"
    if [ -n "$val" ]; then
      tmux setenv -g "$var" "$val" 2>/dev/null || true
    fi
  done
}
set_tmux_env TERMINAL_PORT TERM_FONT_SIZE TERM LANG 

# Mark this invocation as the current owner
echo "$$" > "$PID_FILE"

TMUX_CMD=(tmux new-session -A -s main "cd /workspace && exec gemini -r latest")

pids=()
stop=false

cleanup() {
  for pid in "${pids[@]:-}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
  pids=()
}

start_ttyd() {
  echo "Starting ttyd on port $TERMINAL_PORT, attaching tmux session 'main'"
  /usr/local/bin/ttyd \
    --port "$TERMINAL_PORT" \
    --writable \
    --client-option disableLeaveAlert=true \
    --client-option "$FONT_OPTION" \
    --index /opt/ttyd/index.html \
    "${TMUX_CMD[@]}" &
  pids+=("$!")
}

trap 'stop=true; cleanup' INT TERM

start_services() {
  cleanup
  start_ttyd

  if [ "${#pids[@]}" -eq 0 ]; then
    echo "ERROR: no services started" >&2
    return 1
  fi
  echo "OK: agent services started"
  wait -n "${pids[@]}"
}

cd /workspace

while true; do
  start_services || {
    echo "ERROR: service loop failed; retrying in 2s..." >&2
    sleep 2
    continue
  }
  if $stop; then
    break
  fi
  sleep 1
done

cleanup
rm -f "$PID_FILE"
