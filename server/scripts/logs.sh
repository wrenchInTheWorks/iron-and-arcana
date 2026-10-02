#!/usr/bin/env bash
# Follow the server log. Ctrl+C stops watching; it does NOT stop the server.
#   ./logs.sh            follow, last 100 lines
#   ./logs.sh 500        follow, last 500 lines
#   ./logs.sh errors     show only warnings and errors
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
case "${1:-}" in
  errors) docker compose logs --tail=2000 | grep -Ei 'ERROR|FATAL|Exception|Caused by|failed' | tail -60 ;;
  ''|*[!0-9]*) docker compose logs -f --tail=100 ;;
  *) docker compose logs -f --tail="$1" ;;
esac
