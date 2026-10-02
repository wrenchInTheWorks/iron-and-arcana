#!/usr/bin/env bash
# Restart the server. A restart re-runs packwiz-installer, so this is also how
# pack updates are applied. Waits for GitHub's CDN first — see _common.sh.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker; require_env
[ "${1:-}" = "--now" ] || wait_for_cdn
if is_running; then
  docker compose exec -T "$SERVICE" rcon-cli save-all >/dev/null 2>&1 || true
fi
docker compose restart
c_grn "restarting — follow with ./logs.sh"
