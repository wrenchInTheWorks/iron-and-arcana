#!/usr/bin/env bash
# Shared helpers. Sourced by the other scripts; not meant to be run directly.
set -euo pipefail

# Resolve the compose directory from this script's location, so the scripts work
# from anywhere (desktop shortcut, cron, wherever).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$COMPOSE_DIR/.." && pwd)"
SERVICE="minecraft"
CONTAINER="iron-and-arcana"
VOLUME="iron-and-arcana_data"

cd "$COMPOSE_DIR"

c_red()  { printf '\033[31m%s\033[0m\n' "$*"; }
c_grn()  { printf '\033[32m%s\033[0m\n' "$*"; }
c_ylw()  { printf '\033[33m%s\033[0m\n' "$*"; }
die()    { c_red "error: $*" >&2; exit 1; }

require_docker() {
  command -v docker >/dev/null 2>&1 || die "docker is not installed"
  docker info >/dev/null 2>&1 || die "cannot reach the Docker daemon (is it running? are you in the 'docker' group?)"
}

require_env() {
  [ -f "$COMPOSE_DIR/.env" ] || die ".env not found — run setup.sh first"
}

is_running() {
  [ -n "$(docker compose ps -q "$SERVICE" 2>/dev/null)" ] &&
  [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = "true" ]
}

# Wait until raw.githubusercontent serves the current commit's index.
# raw.githubusercontent sends Cache-Control: max-age=300, so restarting straight
# after a push makes packwiz-installer silently install the PREVIOUS files.
wait_for_cdn() {
  local url expected i
  url="$(grep -E '^PACKWIZ_URL=' "$COMPOSE_DIR/.env" | cut -d= -f2-)"
  [ -n "$url" ] || { c_ylw "PACKWIZ_URL not set; skipping CDN check"; return 0; }
  command -v git >/dev/null 2>&1 || { c_ylw "git not available; skipping CDN check"; return 0; }
  expected="$(cd "$REPO_DIR" && git rev-parse HEAD 2>/dev/null || true)"
  [ -n "$expected" ] || { c_ylw "not a git checkout; skipping CDN check"; return 0; }

  local index_url="${url%/pack.toml}/index.toml"
  local local_hash remote_hash
  local_hash="$(sha256sum "$REPO_DIR/index.toml" 2>/dev/null | cut -d' ' -f1 || true)"
  [ -n "$local_hash" ] || { c_ylw "no local index.toml; skipping CDN check"; return 0; }

  printf 'checking GitHub has the current pack'
  for i in $(seq 1 20); do
    remote_hash="$(curl -fsSL "$index_url" 2>/dev/null | sha256sum | cut -d' ' -f1 || true)"
    if [ "$remote_hash" = "$local_hash" ]; then printf '\n'; c_grn "CDN is serving the current index"; return 0; fi
    printf '.'; sleep 15
  done
  printf '\n'
  c_ylw "CDN still stale after ~5min — the server may install the previous pack version."
  c_ylw "Continuing anyway; verify afterwards with status.sh."
}
