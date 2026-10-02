#!/usr/bin/env bash
# At-a-glance health: container, players, resources, pack freshness.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker

c_grn "=== container ==="
docker compose ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true

if is_running; then
  echo
  c_grn "=== players ==="
  docker compose exec -T "$SERVICE" rcon-cli list 2>/dev/null || echo "  (rcon unavailable - still starting?)"

  echo
  c_grn "=== resources ==="
  docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}' "$CONTAINER" 2>/dev/null || true

  echo
  c_grn "=== pack freshness (is the server running what the repo says?) ==="
  if command -v git >/dev/null 2>&1 && [ -d "$REPO_DIR/.git" ]; then
    echo "  repo HEAD    : $(cd "$REPO_DIR" && git log --oneline -1)"
    echo "  local mods   : $(ls "$REPO_DIR"/mods/*.pw.toml 2>/dev/null | wc -l)"
  fi
  echo "  server mods  : $(docker compose exec -T "$SERVICE" sh -c 'ls /data/mods/*.jar 2>/dev/null | wc -l' 2>/dev/null | tr -d '\r')"
else
  echo; c_ylw "server is not running"
fi

echo
c_grn "=== world size ==="
docker run --rm -v "$VOLUME":/data alpine du -sh /data/world 2>/dev/null | sed 's/^/  /' || echo "  (volume unavailable)"
