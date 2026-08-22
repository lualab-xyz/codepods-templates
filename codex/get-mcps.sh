#!/usr/bin/env bash
set -euo pipefail

get_mcps() {
  local config="${HOME}/.codex/config.toml"

  if [ ! -f "$config" ]; then
    echo "[]"
    return 0
  fi

  grep -oE '^\[mcp_servers\."[^"]+"' "$config" \
    | sed 's/^\[mcp_servers\."//; s/"$//' \
    | node -e '
        let d = "";
        process.stdin.on("data", c => d += c).on("end", () => {
          console.log(JSON.stringify(d.split("\n").filter(Boolean)));
        });'
}

if ! get_mcps; then
  echo "ERROR: failed to list MCP servers" >&2
  exit 1
fi
