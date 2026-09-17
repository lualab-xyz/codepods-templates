#!/usr/bin/env bash
set -euo pipefail

# Kimi Code CLI has no "kimi mcp add" subcommand: MCP servers live in
# $KIMI_CODE_HOME/mcp.json (default ~/.kimi-code/mcp.json), user level.
add_mcp_server() {
  local name="$1"
  local url="$2"
  local transport="${3:-http}"
  local auth_header="${4:-}"

  echo "Adding MCP server ${name} (${transport}) -> ${url}"

  local kimi_dir="${KIMI_CODE_HOME:-${HOME}/.kimi-code}"
  mkdir -p "$kimi_dir"

  node -e '
    const fs = require("fs");
    const path = process.argv[1];
    const name = process.argv[2];
    const url = process.argv[3];
    const transport = process.argv[4];
    const authHeader = process.argv[5];
    let cfg = {};
    try { cfg = JSON.parse(fs.readFileSync(path, "utf8")); } catch {}
    cfg.mcpServers = cfg.mcpServers || {};
    const entry = { url };
    // HTTP is the default transport; only SSE needs an explicit value.
    if (transport === "sse") entry.transport = "sse";
    if (authHeader) {
      const idx = authHeader.indexOf(":");
      const headerName = idx > 0 ? authHeader.slice(0, idx).trim() : "Authorization";
      const headerValue = idx > 0 ? authHeader.slice(idx + 1).trim() : authHeader.trim();
      entry.headers = { [headerName]: headerValue };
    }
    cfg.mcpServers[name] = entry;
    fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + "\n");
  ' "${kimi_dir}/mcp.json" "$name" "$url" "$transport" "$auth_header"

  echo "OK: MCP server ${name} added"
}

if [ "$#" -lt 2 ]; then
  echo "ERROR: missing arguments" >&2
  echo "Usage: $0 \$name \$url [\$transport] [\$authHeader]" >&2
  exit 1
fi

if ! add_mcp_server "$@"; then
  echo "ERROR: failed to add MCP server ${1}" >&2
  exit 1
fi
