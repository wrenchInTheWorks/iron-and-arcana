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
(Invoke-WebRequest "https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/main/pack.toml" -UseBasicParsing).Content
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
inside the container, so `RCON_PASSWORD` never crosses the network. The Discord
bot reaches it over the compose network rather than a published port, which is
why the two have to run on the same host.

## Whitelisting

`ENABLE_WHITELIST=TRUE`, seeded from `WHITELIST` in `.env`. Day to day, though,
**players whitelist themselves from Discord** — the Wrench's Toolkit bot
resolves the name against Mojang and issues `whitelist add` over RCON, so
`whitelist.json` stays the single source of truth and nobody edits it by hand.

> **Do not set `OVERRIDE_WHITELIST=TRUE`.** The image's whitelist handling
> defaults to `MERGE`, which is what makes bot-added players survive a restart.
> `OVERRIDE_WHITELIST=TRUE` switches it to `SYNCHRONIZE`, which prunes everyone
> not named in the `WHITELIST` variable — so every self-whitelisted player
> would silently lose access at the next scheduled restart. This was confirmed
> empirically, both ways, on 2026-10-12. The same applies to `OVERRIDE_OPS`.

Removal is `/ia mod whitelist-remove` in Discord, or `whitelist remove <name>`
over RCON for an entry added by hand.

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

There is no backup script here any more. **Routine backups are the Discord
bot's job** -- Wrench's Toolkit takes them on a schedule, without stopping the
server (`save-off`, flush, copy, `save-on`) and copies them off-host to Google
Drive with restic, deduplicated so two days of two-hourly snapshots costs about
46 MB. See `IRON_ARCANA_HANDOVER.md` in that repo.

The recipe above remains the way to take one **by hand** -- for a migration, or
if the bot is not running. It stops the server, which the bot's version does
not need to.

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

On the old host, take the archive by hand (the recipe at the top of this file):

```bash
cd server
docker compose stop
docker run --rm -v iron-and-arcana_data:/data -v "$PWD:/backup" alpine   tar czf /backup/world-$(date +%F).tar.gz --exclude=world/session.lock -C /data world
docker compose start
```

Or pull the newest archive the bot already made, which saves taking a fresh
one: they are on the bot's `bot_data` volume under `backups/`.

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
on (see `../docs/SERVER_PERFORMANCE_NOTES.md`). Two things changed for the better by
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

## Exposing the server

**No CGNAT** on this connection, which is what makes the simple route viable.

| Need | Approach | State |
|---|---|---|
| Game port | Forward TCP 25565 to the Linux host | **unverified from outside** — see below |
| Dynamic IP | A `cloudflare-ddns` container updating the A record — no static IP needed | live |
| Friendly address | A record **grey-clouded (DNS-only)**. Orange-cloud proxying breaks Minecraft | live |
| BlueMap | Cloudflare Tunnel → `http://minecraft:8100`. Keeps 8100 closed and gives TLS | **live**, serving 5.3 over HTTPS |

The DDNS container, the tunnel and the exact Cloudflare record attributes are
**not in this compose stack**. They live in their own repo with a step-by-step
runbook, `wrenchInTheWorks/cloudflare-ddns` (private). Two records, with
different owners and lifetimes:

| Record | Type | Points at | Maintained by |
|---|---|---|---|
| `minecraft.<domain>` | **A** | this box's public IP | the DDNS container, TTL 60, **grey cloud** |
| `mc-map.<domain>` | **CNAME** | `<tunnel-id>.cfargotunnel.com` | created once by `cloudflared`, proxied |

**No SRV record.** The runbook describes a `play.` SRV pointing at an `mc.` A
record, which exists so players can omit a non-standard port. This deployment
keeps the server on the default **25565**, so a single A record is enough and
the bare hostname works by itself. `mc.` and `play.` do not exist.

As live on 2026-10-14: `minecraft.` answers `122.58.125.30` (the public IP, not
anycast -- so grey cloud is intact) and `mc-map.` answers Cloudflare anycast and
serves BlueMap 5.3 over HTTPS with all five maps. **Grey cloud on the game
record is load-bearing** -- orange-cloud proxying breaks Minecraft, and
Cloudflare's proxy does not carry 25565 anyway.

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

Forward 25565 on the router/firewall. **Do not forward 8100.** BlueMap is
unauthenticated, and it does not need a hole: the Cloudflare Tunnel reaches it
over the compose network and terminates TLS, so 8100 stays closed to the
internet. Cloudflare's proxy would not carry 8100 anyway — it accepts a fixed
port list that does not include it, which is the other reason the map goes
through a tunnel rather than a proxied record.

## If the repo ever goes private

`raw.githubusercontent.com` needs the repo to be public for `PACKWIZ_URL` to
work unauthenticated. If that changes, the options are a token-authenticated
URL, GitHub Pages, or having CI bake the pack into a GHCR server image and
deploying that instead.

## Config files

Mod configs **are** tracked, in `config/` at the repo root, and packwiz ships
them like any other pack file. The repo is authoritative: packwiz-installer
rewrites them at every container start, so **an edit made inside the container
is overwritten on the next restart**. Edit the repo, push, wait out the CDN
cache, restart.

Five files are tracked deliberately rather than the whole generated tree —
`ProjectRed.cfg`, `bluemap/core.conf`, the two Sophisticated ones, and
`world-gen.json`. Everything else is left at mod defaults and generated in the
volume, which keeps the diff readable and avoids shipping schemas that change
under us between mod versions.

`defaultconfigs/` is a different mechanism. Forge server-scoped configs live
per-world in `world/serverconfig/`, so `defaultconfigs/` seeds **new** worlds
only — changing one means stopping the server and copying it into the running
world by hand.
