#!/usr/bin/env bash
set -euo pipefail

get_mcps() {
  local config="${HOME}/.opencode/opencode.jsonc"

  if [ ! -f "$config" ]; then
    echo "[]"
    return 0
  fi

  node - "$config" <<'JS'
const fs = require('fs');
const [configPath] = process.argv.slice(2);
const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
console.log(JSON.stringify(Object.keys(cfg.mcp || {})));
JS
}

if ! get_mcps; then
  echo "ERROR: failed to list MCP servers" >&2
  exit 1
fi
