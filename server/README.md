# Iron & Arcana — Self-Hosted Server

Docker deployment for the 2.0 pack. Minecraft 1.20.1, Forge 47.4.10, Java 17.

This replaces the v1 setup entirely: no Modrinth-hosted panel, no SFTP, and no
`server_sync.py` push step. The server installs the pack itself from this repo.

## First run

```bash
cp .env.example .env
```

Edit `.env` — at minimum set `WHITELIST`, `OPS` and `RCON_PASSWORD`. Then:

```bash
docker compose up -d && docker compose logs -f
```

The first boot downloads Forge and every mod, generates the world, and takes a
while. Watch for packwiz-installer resolving all 104 mods, then Forge starting.

## How updating works

`PACKWIZ_URL` points at `pack.toml` in this repo, and packwiz-installer runs on
every container start. So:

```bash
docker compose restart
```

is the update. There is no separate push step, and the server can never drift
from what the repo says — which is the failure mode the old SFTP sync had.

Change the branch in `PACKWIZ_URL` to control what the server tracks. It points
at `2.0` during the rebuild; switch it to `main` once 2.0 is merged.

## Console and admin

```bash
docker compose exec minecraft rcon-cli          # interactive console
docker compose exec minecraft rcon-cli list     # one-off command
docker compose logs -f --tail=200               # follow logs
```

RCON is enabled but its port is **not** published — it is reachable only from
inside the container, so `RCON_PASSWORD` never crosses the network.

## Mods packwiz cannot fetch

If a mod's CurseForge distribution is disabled, packwiz-installer cannot
download it and the boot will fail naming that file. Drop the jar into
`mods-override/` and restart — the image copies it into place. This replaces
what `pack-import-cache/` does for CI.

Nothing currently needs this. Create Aeronautics did in v1, and is not in 2.0.

## Backups

The world lives in the named volume `iron-and-arcana_data`, not in this
directory. To snapshot it:

```bash
docker compose stop
docker run --rm -v iron-and-arcana_data:/data -v "$PWD:/backup" alpine \
  tar czf /backup/world-$(date +%F).tar.gz -C /data world
docker compose start
```

Stop the server first — copying a live world can capture a torn save.

## Memory and performance

`USE_AIKAR_FLAGS` applies the same G1GC tuning that the v1 investigation landed
on (see `../SERVER_PERFORMANCE_NOTES.md`). Two things changed for the better by
self-hosting:

- **`-Xmx` is ours now.** The Modrinth panel used to append `-Xmx6000M` last,
  overriding anything set locally. `MAX_MEMORY` is authoritative here.
- `INIT_MEMORY=2G` pre-allocates heap to soften the cold-start GC thrash that
  caused the entity jitter reported in v1.

Expect some jitter in the first few minutes after a restart regardless — that is
JVM warmup and it resolves on its own. The notes have the full diagnosis and a
Spark reading guide.

`VIEW_DISTANCE=8` / `SIMULATION_DISTANCE=4` carry over as the largest single TPS
win found in v1.

## Ports

| Port | Purpose |
|---|---|
| 25565 | Minecraft |
| 8100 | BlueMap web UI |

Forward these on the router/firewall as needed. BlueMap on 8100 is unauthenticated,
so put it behind a reverse proxy before exposing it to the internet.

## If the repo ever goes private

`raw.githubusercontent.com` needs the repo to be public for `PACKWIZ_URL` to
work unauthenticated. If that changes, the options are a token-authenticated
URL, GitHub Pages, or having CI bake the pack into a GHCR server image and
deploying that instead.

## Config files

Mod configs are **not** tracked in this repo yet. Let the first boot generate
them for 1.20.1, then tune and commit the ones that matter — copying the v1
configs over would be wrong, because config schemas change between mod versions.
