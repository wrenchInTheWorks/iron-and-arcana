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

### Wait before restarting after a push

`raw.githubusercontent.com` sends `Cache-Control: max-age=300`, so for up to
**5 minutes** after a push it may still serve the previous version. Restarting
inside that window makes packwiz-installer quietly install the **old** files —
the server comes up healthy and looks correct, which is what makes this nasty.

Either wait a few minutes, or verify what GitHub is actually serving first:

```powershell
(Invoke-WebRequest "https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/2.0/pack.toml" -UseBasicParsing).Content
```

To confirm a config really landed, compare sizes rather than trusting the boot:

```powershell
docker compose exec -T minecraft sh -c "wc -c < /data/config/sophisticatedcore-common.toml"
```

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
  tar czf /backup/world-$(date +%F).tar.gz --exclude=world/session.lock -C /data world
docker compose start
```

Stop the server first — copying a live world can capture a torn save.

`session.lock` is excluded on purpose. If it ends up in the archive, the
restored server dies with a file-lock `IOException` on first start, which is
indistinguishable from a stale lock after an unclean kill.

`scripts/backup.sh` does all of the above, keeps the last 10, and restarts the
server only if it was running.

## Moving the server to another host

The same archive is the migration path. **Only `world/` needs to move.** Of the
~890 MB in the volume the world is ~40 MB (~28 MB compressed): `mods/` (~594 MB)
is re-fetched by packwiz on first start, `bluemap/` (~83 MB) re-renders itself,
and everything in `config/` ships from the repo.

What is irreplaceable, and easy to lose:

- **`world/serverconfig/`** holds 23 Forge server-scoped configs that live
  *inside* the world, including the Sophisticated Backpacks slowness nerf.
  `defaultconfigs/` only seeds **new** worlds, so letting these regenerate
  instead of carrying them silently reverts tuned values to mod defaults. A
  `world/` tar includes them; a region-files-only copy does not.
- **`.env`** is gitignored, so it does not travel with a clone. Copy it across,
  or let `scripts/setup.sh` generate a fresh one (it mints a new RCON password,
  which is fine).

On the old host:

```bash
cd server
./scripts/backup.sh
```

On the new host:

```bash
git clone https://github.com/wrenchInTheWorks/iron-and-arcana.git
cd iron-and-arcana/server
./scripts/setup.sh
docker compose stop
docker run --rm -v iron-and-arcana_data:/data -v "$PWD:/restore" alpine   tar xzf /restore/world-<date>.tar.gz -C /data
docker compose start
```

Restore **after** the first start, not before: that first boot is what creates
the volume and installs the pack, and the throwaway world it generates is then
overwritten by the restore.

Then fix ownership. A tar restored as root leaves root-owned files, and the
owning mod crashes with `AccessDeniedException` on its next write:

```bash
docker run --rm -v iron-and-arcana_data:/data alpine chown -R 1000:1000 /data/world
```

Verify with `./scripts/status.sh`, then join and check your inventory and
position - the surest sign the right world came across.

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

## Planned: exposing the server

Decided, to be built once the Linux host is ready. **No CGNAT** on this
connection, which is what makes the simple route viable.

| Need | Approach |
|---|---|
| Game port | Forward TCP 25565 to the Linux host |
| Dynamic IP | A `cloudflare-ddns` container updating the A record — no static IP needed |
| Friendly address | DNS A record **grey-clouded (DNS-only)** plus an SRV record, so players type the hostname with no port. Orange-cloud proxying breaks Minecraft |
| BlueMap | Cloudflare Tunnel (`cloudflare/cloudflared` service in this compose stack) → `http://minecraft:8100`. Keeps 8100 closed and gives TLS |

**Why not tunnel the game port too:** Cloudflare Tunnel is HTTP-native. Raw TCP
requires `cloudflared` on every *client*, or Spectrum (Enterprise). The
client-side route exists — the **Modflared** mod, which could be shipped in the
pack with a `forced_tunnels.json` — but it was rejected: its 1.20.1 Forge build
is frozen at May 2024, it downloads and runs a `cloudflared` binary from GitHub
on each player's machine, and if it breaks *nobody* can connect. Port
forwarding fails in ways that can be diagnosed and fixed from the server side.

Reconsider Modflared only if this connection is ever moved behind CGNAT, where
port forwarding becomes impossible.

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
