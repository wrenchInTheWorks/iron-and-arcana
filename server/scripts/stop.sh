#!/usr/bin/env bash
# Stop the server cleanly. Saves the world; does NOT delete anything.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
if ! is_running; then c_ylw "not running"; exit 0; fi
c_grn "saving world before shutdown"
# `flush` waits until every chunk is actually on disk, so the save Minecraft
# does while stopping has almost nothing left to write.
docker compose exec -T "$SERVICE" rcon-cli save-all flush >/dev/null 2>&1 || c_ylw "(rcon save failed; stopping anyway)"
docker compose stop

# 137 = Docker gave up waiting and SIGKILLed it. Minecraft saves players before
# chunks, so a kill mid-shutdown keeps inventories and loses placed blocks.
code="$(docker inspect -f '{{.State.ExitCode}}' "$CONTAINER" 2>/dev/null || echo '?')"
if [ "$code" = "137" ]; then
  c_red "the server was KILLED before it finished saving (exit 137)."
  c_red "blocks placed since the last autosave may be lost. Raise stop_grace_period in docker-compose.yml."
  exit 1
fi
c_grn "stopped (exit $code). The world is safe in volume '$VOLUME'."
