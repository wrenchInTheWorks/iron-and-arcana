#!/usr/bin/env bash
# Start the server.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker; require_env
if is_running; then c_ylw "already running"; exit 0; fi
docker compose up -d
c_grn "started — follow with ./logs.sh"
