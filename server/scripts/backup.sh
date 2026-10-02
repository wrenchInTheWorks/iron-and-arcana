#!/usr/bin/env bash
# Snapshot the world to a dated tar.gz. Stops the server first so the save is
# not torn, then restarts it if it was running.
#   ./backup.sh [destination-dir]      default: ~/ia-backups
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
DEST="${1:-$HOME/ia-backups}"
mkdir -p "$DEST"
STAMP="$(date +%Y-%m-%d_%H%M)"
WAS_RUNNING=false
if is_running; then
  WAS_RUNNING=true
  c_grn "stopping server for a consistent snapshot"
  docker compose exec -T "$SERVICE" rcon-cli save-all >/dev/null 2>&1 || true
  docker compose stop
fi
c_grn "archiving world -> $DEST/world-$STAMP.tar.gz"
docker run --rm -v "$VOLUME":/data -v "$DEST":/backup alpine \
  tar czf "/backup/world-$STAMP.tar.gz" -C /data world
docker run --rm -v "$DEST":/backup alpine sh -c "chown $(id -u):$(id -g) /backup/world-$STAMP.tar.gz" 2>/dev/null || true
ls -lh "$DEST/world-$STAMP.tar.gz" | awk '{print "  " $5, $9}'
# keep the 10 most recent
ls -1t "$DEST"/world-*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -- && c_grn "pruned to 10 most recent"
$WAS_RUNNING && { c_grn "restarting server"; docker compose up -d; }
c_grn "backup complete"
