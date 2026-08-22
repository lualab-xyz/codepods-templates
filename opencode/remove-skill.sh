#!/usr/bin/env bash
set -euo pipefail

# Global skill discovery directory for OpenCode (~/.config/opencode/skills).
SKILL_DIR="${HOME}/.config/opencode/skills"

remove_skill() {
  local name="$1"

  # Guard against path traversal
  if [[ "$name" == */* || "$name" == ".." || -z "$name" ]]; then
    echo "ERROR: invalid skill name '${name}'" >&2
    return 1
  fi

  local target="${SKILL_DIR}/${name}"

  if [ ! -e "$target" ]; then
    echo "ERROR: skill '${name}' not found at ${target}" >&2
    return 1
  fi

  rm -rf "$target"

  echo "OK: skill '${name}' removed from ${SKILL_DIR}"
}

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing skill name" >&2
  echo "Usage: $0 <name>" >&2
  exit 1
fi

if ! remove_skill "$1"; then
  echo "ERROR: failed to remove skill" >&2
  exit 1
fi
