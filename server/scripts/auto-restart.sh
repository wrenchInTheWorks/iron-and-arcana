#!/usr/bin/env bash
# Scheduled restart with player warnings. Intended to be run from cron.
#
# No mod is needed for this. The container runs with `restart: unless-stopped`,
# so a clean server stop exits Java with code 0 and Docker immediately starts it
# again -- verified 2026-10-11, back up in under 5 seconds. That means "restart"
# here is just a graceful stop; Docker is the relaunch mechanism.
#
# If nobody is online it stops straight away. If players are online it warns
# them first, on the schedule in WARN_MINUTES, then saves and stops.
#
#   ./auto-restart.sh            # warn, then restart
#   ./auto-restart.sh --now      # skip warnings entirely
#   WARN_MINUTES="30 10 5 1" ./auto-restart.sh
#
# Cron example (05:30 daily, logging to the journal):
#   30 5 * * * /home/<user>/iron-and-arcana/server/scripts/auto-restart.sh >> /home/<user>/ia-restart.log 2>&1
#
# Note the warnings mean the script runs for WARN_MINUTES minutes before the
# restart actually happens, so schedule it that far ahead of when you want the
# server back.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

WARN_MINUTES="${WARN_MINUTES:-15 10 5 1}"
SKIP_WARN=false
[ "${1:-}" = "--now" ] && SKIP_WARN=true

require_docker
require_env

is_running || { c_ylw "server is not running - nothing to restart"; exit 0; }

rcon() { docker compose exec -T "$SERVICE" rcon-cli "$@" 2>/dev/null | tr -d '\r'; }

# "There are 2 of a max of 20 players online: a, b" -> 2
player_count() {
  local out n
  out="$(rcon list || true)"
  n="$(printf '%s' "$out" | sed -n 's/.*There are \([0-9]\+\) of a max.*/\1/p' | head -1)"
  # An unparseable reply must not be read as "empty server" -- warn instead of
  # silently skipping the countdown with people online.
  [ -n "$n" ] || { c_ylw "could not parse player count; assuming players are online" >&2; echo 99; return; }
  echo "$n"
}

count="$(player_count)"
c_grn "players online: $count"

if [ "$count" -gt 0 ] && [ "$SKIP_WARN" = false ]; then
  prev=0
  # WARN_MINUTES is descending; sleep the gap between each warning.
  for m in $WARN_MINUTES; do
    if [ "$prev" -ne 0 ]; then
      gap=$(( (prev - m) * 60 ))
      [ "$gap" -gt 0 ] && sleep "$gap"
    fi
    if [ "$m" -eq 1 ]; then
      rcon "say Server restarting in 1 minute." >/dev/null || true
    else
      rcon "say Server restarting in $m minutes." >/dev/null || true
    fi
    c_grn "warned: ${m}m"
    prev="$m"
  done
  [ "$prev" -gt 0 ] && sleep $(( prev * 60 ))
  rcon "say Restarting now - back in about a minute." >/dev/null || true
  sleep 3
fi

c_grn "saving"
rcon save-all >/dev/null || true
sleep 3

c_grn "stopping (Docker will bring it back)"
rcon stop >/dev/null || true

# Wait for Docker's restart policy to produce a new container start.
before_start="$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || true)"
for _ in $(seq 1 60); do
  now_start="$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || true)"
  status="$(docker inspect -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null || true)"
  if [ -n "$now_start" ] && [ "$now_start" != "$before_start" ] && [ "$status" = "running" ]; then
    c_grn "container restarted at $now_start"
    exit 0
  fi
  sleep 5
done

c_red "container did not come back within 5 minutes - check 'docker compose ps' and logs"
exit 1
