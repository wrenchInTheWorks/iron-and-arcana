#!/usr/bin/env bash
# First-run setup: checks prerequisites, creates .env, starts the server.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

c_grn "=== Iron & Arcana server setup ==="
require_docker
docker compose version >/dev/null 2>&1 || die "the Docker Compose v2 plugin is missing (apt install docker-compose-plugin)"

if [ -f .env ]; then
  c_ylw ".env already exists — leaving it alone."
else
  cp .env.example .env
  c_grn "created .env from .env.example"
  read -rp "Minecraft usernames to whitelist (comma separated): " wl
  read -rp "Usernames to make operators (comma separated): " ops
  rcon="$(head -c 24 /dev/urandom | base64 | tr -d '/+=' | head -c 24)"
  sed -i "s|^WHITELIST=.*|WHITELIST=${wl}|;s|^OPS=.*|OPS=${ops}|;s|^RCON_PASSWORD=.*|RCON_PASSWORD=${rcon}|" .env
  c_grn "whitelist, ops and a random RCON password written to .env"
fi

grep -qE '^PACKWIZ_URL=.+' .env || die "PACKWIZ_URL is empty in .env"

c_grn "starting the server (first boot downloads Forge and ~100 mods; be patient)"
docker compose up -d
c_grn "done — follow progress with: ./logs.sh"
