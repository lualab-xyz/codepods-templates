#!/usr/bin/env bash
set -euo pipefail
# Seed per-user base config on first start (does not overwrite existing files).
/usr/local/bin/seed-config.sh
# Keep the container alive; services are started via the start_agent command.
exec tail -f /dev/null
