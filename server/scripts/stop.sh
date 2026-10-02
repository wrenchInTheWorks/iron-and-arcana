#!/usr/bin/env bash
# Stop the server cleanly. Saves the world; does NOT delete anything.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
if ! is_running; then c_ylw "not running"; exit 0; fi
c_grn "saving world before shutdown"
docker compose exec -T "$SERVICE" rcon-cli save-all >/dev/null 2>&1 || c_ylw "(rcon save failed; stopping anyway)"
docker compose stop
c_grn "stopped. The world is safe in volume '$VOLUME'."
