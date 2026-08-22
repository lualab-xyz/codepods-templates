#!/usr/bin/env bash
set -euo pipefail

get_mcps() {
  exec copilot mcp list
}

if ! get_mcps; then
  echo "ERROR: failed to list MCP servers" >&2
  exit 1
fi
