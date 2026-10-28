#!/usr/bin/env bash
set -euo pipefail

set_git_proxy() {
  local download_url="$1"
  local bin_dir="${HOME}/.local/bin"
  local bin_path="${bin_dir}/git"

  echo "Installing git proxy from ${download_url}..."

  mkdir -p "$bin_dir"

  # Remove the real git entirely (do not just move/rename it: agents must
  # never find a working system git). Needs root; images ship without git,
  # so this is only a safety net for binaries appearing at runtime.
  for sys_git in /usr/bin/git /usr/local/bin/git; do
    if [ -e "$sys_git" ]; then
      if command -v sudo >/dev/null 2>&1 && sudo -n rm -f "$sys_git" 2>/dev/null; then
        echo "Removed real git at ${sys_git}"
      else
        echo "WARNING: real git found at ${sys_git} but could not be removed (no root privileges)" >&2
      fi
    fi
  done

  # Delete any previous binary in the user bin (real git or old proxy):
  # the proxy is downloaded fresh, and no copy of a real git may survive
  # (backups like git.original are removed too).
  rm -f "$bin_path" "${bin_dir}/git.original"

  # Download the fake-git proxy binary from the host
  if ! curl -fsSL "$download_url" -o "$bin_path"; then
    echo "ERROR: failed to download git proxy from ${download_url}" >&2
    return 1
  fi

  chmod +x "$bin_path"

  # Verify it is executable
  if ! "$bin_path" --version >/dev/null 2>&1; then
    echo "WARNING: git proxy does not respond to --version" >&2
  fi

  echo "OK: git proxy installed at ${bin_path}"
}

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing download URL" >&2
  echo "Usage: $0 \$downloadUrl" >&2
  exit 1
fi

if ! set_git_proxy "$1"; then
  echo "ERROR: failed to install git proxy" >&2
  exit 1
fi
