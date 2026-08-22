#!/usr/bin/env bash
set -euo pipefail

# Personal skill discovery directory for GitHub Copilot CLI (~/.agents/skills).
SKILL_DIR="${HOME}/.agents/skills"

TMP_DIR=""

cleanup() {
  if [ -n "${TMP_DIR}" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

add_skill() {
  local source="$1"
  local name

  # Derive the skill folder name from the zip filename (e.g. skill1.zip -> skill1)
  name="$(basename "$source")"
  name="${name%.zip}"

  echo "Adding skill ${name} from ${source}"

  TMP_DIR="$(mktemp -d)"

  # Download when the source is a URL, otherwise use it as a local path
  local zip="$source"
  if [[ "$source" =~ ^https?:// ]]; then
    zip="${TMP_DIR}/$(basename "$source")"
    if ! curl -fsSL "$source" -o "$zip"; then
      echo "ERROR: failed to download ${source}" >&2
      return 1
    fi
  fi

  mkdir -p "${SKILL_DIR}/${name}"

  if ! unzip -o "$zip" -d "${SKILL_DIR}/${name}"; then
    echo "ERROR: failed to extract ${zip}" >&2
    return 1
  fi

  echo "OK: skill ${name} installed to ${SKILL_DIR}/${name}"
}

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing skill zip (URL or local path)" >&2
  echo "Usage: $0 <url-or-path-to-zip>" >&2
  exit 1
fi

if ! add_skill "$1"; then
  echo "ERROR: failed to add skill" >&2
  exit 1
fi
