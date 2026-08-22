#!/usr/bin/env bash
set -euo pipefail

remove_mcp_server() {
  local name="$1"

  echo "Removing MCP server ${name}"

  local config="${HOME}/.codex/config.toml"

  python3 - "$name" "$config" <<'PY'
import sys, os

name, config_path = sys.argv[1:3]

if not os.path.exists(config_path):
    print(f"OK: MCP server {name} not present (no config file)", file=sys.stderr)
    sys.exit(0)

with open(config_path, 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
section_prefix = f'[mcp_servers."{name}"'
for line in lines:
    stripped = line.strip()
    if stripped.startswith(section_prefix):
        skip = True
        continue
    if skip and stripped.startswith('[') and not stripped.startswith(section_prefix):
        skip = False
    if not skip:
        new_lines.append(line)

with open(config_path, 'w') as f:
    f.writelines(new_lines)
PY

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
