#!/usr/bin/env bash
# Server console via RCON.
#   ./console.sh             interactive
#   ./console.sh list        run one command
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
is_running || die "server is not running"
if [ $# -eq 0 ]; then docker compose exec "$SERVICE" rcon-cli
else docker compose exec -T "$SERVICE" rcon-cli "$@"; fi
