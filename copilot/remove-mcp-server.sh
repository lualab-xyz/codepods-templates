#!/usr/bin/env bash
set -euo pipefail

remove_mcp_server() {
  local name="$1"

  echo "Removing MCP server ${name}"

  if ! copilot mcp remove "$name"; then
    echo "ERROR: failed to remove MCP server ${name}" >&2
    return 1
  fi

  echo "OK: MCP server ${name} removed"
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
