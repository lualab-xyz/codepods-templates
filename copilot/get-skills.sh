#!/usr/bin/env bash
set -euo pipefail

get_skills() {
  local json
  json="$(copilot skill list --json)" || return 1
  printf '%s' "$json" | node -e '
    let d = "";
    process.stdin.on("data", c => d += c).on("end", () => {
      const j = JSON.parse(d);
      console.log(JSON.stringify((j || []).map(s => s.name)));
    });'
}

if ! get_skills; then
  echo "ERROR: failed to list skills" >&2
  exit 1
fi
