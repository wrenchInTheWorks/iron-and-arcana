#!/usr/bin/env bash
# General Docker health on this host — not specific to Minecraft.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
require_docker

c_grn "=== containers ==="
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
echo
c_grn "=== live resource usage (one sample) ==="
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}'
echo
c_grn "=== disk used by Docker ==="
docker system df
echo
c_grn "=== volume sizes ==="
for v in $(docker volume ls -q); do
  s="$(docker run --rm -v "$v":/v alpine du -sh /v 2>/dev/null | cut -f1)"
  printf '  %-40s %s\n' "$v" "${s:-?}"
done
echo
c_ylw "reclaim space with:  docker system prune     (add --volumes ONLY if you are certain)"
