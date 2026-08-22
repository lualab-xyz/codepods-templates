#!/usr/bin/env bash
set -euo pipefail

# Personal skill discovery directory for OpenAI Codex CLI ($HOME/.agents/skills).
SKILL_DIR="${HOME}/.agents/skills"

TMP_DIR=""

cleanup() {
  if [ -n "${TMP_DIR}" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

# Slugify a name into a safe, lowercase, hyphenated folder name.
slugify() {
  local s
  s="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')"
  s="$(printf '%s' "$s" | tr -s '-')"
  s="${s%%-}"
  s="${s%-}"
  printf '%s' "$s"
}

add_skill() {
  local name="$1"
  local source="$2"
  local slug
  local zip

  slug="$(slugify "$name")"
  if [ -z "$slug" ]; then
    echo "ERROR: could not derive a valid folder name from '${name}'" >&2
    return 1
  fi

  echo "Adding skill ${name} (folder ${slug}) from ${source}"

  TMP_DIR="$(mktemp -d)"

  # Download when the source is a URL, otherwise use it as a local path
  zip="$source"
  if [[ "$source" =~ ^https?:// ]]; then
    zip="${TMP_DIR}/$(basename "$source")"
    if ! curl -fsSL "$source" -o "$zip"; then
      echo "ERROR: failed to download ${source}" >&2
      return 1
    fi
  fi

  mkdir -p "${SKILL_DIR}/${slug}"

  if ! unzip -o "$zip" -d "${SKILL_DIR}/${slug}"; then
    echo "ERROR: failed to extract ${zip}" >&2
    return 1
  fi

  echo "OK: skill '${name}' installed to ${SKILL_DIR}/${slug}"
}

if [ "$#" -lt 2 ]; then
  echo "ERROR: missing arguments" >&2
  echo "Usage: $0 <name> <url-or-path-to-zip>" >&2
  exit 1
fi

if ! add_skill "$1" "$2"; then
  echo "ERROR: failed to add skill" >&2
  exit 1
fi
