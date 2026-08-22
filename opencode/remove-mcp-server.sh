#!/usr/bin/env bash
set -euo pipefail

remove_mcp_server() {
  local name="$1"

  echo "Removing MCP server ${name}"

  local config="${HOME}/.opencode/opencode.jsonc"

  node - "$name" "$config" <<'JS'
const fs = require('fs');
const [name, configPath] = process.argv.slice(2);

const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));

if (cfg.mcp && cfg.mcp[name]) {
  delete cfg.mcp[name];
  fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2) + '\n');
}
JS

  echo "OK: MCP server ${name} removed from ${config}"
}

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing argument" >&2
  echo "Usage: $0 \$name" >&2
  exit 1
fi

if ! remove_mcp_server "$1"; then
  echo "ERROR: failed to remove MCP server" >&2
  exit 1
fi
