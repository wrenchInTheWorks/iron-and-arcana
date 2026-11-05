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

`PACKWIZ_URL` points at a `pack.toml` in this repo, and packwiz-installer runs
on every container start — so whatever it points at **is** what the server
runs. There is no separate push step and the server cannot drift from the repo,
which was the failure mode of the old SFTP sync.

**It is pinned to a release tag, currently `v2.4.0`:**

```
PACKWIZ_URL=https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/v2.4.0/pack.toml
```

That makes a restart *reproducible* rather than an update. Pointed at a branch
head instead, an unattended 5:30am restart would install whatever was last
pushed, half-finished work included. Updating is now a deliberate act:

```bash
# edit PACKWIZ_URL in .env to the new tag, then
docker compose up -d
```

**`up -d`, not `restart`.** A restart reuses the existing container with the
environment it was created with, so the new tag would be ignored and nothing
would appear to happen.

**Pull this repo on the host before the first `up -d` after 2026-11-05.** That
change added `stop_grace_period` to `docker-compose.yml` (see "Placed blocks
vanished" below). The container being replaced still has Docker's old
10-second limit, so stop it with an explicit timeout first, once:

```bash
git pull
docker compose stop -t 180 && docker compose up -d
```

Verify a tag before pinning to it — a release once tagged the wrong commit:

```bash
git rev-parse v2.4.0 && git show $(git rev-parse v2.4.0):pack.toml | head -3
```

> Because the tag is immutable, the CDN caching note below stops mattering for
> normal updates: a tag's content never changes, so there is no stale version
> to catch. It still applies if you ever point this back at a branch.

### Wait before restarting after a push

`raw.githubusercontent.com` sends `Cache-Control: max-age=300`, so for up to
**5 minutes** after a push it may still serve the previous version. Restarting
inside that window makes packwiz-installer quietly install the **old** files —
the server comes up healthy and looks correct, which is what makes this nasty.

Either wait a few minutes, or verify what GitHub is actually serving first:

```powershell
(Invoke-WebRequest "https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/v2.4.0/pack.toml" -UseBasicParsing).Content
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

## Crashes, logs and rollbacks

### Where to find the logs

Everything is in the volume, under `/data`. `scripts/files.sh` reaches it
whether the server is up or not, and `pull` copies into `server/pulled/`.

| What | Where in `/data` | Get it |
|---|---|---|
| Crash reports | `crash-reports/crash-<date>-server.txt` | `./scripts/files.sh pull crash-reports` |
| This run's log | `logs/latest.log` | `./scripts/logs.sh 500`, or `/ia mod logs` in Discord |
| Earlier runs | `logs/<date>-<n>.log.gz`, one per start | `./scripts/files.sh pull logs` |
| The JVM itself died | `hs_err_pid*.log` | `./scripts/files.sh ls` |
| Players' own crashes | their instance folder: `crash-reports/` and `logs/latest.log` | ask them for it |

**The crash is in the log before the current one.** The container restarts by
itself after a crash, so `latest.log` is the fresh boot. Look in the newest
`.log.gz` instead.

**No crash report at all means the process was killed from outside.** Nothing
inside Java runs, so nothing is written. Each rolled log shows how its run
ended. A run that stopped cleanly logs `Stopping server`. A killed one simply
stops mid-play, usually on a run of `Can't keep up!` warnings:

```bash
docker compose exec -T minecraft sh -c 'cd /data/logs && for f in $(ls -tr 20*.log.gz); do
  printf "%-20s new-run=%-3s stopped=%s  last line %s\n" "$f" \
    "$(zcat $f | head -1 | grep -q "\[main/" && echo yes || echo no)" \
    "$(zcat $f | grep -c "Stopping server")" "$(zcat $f | tail -1 | cut -c2-22)"; done'
```

A `new-run=no` file is the daily rollover, so read it as part of the run
before it. A run whose files never show `stopped=1` was killed. On 2026-11-04,
every run after the 10:31 update ended that way.

> **Do not count `All dimensions are saved`.** An earlier version of this
> section did. That line is also printed about a minute after every **boot**,
> so a killed run still scores 1.

Two things kill the server from outside, and **Docker cannot tell you which**:

1. **The host ran out of memory.** This is the one that has actually happened,
   repeatedly (see "Memory" below). The kernel's OOM killer takes the biggest
   process, which is always Java. Docker's `OOMKilled` flag stays `false`,
   because it only covers a container memory limit and this stack sets none.
   The restart policy also brings the server back within a minute, so
   `docker inspect` shows a healthy container. The host's kernel log is the only
   record, one boot at a time:

   ```bash
   journalctl -k -b 0 | grep 'Killed process'    # this boot; -b -1 for the one before
   sar -r; sar -S                                # memory and swap every 10 minutes (sysstat)
   ```

2. **Docker's stop timeout ran out** (see below).

A crash report titled *Watching Server* means one tick hung for 60 seconds and
the watchdog killed it. That is lag, not a broken mod. `spark` is in the pack,
so `/spark profiler` will show what was eating the tick. If the host is
swapping, the watchdog can fire without managing to write the report at all.

### Memory: what `MAX_MEMORY` really costs

Java's resident size is the heap **plus about 1.3 GB** of its own (metaspace,
code, threads, GC). That was measured at 9.3 GB resident for an 8 GB heap.
`USE_AIKAR_FLAGS` commits `INIT_MEMORY` at boot, and under load the heap grows
to `MAX_MEMORY` and stays there. So the budget is:

