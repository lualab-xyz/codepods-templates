#!/usr/bin/env bash
set -euo pipefail

# Personal skill discovery directory for OpenAI Codex CLI ($HOME/.agents/skills).
SKILL_DIR="${HOME}/.agents/skills"

get_skills() {
  if [ ! -d "$SKILL_DIR" ]; then
    echo "[]"
    return 0
  fi

  find "$SKILL_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort \
    | node -e '
        let d = "";
        process.stdin.on("data", c => d += c).on("end", () => {
          console.log(JSON.stringify(d.split("\n").filter(Boolean)));
        });'
}

if ! get_skills; then
  echo "ERROR: failed to list skills" >&2
  exit 1
fi
