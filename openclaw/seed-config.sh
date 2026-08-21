#!/usr/bin/env bash
set -euo pipefail

# Seed base config files at container start if they don't exist. Never
# overwrites an existing config (the user/orchestrator may have customized
# it on purpose). Templates live under /opt (read-only, not covered by the
# $HOME mount that replaces build-time contents).
TMUX_TEMPLATE=/opt/tmux/.tmux.conf
if [ -f "$TMUX_TEMPLATE" ] && [ ! -f "$HOME/.tmux.conf" ]; then
  cp "$TMUX_TEMPLATE" "$HOME/.tmux.conf"
fi

# Seed a base config at container start if none exists. Never overwrites an
# existing config (the user/orchestrator may have customized it on purpose).
CONFIG="${HOME}/.openclaw/openclaw.json"
mkdir -p "$(dirname "$CONFIG")"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<'EOF'
{
  "models": {
    "mode": "replace",
    "providers": {}
  },
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "auto"
  }
}
EOF
fi
