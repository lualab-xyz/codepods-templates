#!/usr/bin/env bash
set -euo pipefail

get_mcps() {
  local json
  json="$(copilot mcp list --json)" || return 1
  printf '%s' "$json" | node -e '
    let d = "";
    process.stdin.on("data", c => d += c).on("end", () => {
      const j = JSON.parse(d);
      console.log(JSON.stringify(Object.keys(j.mcpServers || {})));
    });'
}

if ! get_mcps; then
  echo "ERROR: failed to list MCP servers" >&2
  exit 1
fi
