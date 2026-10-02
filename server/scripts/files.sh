#!/usr/bin/env bash
# Get at the server's files. Works whether or not the container is running.
#   ./files.sh path            print where the volume lives on this host
#   ./files.sh ls [subdir]     list a directory inside /data
#   ./files.sh cat <file>      print a file from /data
#   ./files.sh pull <file>     copy a file out of /data into ./pulled/
#   ./files.sh open            open the volume in a file manager (desktop only)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker
MP="$(docker volume inspect "$VOLUME" -f '{{ .Mountpoint }}' 2>/dev/null || true)"

case "${1:-path}" in
  path) echo "$MP"
        c_ylw "note: owned by root on the host — use 'ls'/'cat'/'pull' below, or sudo" ;;
  ls)   docker run --rm -v "$VOLUME":/data alpine ls -la "/data/${2:-}" ;;
  cat)  [ -n "${2:-}" ] || die "usage: files.sh cat <path under /data>"
        docker run --rm -v "$VOLUME":/data alpine cat "/data/$2" ;;
  pull) [ -n "${2:-}" ] || die "usage: files.sh pull <path under /data>"
        mkdir -p "$COMPOSE_DIR/pulled"
        docker run --rm -v "$VOLUME":/data -v "$COMPOSE_DIR/pulled":/out alpine \
          sh -c "cp -r /data/$2 /out/ && chown -R $(id -u):$(id -g) /out" 2>/dev/null \
          || docker run --rm -v "$VOLUME":/data -v "$COMPOSE_DIR/pulled":/out alpine cp -r "/data/$2" /out/
        c_grn "copied to $COMPOSE_DIR/pulled/" ;;
  open) command -v xdg-open >/dev/null && xdg-open "$MP" || die "no xdg-open; path is: $MP" ;;
  *)    sed -n '2,9p' "$0" ;;
esac
