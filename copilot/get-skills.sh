#!/usr/bin/env bash
set -euo pipefail

get_skills() {
  exec copilot skill list
}

if ! get_skills; then
  echo "ERROR: failed to list skills" >&2
  exit 1
fi
