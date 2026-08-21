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

# Seed base configs at container start if none exist. Never overwrites an
# existing config (the user/orchestrator may have customized it on purpose).
# The provider-specific fields are managed by set_provider.
CONFIG="${HOME}/.opencode/opencode.jsonc"
mkdir -p "$(dirname "$CONFIG")"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "server": {
    "port": 4096,
    "hostname": "0.0.0.0"
  }
}
EOF
fi

TUI="${HOME}/.opencode/tui.json"
if [ ! -f "$TUI" ]; then
  cat > "$TUI" <<'EOF'
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "opencode"
}
EOF
fi
