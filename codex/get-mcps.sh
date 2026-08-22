#!/usr/bin/env bash
set -euo pipefail

get_mcps() {
  local config="${HOME}/.codex/config.toml"

  if [ ! -f "$config" ]; then
    return 0
  fi

  grep -oE '^\[mcp_servers\."[^"]+"' "$config" \
    | sed 's/^\[mcp_servers\."//; s/"$//'
}

if ! get_mcps; then
  echo "ERROR: failed to list MCP servers" >&2
  exit 1
fi
