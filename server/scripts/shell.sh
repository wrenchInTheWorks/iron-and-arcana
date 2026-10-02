#!/usr/bin/env bash
# Shell inside the container, AS UID 1000 — never as root.
# Editing files as root leaves root-owned configs, and the mod that owns them
# then crashes with AccessDeniedException on its next write. This has happened.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
is_running || die "server is not running (start it, or use files.sh for an offline look)"
c_ylw "you are uid 1000 — note config/ is overwritten from the repo on restart"
docker compose exec --user 1000:1000 "$SERVICE" bash 2>/dev/null \
  || docker compose exec --user 1000:1000 "$SERVICE" sh