> `MAX_MEMORY` + 1.5 GB + everything else on the host  <=  RAM, **without swap**

**Swap is not headroom.** Once the heap is partly swapped out, every garbage
collection touches disk. The first symptom is 15-30 second `Can't keep up!`
stalls, and the kill follows once swap fills too. On 2026-11-04, a 15 GiB host
running a desktop session and a browser beside a 12 GB heap swapped to 100% and
was OOM-killed seven times in one afternoon and evening, roughly every 40
minutes of play.

`VIEW_DISTANCE` is the other half. The server keeps `(2v+1)^2` chunks per
player and generates every one of them when a player explores: 289 at 8, 625 at
12, 2401 at 24. Raising it multiplies memory, worldgen and bandwidth together.

### Placed blocks vanished, but inventories did not

This is what a kill looks like from inside the game. Players are saved more
often than the world. Each player's file is written whenever that player logs
off, and when the server stops it saves **players first and chunks second**.
The world only reaches disk at the 5-minute autosave and at a clean stop. A
lagging server ticks slowly, so the autosave comes even less often in real time.
When the process is killed, inventories are as recent as each player's last
logoff, but the world goes back to the last autosave. Blocks placed since then
vanish and do not come back to anyone's inventory. Items moved into chests
vanish the same way. Items taken *out* of chests come out duplicated.

**The confirmed cause was host OOM kills.** Every run on 2026-11-04 and 11-05
ended in one. None logged `Stopping server`, and each kill is in the host's
kernel log, 20-40 seconds after that run's last line. The **10-minute** losses
players reported fit a server that had fallen a quarter to a third behind
real time.

**Docker's stop timeout can do the same, and it has been fixed.** Docker
SIGKILLs a container **10 seconds** after asking it to stop, and saving this
pack's dimensions can take longer than that. So `docker compose stop`,
`restart`, `down` and every update could cut the save short.
`docker-compose.yml` now sets `stop_grace_period: 3m` and `STOP_DURATION: 150`.
`stop.sh` reports an exit code of 137 rather than claiming the world is safe.
This was diagnosed from the code, and no logged run has ended this way yet.

Two smaller windows remain, and both are vanilla behaviour:

- A **watchdog crash** saves nothing at all. Players and world roll back
  together to the last autosave (every 5 minutes), so time is lost but no
  items are.
- **Logging off saves that player immediately**, but the world only saves at
  the next autosave. If the server crashes in between, blocks that player
  placed before leaving can be lost. The window is at most 5 minutes.

### "Failed to verify username!"

That message comes from the server, and it means Mojang's session server said
the player had not joined. A network failure shows a different message,
*Authentication servers are down*. The server log says which it was:

```bash
docker compose exec -T minecraft sh -c 'zcat /data/logs/20*.log.gz; cat /data/logs/latest.log' \
  | grep -E "invalid session|servers are unavailable"
```

- `Username 'X' tried to join with an invalid session`: Mojang did not
  recognise the join. Each retry repeats the whole handshake, which is why the
  second or third try works. It is between the client, the launcher's login
  and Mojang. If one player hits it constantly, they should sign out of the
  launcher and back in to refresh their token. On this server it **clusters
  right after a crash**: everyone reconnects at once and retries rapidly, and
  one burst on 2026-11-04 was a dozen attempts in two minutes. A stable
  server shows it only now and then.
- `Couldn't verify username because servers are unavailable`: this host could
  not reach `sessionserver.mojang.com`. Check the host's DNS and network.

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

Set `BLUEMAP_BIND=127.0.0.1` in `.env` to keep 8100 off the LAN as well. The
live host does this. The tunnel does not use the published port at all, so
the only thing that still reaches it is `curl http://localhost:8100` on the
host. Before 2026-11-05 the host got the same effect by deleting the port line
from its copy of `docker-compose.yml`, which left the clone permanently dirty.
Keep host-specific settings in `.env`, so the clone can follow `main` cleanly.

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
