# Iron & Arcana — Claude Handover Document
**Forge 1.20.1 | v2.4.0 (on `main`) | Small private friend server**

---

## Pack Identity

| Field | Value |
|---|---|
| Name | Iron & Arcana |
| Version | 2.4.0 |
| Minecraft | 1.20.1 |
| Loader | **Forge 47.4.10** (not NeoForge) |
| Author | iron-and-arcana |
| Distribution | **GitHub Releases only** — not published on Modrinth |
| Server | Self-hosted Docker (`server/`) |
| Repo | `C:\Users\email\Documents\Git\Iron & Arcana` → `wrenchInTheWorks/iron-and-arcana` |

### Why 1.20.1 and Forge

Tinkers' Construct caps at 1.20.1, and Create, Immersive Engineering, Ars
Nouveau, EMI and Chipped all cap at 1.21.1 — so 1.21.1 was the ceiling either
way and 1.20.1 costs almost nothing. **83 of 86** Modrinth mods already had
1.20.1 builds. Forge over NeoForge because Botania and EMI publish Forge-only
files on 1.20.1, and Forge 47 is what every 1.20.1 mod is tested against.

**Do not "upgrade" the pack to a newer Minecraft version.** Doing so means
dropping Create and Immersive Engineering, which are the pack's tech pillars.

---

## Directory Layout

| Path | Purpose |
|---|---|
| `.` | packwiz project root, git repo |
| `mods/*.pw.toml` | one metadata file per mod (120 entries, 11 CurseForge-sourced) |
| `server/` | Docker deployment — compose file, `.env.example`, README |
| `server/mods-override/` | jars packwiz-installer cannot fetch |
| `docs/v1-mod-inventory.md` | v1.2.3 snapshot + per-mod 2.0 disposition |
| `C:\Users\email\Desktop\I&A MC Server\` | **legacy** v1 test server — superseded by Docker; still holds the un-ported KubeJS scripts |

---

## The live server machine: test locally first (owner's rule, 2026-11-05)

The live server and the Discord bot run on **`garage-server_wireless`**
(Ubuntu, LAN). This computer can reach it over SSH as
`michael@garage-server_wireless`.

> **Nothing experimental reaches the server machine** unless it has first been
> tested on the **local** server on this computer, or the owner explicitly
> says to apply it directly to the server.
>
> That covers everything that changes state there: pack updates (moving
> `PACKWIZ_URL` to a new tag), `docker-compose.yml` and script changes, bot
> deploys and rebuilds, config or world edits, and any command that writes on
> the host or inside its containers.
>
> **Read-only inspection is fine** when asked for: logs, crash reports,
> `docker inspect`, `docker compose ps`, and `ls` / `cat` / `zcat` / `grep`
> inside the running container. Prefer `docker compose exec -T` reads over
> `docker run`, which can pull an image and start something new on the host.

The local server is this repo's own `server/` stack under **Docker Desktop**.
The engine is often stopped, so `docker ps` fails until Docker Desktop is
started. That does not mean there is no local server.

SSH: the owner replaced `~/.ssh/id_ed25519` on 2026-11-05 with a key that has
**no passphrase** (`SHA256:keHiGn3s...`), so `-o BatchMode=yes` works directly.
The old one had a passphrase. With a key like that, BatchMode fails with
"Permission denied" right after "Server accepts key", and the owner, not Claude,
types the passphrase into an agent. Three traps:

- **PowerShell 5.1 strips embedded double quotes** from arguments to native
  programs, so a multi-line remote script passed as an argument arrives
  mangled (`template parsing error: function "com" not defined`). Run it from
  Git Bash instead: `/c/Windows/System32/OpenSSH/ssh.exe -o BatchMode=yes
  michael@garage-server_wireless bash -s <<'EOF' ... EOF`.
- Use Windows OpenSSH (`/c/Windows/System32/OpenSSH/ssh.exe`), not Git Bash's
  own `ssh`, which does not see the Windows agent or the same config.
- **`docker compose exec -T` inside a `bash -s` heredoc eats the rest of the
  script.** It reads stdin, and stdin is the script, so every line after it
  silently never runs. Put `</dev/null` on every `exec` (and `stop`/`up`) in a
  heredoc'd script.

**What is on the host** (tidied 2026-11-05, on the owner's instruction):

| | |
|---|---|
| Server stack | `~/Desktop/Iron & Arcana/server`, a **symlink** into a git clone at `~/Documents/Git/iron-and-arcana`. Run `docker compose` from the symlink path: it is the project's recorded working dir |
| That clone | on **`main`, tracking `origin/main`, clean**. It was on `2.0` at `54de19f` (2026-10-02) with an uncommitted `docker-compose.yml` edit until 2026-11-05. The local `2.0` branch was deleted |
| Host-specific settings | **all in `.env`**: `INIT_MEMORY=8G`, `MAX_MEMORY=8G`, `VIEW_DISTANCE=24`, `SIMULATION_DISTANCE=8`, `BLUEMAP_BIND=127.0.0.1`, `PACKWIZ_URL` at `v2.4.0` |
| What was replaced | `~/iron-and-arcana-backups/` (mode 700): `env-2026-11-05-before` (the old `.env`, which holds the RCON password) and `compose-local-edit-2026-11-05.patch` |
| Tunnel and DDNS | `cloudflared` from `~/Desktop/Networking/cloudflared-tunnel`, joined to `iron-and-arcana_default` and reaching BlueMap over it, so 8100 does not need publishing. `cloudflare-ddns` from `~/Documents/Git/cloudflare-ddns` |
| Bot | `~/Documents/Git/wrenchs-toolkit-discord-bot`, on **`master`** tracking `origin/master`, clean. Deployed 2026-11-05 at `308ddef` (pre-generation, `/ia config pregen`, `/ia config restart`). The bot repo's `2.0` branch was fast-forwarded into `master` and deleted the same day, so `master` is live. Update with `git pull --ff-only` then `docker compose up -d --build` |
| Bot schedules | **Backups every 2 hours** (`BACKUP_INTERVAL_HOURS=2`, on since 2026-11-05 14:24). Daily restart and pre-generation are **off** until an administrator sets them with `/ia config restart` / `/ia config pregen`. The bot's previous `.env` is at `~/iron-and-arcana-backups/bot-env-2026-11-05-before` |
| Machine | 15 GiB RAM, 4 GiB swap, 4 cores, Ubuntu 26.04.1, kernel 7.0, GNOME desktop session, on **Wi-Fi** (connection `SPARK-SZX7GC-5G`) through a Realtek USB dongle (`rtw88_8821cu`) |
| Not scheduled | `michael` has no crontab, so `auto-restart.sh` does not run. Restarts are the bot's job now |

**Updating the host** is now `git pull --ff-only` in the clone, then
`docker compose up -d` from the stack path. Keep the clone clean. Anything
host-specific goes in `.env`, never into a tracked file. A local edit to
`docker-compose.yml` is what kept this clone on a month-old branch: pulling
would have meant merging around it, so nobody pulled.

---

## Key Workflows

```bash
# After any pack change:
packwiz refresh

# Local export check (CI does this too):
packwiz modrinth export
packwiz curseforge export

# Server: PACKWIZ_URL is PINNED TO A TAG, so a restart is reproducible,
# not an update. To update, edit the tag in .env then:
cd server
docker compose up -d          # NOT restart -- restart keeps the old env
docker compose exec minecraft rcon-cli
```

Releases are cut by `.github/workflows/publish.yml` **only when `pack.toml`
version changes** — pushing without a version bump builds but does not release.

**Wait ~5 minutes between pushing and restarting the server.**
`raw.githubusercontent.com` sends `Cache-Control: max-age=300`, so a restart
inside that window makes packwiz-installer install the **previous** version of
any changed file. The server boots healthy and looks right, so verify by
comparing file sizes rather than trusting a clean startup:

```bash
docker compose exec -T minecraft sh -c "wc -c < /data/config/<file>"
```

**Configs are now tracked in `config/` and shipped by packwiz**, so the repo is
authoritative and in-container edits are overwritten on every start. Edit the
repo, not the container. Note `defaultconfigs/` is different: Forge
server-scoped configs live per-world in `world/serverconfig/`, so
`defaultconfigs/` only seeds **new** worlds — changing one means copying it into
the running world by hand with the server stopped.

**Edit container files as uid 1000, not root** (`docker compose exec --user
1000:1000 ...`). A root-owned config makes the mod that owns it crash with
`AccessDeniedException` on the next write.

packwiz is on `PATH` at `C:\Users\email\go\bin\packwiz.exe`; a CurseForge API
key is configured in `%APPDATA%\packwiz\.packwiz.toml`.

---

## Adding Mods — Hard-Won Rules

- **Always add Modrinth mods by `--project-id`, never by slug.** With `-y`,
  packwiz falls back to search and will silently add the wrong mod.
- **Verify the resolved filename after adding a CurseForge mod.** Byzantine
  Styles resolved to a `1.21.1` jar inside this 1.20.1 pack because its CF file
  metadata is mis-tagged. It was dropped for that reason.
- **Prefer Modrinth when a mod exists on both platforms.** CF mods cannot be
  referenced by URL and have to be bundled, which is what made the v1 mrpack
  269 MB. Watch for a CF dependency *overwriting* a Modrinth entry — FTB Quests
  silently replaced Architectury API with its CurseForge copy; re-add from
  Modrinth afterwards.
- **Run `packwiz modrinth export` after adding CurseForge mods.** It is the only
  check that catches a mod with third-party distribution disabled, which packwiz
  cannot download at all. SmallColonies was dropped for exactly this. The export
  prints "Found N manual downloads" and names them.
- **Do not hand-set `side`.** packwiz infers it from platform metadata; v1's
  hand-set flags drifted. Sides were audited on 2026-09-30 and are correct —
  Embeddium in particular is correctly `client`.
- **Read the FULL mandatory dependency list out of each jar's `mods.toml`
  before shipping.** Modrinth's API dependency data is incomplete and will not
  show them. Adding six Tinkers addons crash-looped the server on three missing
  mandatory deps (`jsonthings`, `attributeslib`, `jei`) that the Modrinth
  metadata never mentioned. Check every `mandatory = true` entry, not just the
  one you happen to be thinking about:

  ```python
  # per jar: re.findall(r'\[\[dependencies\.[^\]]+\]\](.*?)(?=\[\[|\Z)', mods_toml, re.S)
  # keep blocks where mandatory = true, print modId + versionRange
  ```
- **JEI is the recipe viewer. EMI was removed.** Every major mod here ships a
  JEI plugin and none ship EMI support, so JEI renders them natively -- see
  "Recipe viewing" below before reintroducing either.
- Run `packwiz refresh` every 10–15 additions to catch index errors early.

---

## 2.0 Progress

### Done

| | |
|---|---|
| Pack rebuilt | 95 entries re-resolved for 1.20.1 Forge from scratch (`247b367`) |
| Export verified | `packwiz modrinth export` succeeds; 2.0.0 mrpack is 176 MB vs v1's 256 MB |
| First boot | Server runs, world generates, BlueMap renders, client connects (`v2.0.0-firstboot`) |
| No flight mod | Create Aeronautics has no 1.20.1 release; Valkyrien Skies + Clockwork were trialled then **removed as off-theme** |
| Storage | Sophisticated Backpacks is back — upgrades gated by the **mod's own config**, not KubeJS |
| Gear swap | Tinkers' Construct 3.12.1.231 + Mantle replace Silent Gear |
| Restored | Twilight Forest, Stylecolonies, SmallColonies, TownTalk, FTB Quests/Teams/Library, Botania |
| Unofficial ports retired | Alex's Caves, Alex's Mobs, Citadel, Spartan Weaponry, Steam 'n' Rails now official 1.20.1 builds |
| Recipe viewing | JEI is the viewer; EMI tried first and removed 2026-10-11 (see Recipe viewing) |
| Redstone | Project Red (5 modules) replaced More Red 2026-10-13 — More Red had no timers, counters or sequencers |
| Docker server | `server/` — itzg image, `PACKWIZ_URL` self-install (`bae071e`) |
| Infra stripped | EventBridge and all Modrinth publishing removed (`2db8bf6`) |
| Discord mod removed | DI dropped, 112 -> 111 mods. The bridge is bot-side (log tail + RCON), so the pack needs no Discord mod and stays playable with no bot |

### Not done yet

1. **Linux migration.** The runbook is in `server/README.md` ("Moving the
   server to another host"). Only `world/` moves (40 MB in October, 1.2 GB by
   2026-11-05);
   mods re-download, BlueMap re-renders, `config/` ships from the repo. The two
   things that do not survive on their own are `world/serverconfig/` (23
   per-world Forge configs, including the backpack slowness nerf, which
   `defaultconfigs/` will NOT reseed into an existing world) and `.env`, which
   is gitignored.
2. **Backups — now the bot's job.** `server/scripts/backup.sh` was deleted on
   2026-10-12: Wrench's Toolkit takes scheduled backups without stopping the
   server (`save-off`, flush, copy, `save-on`) and copies them off-host to
   Google Drive with restic, deduplicated so two days of two-hourly snapshots
   costs ~46 MB rather than ~716 MB of full copies. The manual recipe in
   `server/README.md` is still the migration path and the fallback when the bot
   is down. **A restore has still never been performed**, so the migration
   remains its first real test.

   > **Scheduled backups were off until 2026-11-05.** The bot's `.env` on the
   > host had `BACKUP_INTERVAL_HOURS=0`, and the newest local archive was from
   > 2026-10-12. Turned on at 14:24 that day (`2`, two-hourly) at the owner's
   > request. The first run at 14:34:
   >
   > - **Local: fine.** 1043 MB archive from 1228.6 MB of world, in 46.7 s.
   >   Six are kept, so budget about 6.5 GB on the bot's volume. **The world is
   >   1.2 GB now**, against 41 MB in October, mostly `region/` (view distance
   >   24 generating chunks as players explore). Every size estimate in the bot's
   >   docs predates that.
   > - **Off-host: failing.** Google answers `invalid_grant: Token has been
   >   expired or revoked`. The `rclone.conf` uses the owner's **own** OAuth
   >   client (`client_id` set, `scope = drive`). An OAuth app left in
   >   **Testing** status gets refresh tokens that expire after 7 days, so a
   >   reconnect alone would fail again a week later. Fix: set the app to
   >   *In production* in Google Cloud (OAuth consent screen / Audience), then
   >   reconnect. The file is `config/rclone.conf`, owned by the bot's uid
   >   10001 with mode 600, so michael needs sudo to copy it out and back.
   > - **When off-host works again, the first snapshot is ~1 GB, and it runs
   >   inside the `save-off` pause** (`_perform_backup` holds one pause for both
   >   copies). Saving stays off for the whole upload, over Wi-Fi at the edge
   >   of range. Later snapshots are incremental and short.
   > - **No audit channel is set**, so every backup, restart and pregen report
   >   goes only to the bot's stdout (`(no audit channel set)` in its log).
   >   Set one with `/ia config audit-channel`.
3. **Cloudflare exposure.** Port-forward 25565, a `cloudflare-ddns` container,
   DNS-only A record plus SRV, and a Tunnel for BlueMap only. No CGNAT (public
   IP confirmed, gateway 192.168.1.254). The runbook lives in the private
   `wrenchInTheWorks/cloudflare-ddns` repo; the record layout is summarised in
   `server/README.md`.

   > **The addresses are `minecraft.` and `mc-map.`, and both resolve.**
   > Measured over DoH on 2026-10-14: `minecraft.wrenchintheworks.online` is an
   > **A** record to `122.58.125.30` -- the connection's own public IP, not a
   > Cloudflare anycast address, so it is correctly grey-clouded.
   > `mc-map.wrenchintheworks.online` answers with Cloudflare anycast
   > (`104.21.32.198`, `172.67.154.115`), i.e. proxied through the tunnel.
   >
   > **There is no SRV record and none is needed.** The runbook's original
   > shape was `play.` (SRV) -> `mc.` (A), which exists to serve a non-standard
   > port. This is one A record with the server on the default 25565, so the
   > bare hostname works on its own. **Neither `mc.` nor `play.` exists** --
   > earlier drafts of this file and of `docs/discord-welcome.md` named them,
   > and that was wrong.
   >
   > BlueMap is confirmed live: HTTP 200, `settings.json` reports version 5.3
   > (the pinned build) and all five maps. **The game port is NOT verified** --
   > TCP 25565 times out from inside the LAN, which proves nothing because
   > consumer routers rarely hairpin to their own public IP. Test from mobile
   > data.
4. **Config tuning** after some playtime. Serene Seasons was made cosmetic on
   2026-11-03 -- see "Serene Seasons is cosmetic" below.
5. ~~Pin `PACKWIZ_URL` to a tag~~ **done 2026-11-04** -- pinned to `v2.4.0`
   in `server/.env.example`. The live `server/.env` is gitignored and has to
   be changed by hand on the host. See "Restarts" below.

### Version and branch state

**`main` is the live branch. Work on `main`.**  `2.0` was fast-forwarded into
`main` on 2026-10-11 (53 commits, no divergence) and the pack went to **2.2.0**.

> **The `2.0` branch was deleted on 2026-11-05**, on GitHub, in this checkout
> and on the host. It had been a trap: frozen at `9bd0290` (113 mods, no
> Project Red) while reporting the same `version = "2.2.0"` as `main`, so a
> server whose `PACKWIZ_URL` ended in `/2.0/pack.toml` booted happily on a
> two-week-old pack with no error anywhere. That happened on 2026-10-13. Every
> commit it held is in `main`. A `PACKWIZ_URL` still naming `/2.0/` now gets a
> 404 and the server refuses to boot, which is the loud failure it should
> always have been.
>
> If a host is "not getting the new mods", **check `PACKWIZ_URL` in its `.env`
> first**, before anything else. Note `docker compose pull` is unrelated -- it
> fetches the server image; the pack is installed by packwiz-installer at
> container start. And after editing `.env` use `docker compose up -d`, not
> `restart`: restart reuses the existing container with its old environment.

Everything that used to point at the `2.0` branch now points at `main`:
`README.md`'s packwiz-installer route, `server/.env.example`, and the
verification snippet in `server/README.md`. The live `server/.env` pins a
release tag (`v2.4.0`).

Releases are cut by `publish.yml` whenever `pack.toml`'s version **changes**
between commits, on `main`. It passes `--target "$GITHUB_SHA"`, so
tags land on the commit actually built -- that was broken once and produced a
v2.1.0 tag pointing at a v1.2.3 commit, which was deleted.

**Verify any new tag before trusting it**, especially before pinning
`PACKWIZ_URL` to one:

```bash
git rev-parse v2.2.0 && git show $(git rev-parse v2.2.0):pack.toml | head -3
```

**No longer applicable:** FTB Quests was removed, so the 15 authored v1 quest
chapters are not being restored. They remain in git history at
`git show 5a36352^:config/ftbquests/...` if a quest mod is ever reintroduced.

---

## KubeJS Port — RESOLVED: nothing to port

Checked 2026-10-01 by reading the jars. **Every v1 KubeJS job is obsolete on
1.20.1**, so no scripts were carried over:

| v1 script job | Status on 2.0 |
|---|---|
| IE aluminum tag fix | **Not needed.** IE 1.20.1 already ships `data/forge/tags/items/ingots/aluminum.json` containing `immersiveengineering:ingot_aluminum`. v1 needed it only because NeoForge 1.21.1 moved common tags to the `c:` namespace |
| IE refined iron tag fix | **Not applicable.** `ingot_iron_refined` does not exist in IE 1.20.1 — zero matches in the jar. It is a 1.21/NeoForge-line item |
| 29 Sophisticated upgrade removals | Replaced by Sophisticated Core's own config |
| 18 Silent Gear material overrides | Silent Gear removed from the pack |
| EMI stack hiding | Unnecessary — config-disabled items do not appear |

**Nothing was ported, but KubeJS is no longer idle** — it now carries two
`kubejs/data/` recipe overrides, which is exactly the escape-hatch use it was
kept for (v1 maintained a running list of broken recipes). Note Architectury
API is a KubeJS dependency — check before removing either.

### Live KubeJS overrides

Both fix upstream bugs in **Tinkers' Delight 2.0.3** (the Tinkers x Farmer's
Delight integration), and both were diagnosed by probing the live registry with
`rcon-cli give`, which reports `Unknown item '<id>'` for an unregistered id and
`No player was found` for a valid one — a cheap existence probe with no player
online.

| Override | Upstream bug | Fix |
|---|---|---|
| `recipes/cooking/noodles/steak_and_ichor_pasta.json` | references `tconstruct:ichor_ball`, which is not registered | corrected to `tconstruct:ichor_slime_ball` |
| `recipes/tinkering/tools/papas_fried_rice/repair_4.json` | repairs with `tinkers_delight:slime_rice`, which the mod never registers — only `slime_rice.png` ships, no item, no lang entry | ingredient swapped to `tinkers_delight:earth_slime_pasta` |

A bad id does not just skip one ingredient, it fails the **whole** recipe at
load, so Steak and Ichor Pasta was unobtainable rather than merely awkward.

`the_rice_general` repair tiers, for picking future substitutes: 250 plain
cooked rice, 750 mid (fried / mushroom / the dead slime slot), 1500 Queens
Slime Braised Rice. `earth_slime_pasta` was chosen for the 750 slot because
Earth Slime is Tinkers' entry-tier slime, so it stays below Queens Slime.

Note `moms_spaghetti/repair_4.json` is a **different** tool's recipe and is
fine — do not confuse the two when editing.

Common-tag namespace on this pack is **`forge:`**, not `c:`. Anything copied
from v1 scripts or from 1.21 examples will use the wrong namespace.

## Historical: v1 KubeJS scripts

Scripts are at `C:\Users\email\Desktop\I&A MC Server\kubejs\`.

**Keep — Immersive Engineering tag fixes** (`server_scripts/main.js`). IE's
aluminum and refined iron are not registered under the common tags, which broke
recipe unification:

```js
ServerEvents.tags('item', event => {
    event.add('c:ingots/aluminum', 'immersiveengineering:ingot_aluminum')
    event.add('c:ingots/refined_iron', 'immersiveengineering:ingot_iron_refined')
})
```

> On 1.20.1 Forge the common tag namespace is `forge:` rather than `c:` —
> check which one Almost Unified and the recipes actually expect before porting.

**Do not port — the 29 Sophisticated upgrade removals.** Sophisticated Backpacks
is back in 2.0, but the upgrades are to be gated through **Sophisticated Core's
own config**, which is simpler and survives mod updates. v1's approach of
`event.remove({ output: id })` plus EMI hiding was a workaround for not knowing
the config existed — do not recreate it. This was the bulk of v1's KubeJS
surface, so the port is far smaller than the v1 scripts suggest.

**Delete — the entire Silent Gear layer.** 18 material override JSONs, the
`hidden_silent_gear_material` dummy tag, and the redundant
`world/datapacks/ia-silentgear-fixes/` datapack. All obsolete: Tinkers'
registers materials conditionally on mod presence, so the phantom Materials Book
entries that motivated the workaround cannot occur.

**Verify — the EMI hiding event.** `ClientEvents.hideEmiStacks` was never
confirmed working even on `2101.7.2`. Re-check the name for `2001.x`.

---

## Recipe viewing: JEI, and why EMI was removed

Two rounds of this, both from the test playthrough. End state: **JEI is the
viewer and EMI is not in the pack.**

### Round 1 (2026-10-10): recipes missing entirely

Tinkers' smeltery and casting recipes were invisible, Create's non-grid recipes
were invisible, and the Crafting Station was not recognised for auto-fill.
Cause, measured by scanning jars for API references:

| Mod | files in a `/jei/` package | classes using the JEI API | classes using the EMI API |
|---|---|---|---|
| Tinkers' Construct | 105 | 67 | **0** |
| Create | 68 | 40 | **0** |
| Immersive Engineering | 56 | 25 | **0** |
| Ars Nouveau | 19 | 16 | **0** |
| JER | -- | 19 | **0** |

**Every major mod ships a JEI plugin and none ship EMI support.** EMI alone can
only infer generic recipes (crafting table, furnace); every custom category and
every recipe transfer handler lives in those JEI plugins. JEI was added as a
hidden data source behind EMI's documented runtime compat.

### Round 2 (2026-10-11): discovery fixed, rendering not

Recipes then appeared -- Casting and Jumbo Smelting both showed as tabs -- but
rendered wrong: Jumbo Furnace drew magenta missing-texture blocks and Tinkers
Casting showed an "Error" panel from an exception during draw.

**Not a version mismatch, and that was checked rather than assumed.** All
**126** member references EMI 1.1.24 makes into JEI exist in JEI 15.62.0.219,
and the only JEI class EMI references that is absent is Fabric-only.
Downgrading JEI would have fixed nothing and would have broken Tinkers
Reforged, which floors at `jei[15.56.0.204,)`.

The real cause: EMI's JEI-compat layer can enumerate foreign categories but
cannot reproduce their custom `IDrawable` backgrounds and draw code. Inherent
to translating one viewer's rendering model into another's, not a patchable bug.

So EMI was removed and JEI became the visible viewer. Nothing depended on EMI:
no EMI addons in the pack, and JEED -- the only viewer-adjacent mod -- ships
support for both and mandates neither.

**Do not reintroduce EMI expecting the pack to look better.** It renders this
pack's categories worse, and the failure lands on the gear pillar (Tinkers
casting). Revisit only if these mods ship EMI support, or EMI ships native
plugins for them.

## JER and ore distribution

Added 2026-10-11 alongside Tinkers Reforged, both unblocked by JEI now being in
the pack. Two things about JER are not obvious:

**1. The World Gen tab starts empty, and nothing in JER can fill it.** JER's
ore-distribution tab shows Y-level distribution, average blocks per chunk,
valid biomes and dimensions, drops, and silk-touch/fortune flags -- but JER
ships no world-gen data and does not read it out of the worldgen system. It
only renders what is registered through `IWorldGenRegistry`, and the scan
command that used to populate it is unreachable. That is why **JEARGH**
(Just Enough Resources Profiler) is in the pack: it restores the command.

> **`/jer_profile` does not exist in game, and the jar is misleading about it.**
> JER 1.4.0.247 still ships `jeresources/profiling/ProfileCommand` with
> `COMMAND_NAME = "jer_profile"`, so grepping the jar suggests a working
> command. It is orphaned: `jeresources/forge/event/Commands` holds the only
> `RegisterCommandsEvent` handler, is referenced by no other class, and carries
> no `@EventBusSubscriber`; `JEResources` never references
> `RegisterCommandsEvent` either. So nothing ever registers it. Verified in
> game on 2026-10-11 with cheats on -- the command is not found.
>
> Note also that `/jer_profile` is permission-gated (`requires` +
> `hasPermission`) while `/jeargh` is not, so "cheats are off" is a tempting
> but wrong explanation. **Use `/jeargh`.**

Profiling scans a chunk radius per dimension on several threads and writes
`world-gen.json`, then says "You need to restart your world for changes to
appear in JER."

**JEARGH's side is hand-set to `client`, and must stay that way.** This is the
one deliberate exception to the "do not hand-set side" rule, because the
platform metadata is demonstrably wrong: Modrinth marks it `server`, packwiz
inferred `server`, and it then **crashed the dedicated server on boot**:

```
Failed to create mod instance. ModID: jeargh
Caused by: RuntimeException: Attempted to load class
  net/minecraft/client/server/IntegratedServer for invalid dist DEDICATED_SERVER
```

`IntegratedServer` is singleplayer's server and does not exist on a dedicated
one, and the reference is in JEARGH's static initializer, so it cannot even be
constructed server-side. It is a **singleplayer-only** mod. If a future
`packwiz update` or a re-add resets this to `server`, the server will not boot.

So profiling happens in singleplayer, and the workflow is:

1. Launch a singleplayer world on the client with this pack, on a fresh world,
   after any ore-adding mod change.
2. Run the profile command there; it writes `world-gen.json` into the client's
   config folder.
3. Commit that file to `config/` -- packwiz then ships it to every client,
   which is the repo-as-authority model doing exactly what it is for.

Ore placement comes from the pack's worldgen rules rather than the specific
save, so a throwaway singleplayer world is a valid source for data that is then
shipped to everyone.

Do not expect it to populate itself. An empty World Gen tab is the default
state, not a bug.

**2. JER renders natively now.** It is a JEI plugin end to end (19 classes on
the JEI API, zero on EMI's). While EMI was the viewer this was an open risk --
its six tabs are custom-drawn categories, exactly the kind EMI's compat layer
misrenders. With EMI removed the question is moot and the World Gen graphs
render as built.

Tinkers Reforged adds three ores -- barium, thallium and yttrium (plus a
coniferous-biome yttrium variant) -- so it needs fresh chunks. It also declares
`jei` MANDATORY, which is what kept it out of the pack before.

## world-gen.json: the Y encoding, and do NOT run `fixheights`

`config/world-gen.json` stores **Y + 64**, i.e. an index from the Overworld's
floor, for *every* dimension. Calibrated against vanilla:
`minecraft:deepslate_diamond_ore` is stored as 1..79 peak 5, which decodes to
**-63..15 peak -59** -- vanilla's range exactly. `ancient_debris` decodes to
7..120 peak 15 against vanilla's 8..119 with the bulk at 8..24.

**`/jeargh fixheights <radius>` corrupts this file.** Run on 2026-10-11, it
added a second +64 to the 19 non-Overworld entries and left the 31 Overworld
ones alone, which put ancient debris at a real Y of 71..184 in a dimension that
caps at 127. It scans nothing (it completes instantly), finds no new blocks and
changes no sample totals -- it only rewrites the Y labels, wrongly. The output
was discarded.

The command's description, "Fixing incorrect heights for non-overworld
dimensions", reads like the fix for a thin Aether. It is not.

### Merging is safe, and additive

`distrib_raw` holds integer block counts per Y level and `distrib` is the
normalised curve derived from it. `/jeargh start <radius> merge` loads the
existing file, adds new samples to those counts, and rebuilds the curve
(`loadMapFromWorldGen`, `addToMap`, `BuildRawDistrib`). So **short scans
compound** -- several small merge runs beat one multi-hour run, and a small run
cannot dilute existing data.

### Why Deep Aether's ores are still missing

Not heights, and **Deep Aether has only one ore that exists at all**.

The lang file lists seven ore names (skyjade, adibium, agate, oratie and
highstone variants), which is where an inflated expectation comes from -- a
`lang` entry is only a translation string. Checked against the rest of the jar:

| Ore | classes | models | loot/recipe | worldgen |
|---|---|---|---|---|
| `skyjade_ore` | 24 (incl. `DABlocks`, `DAConfiguredFeatures`, `DAPlacedFeatures`) | yes | yes | **yes** |
| `adibium_ore` | **0** | none | none | none |
| `agate_ore` | **0** | none | none | none |
| `oratie_ore` | **0** | 2 assets | none | none |

So adibium, agate and oratie are orphaned translation strings for content that
is not implemented in 1.1.7. They will never generate and are not worth
chasing. **Do not infer a mod's content from its lang file.**

`skyjade_ore` does generate: injected into `#aether:is_aether` (all Aether
biomes, base ones included) by a Forge biome modifier at
`data/deep_aether/forge/biome_modifier/skyjade_ore.json`, replacing the
`aether:holystone` tag, 12 attempts per chunk, vein size 6, real Y 0..60, with
`discard_chance_on_air_exposure: 0.65` so it sits buried inside islands rather
than on their surfaces. Deep Aether biomes were confirmed present in world via
`/locate biome`, so worldgen is applying. The profiler simply does not sample
that band -- its Aether entries bottom out at real Y 21.

Note **Sterling Aercloud is not an ore.** It is an `aether:aercloud` feature
placed by the same biome-modifier route, and its loot table drops the block
itself. It appears near ores in the wiki because it is a generated resource.

`JEARGHProfilerRunnable` takes a `Player` in its scan signature, so the scan
appears to centre on the player. If the ores are wanted, the cheap experiment
is to stand in a Deep Aether biome (Aerglow Forest, Golden Heights) and run a
small `/jeargh start 16 merge` there, rather than growing the radius at spawn.

## Supplementaries needs Amendments (resolved)

Supplementaries split at version 2.8.0 and moved content into a companion mod.
Running `supplementaries-1.20-3.1.43-forge` without it produced a one-time
startup warning for every player -- "Amendments is not installed" -- and left
roughly 10 blocks and 46 items absent: wall lanterns, hanging flower pots, tool
hooks, carpet stairs and slabs, directional and double cake, skull pile, dye
and liquid cauldrons.

**`amendments-1.20-2.2.6` was added on 2026-10-11**, which clears the warning
and restores the content. It was a clean add:

- mandatory deps are `forge[47.1.0,)`, `minecraft[1.20,1.21)` and `moonlight`
  at a **bare** `1.20-2.16.0` range -- non-binding per the Forge rule above,
  and the pack has Moonlight `2.16.35` regardless
- `supplementaries` and `flywheel` are both **optional** and both present
- worldgen is 3 **tag** files only (potion cauldrons added to igloo and swamp
  hut structure tags), so it was safe to add to the existing world

**Keep these two in step.** If Supplementaries is ever updated or removed,
check Amendments with it -- the warning is the only signal that they have
drifted apart, and it appears once at startup where it is easy to miss.

## Pink placeholder boxes in two JEI tabs -- upstream, not fixable here

The **Ars Nouveau ritual** tab drew magenta missing-texture boxes where a
progress bar belongs. Jumbo Smelting had the identical fault, but Jumbo Furnace
left the pack with More Red, so Ars is the only affected tab now. Both are
fixed -- see "Fixed by supplying the texture" below -- but the mechanism is
recorded because any future mod built against old JEI will hit it too.

Both mods ask JEI for the same asset:

```
jei:textures/jei/gui/gui_vanilla.png
```

JEI used to ship a single GUI sprite sheet at that path. It now ships
individual sprites under `assets/jei/textures/jei/atlas/gui/` instead
(`recipe_arrow.png`, `slot.png`, `flame.png`, ...). Measured across versions,
the sheet disappeared between **15.10.0.39 (2024-08-07)** and
**15.19.5.98 (2024-09-20)**. Neither mod ships its own copy.

**Downgrading JEI cannot fix it.** Tinkers Reforged floors at
`jei[15.56.0.204,)`, and 15.56 already lacks the texture -- the last build that
had it is roughly fifty minor versions and two years below that floor. There is
no JEI that satisfies the pack and also renders these two tabs.

**Neither mod will be fixed upstream.** Both are already on their newest 1.20.1
Forge builds: Ars Nouveau `4.12.7` (2025-06-23) and Jumbo Furnace `4.0.0.5`
(**2023-08-06**).

This is NOT the same failure as the EMI one. The API is fine -- an earlier scan
flagged five "missing" JEI members in Jumbo Furnace, but all five are declared
on parent interfaces (`IIngredientAcceptor`, `IDrawable`) and a per-class
member check does not walk the hierarchy. Only the texture is missing.

### Fixed by supplying the texture through KubeJS

`kubejs/assets/` is a client-side resource-pack overlay and can serve **any**
namespace, so the missing file is simply shipped at the path the mods ask for:

```
kubejs/assets/jei/textures/jei/gui/gui_vanilla.png
```

It is JEI's own 256x256 sheet, taken unmodified from
`jei-1.20.1-forge-15.10.0.39.jar` — the last build that contained it. JEI is
**MIT**, so redistribution is fine; the notice is in
`docs/THIRD-PARTY-NOTICES.md`.

This works because KubeJS is `side = both`, so clients receive it. If KubeJS is
ever removed, this texture goes with it and the pink boxes return — and the
link between the two is not obvious, hence this note.

If a future JEI reinstates its own `gui_vanilla.png`, delete ours rather than
letting two copies compete.

## Backpack tier upgrades show twice in JEI -- upstream, no lever

Reported from the playthrough on 2026-11-03: every backpack tier upgrade
appears twice in JEI, and "some coloured backpacks won't craft". Both come from
one mechanism, and **it is not a pack bug** -- nothing we ship touches backpack
recipes.

Sophisticated Backpacks generates its **own** tier-upgrade entries for the
recipe viewer, on top of the real ones. `BackpackTierUpgradeRecipesMaker` calls
`addRecipeViewerVariants`, and the record it produces,
`BackpackTierUpgradeDisplayRecipe`, carries:

```
displayVariants  globalVariants  variantPairs  exactPair  isUntinted
getMainColor  getAccentColor  copyWithItem
withComponentsFromSource  withComponentsFromResult
```

`isUntinted` is the tell: one generated entry holds an untinted variant plus
tinted ones, and `withComponentsFromSource` copies dye components onto the
result. It exists to show that **upgrading a dyed backpack keeps its colour**.

Meanwhile the real recipes (`data/sophisticatedbackpacks/recipes/*.json`) are
ordinary `CraftingRecipe`s, so JEI lists them itself. `BackpackJeiPlugin` has
only `addTypedRecipeManagerPlugin` and `RecipeManagerPlugin` -- **no
`hideRecipes`, no `IRecipeManager` hide path** -- so nothing suppresses the real
copy and both show. Iron shows **four** because it genuinely has two base
recipes (leather + 8 iron, or copper + 4 iron).

The "coloured backpacks won't craft" half is the same thing: JEI's `+` on a
tinted variant asks for a backpack with those exact colour components, which you
only own if you already dyed one. The untinted entry always works.

**Three levers were checked and none exist:**

- **Updating does not fix it.** Build `3.26.19.2239` (2026-10-31), thirteen
  releases ahead of our `3.26.6.2176`, has the identical
  `TierUpgradeRecipesMaker`, the identical plugin with no hide calls, and the
  same six recipe files. Do not take a mid-playthrough update for this.
- **No config option.** Sophisticated Core's *entire* common config is
  `enabledItems`; the client config is only `mouseTweaksScrollEnabled`,
  `playButtonSound` and `sortButtonsPosition`.
- **KubeJS cannot reach it.** The duplicates are generated inside the JEI plugin
  at runtime, so there is no registered recipe for `event.remove` to match.

The only lever that would remove a duplicate is disabling that tier in
`enabledItems`, which removes the tier as well -- not worth it.

> Incidental but useful: the tier chain is **leather -> copper -> iron -> gold
> -> diamond -> netherite**, each consuming the previous tier. `gold_backpack`
> takes an `iron_backpack` in the centre slot, not a leather one. The only real
> shortcut is leather -> iron for 8 iron, against 4 iron via copper.

### Disabled Sophisticated items do NOT litter JEI

Verified while investigating the above, and it is the opposite of the Project
Red case, so the distinction matters. `ItemBase.addCreativeTabItems` gates on
`isItemEnabled`, so an item disabled through `enabledItems` never enters the
creative tab -- and JEI builds its list from creative tab contents. The ~20
upgrades disabled in `config/sophisticatedcore-common.toml` are therefore
genuinely invisible, with no orphaned no-recipe entries.

Project Red needed `kubejs/client_scripts/jei_hide.js` precisely because it does
**not** gate its creative tab: removing its recipes via KubeJS left the items
listed. So: **mod-config gating hides the item; KubeJS recipe removal does
not.** Pick the config lever whenever one exists.

## Project Red: what is in, and what is gated

Replaced More Red on 2026-10-13. More Red only ever had fundamental logic --
AND/NAND/OR/NOR/NOT/XOR/XNOR, bitwise variants, a Diode, a Multiplexer, a Latch
and a Pulse Gate. No timer, no counter, no sequencer. Project Red Integration
has those: Timer, Counter, Sequencer, State Cell, Pulse Former, three
randomisers, Synchronizer, Repeater, Comparator, three latches, light and rain
sensors, segment display and the cell blocks.

Removed with it: **Use Item on Block Event** and **Jumbo Furnace**, both of
which were only ever More Red's mandatory dependencies. Jumbo Furnace was never
wanted.

### The module set, and why each

| Module | Why |
|---|---|
| Core | required by everything |
| Integration | the gates -- the entire reason for the swap |
| Transmission | **not optional**: 10 of Integration's 34 gates need `wired_plate` or `bundled_plate`, which only Transmission provides |
| Exploration | the only source of electrotine, which Fabrication's silicon chain needs |
| Fabrication | the FPGA module: IC Workbench, lithography, custom gates |

Illumination was offered and declined. CodeChicken Lib and CB Multipart are the
only libraries needed -- **`cb_microblock` is NOT a separate mod**, the CB
Multipart jar declares `cb_multipart`, `cb_microblock` and
`cb_multipart_minecraft` together.

The Forge floor is a **bracketed** `[47.1.65,)`, so unlike a bare range it is
genuinely enforced. 47.4.10 clears it; this is now the pack's hard Forge floor.

### Gating, and which lever was used

Exploration collides with two pack rules, so it is gated rather than accepted
whole. Config first, KubeJS only where no config exists:

| What | Lever | Detail |
|---|---|---|
| Tin and silver ore | **config** | `config/ProjectRed.cfg`, `world_gen` section, both `false` |
| 16 backpacks | KubeJS | `server_scripts/projectred_backpacks.js`, 17 recipes |
| Gem **armour** | KubeJS | `server_scripts/projectred_gear.js`, 12 recipes |
| Gem **tools** | *(kept)* | simple tool tiers are not a third gear mod |

Why those two ores specifically: **silver** is provided by both IE and Project
Red under the same `forge` tags, so Almost Unified unifies them and IE remains
the source. **Tin** is Project Red's alone -- IE has none -- but nothing
consumes it either; every tin recipe is tin to tin, so disabling it breaks no
chain.

> Searching for this is booby-trapped: grepping recipes for `tin` also matches
> elec**tin**e, and filtering item ids for the Wool **Gin** also matches
> leg**gin**gs. Both nearly produced wrong conclusions.

### Upstream bug fixed here: the deepslate ores could never generate

All six of Exploration's ore features give **both** targets the same tag:

```json
{"state": "ruby_ore",           "tag": "minecraft:stone_ore_replaceables"}
{"state": "deepslate_ruby_ore", "tag": "minecraft:stone_ore_replaceables"}
```

The vanilla ore feature takes the **first** matching target, so the stone
variant always won and the deepslate block was unreachable. Fixed by datapack
override in `kubejs/data/projectred_exploration/worldgen/configured_feature/`
for the four enabled ores, pointing the second target at
`minecraft:deepslate_ore_replaceables`.

Verified two ways. On the server, `/place feature` at Y -40/-44/-48 in a
force-loaded chunk then counted with `/fill ... replace`: **19 deepslate blocks,
0 stone**. And in the ore data, every stone variant now peaks above Y 0 while
every deepslate variant peaks below it.

The ranges overlap at the margins -- stone variants reach Y -40, deepslate ones
reach +53 -- which is correct, not leakage: **tuff is in both** replaceable
tags and tuff blobs straddle the boundary.

> Worldgen fixes only affect chunks generated **after** they land. Install the
> override before pre-generating with Chunky, or the pre-generated area will
> permanently lack deepslate ores.

### Dead content hidden from JEI

`client_scripts/jei_hide.js` hides 34 items: the 16 backpacks, the 12 gem
armour pieces, and **6 basalt blocks**. The basalt is not a duplicate of
vanilla's needing substitution -- it is unobtainable. Nothing generates it
(`MarbleCaveWorldCarver` places marble and never mentions basalt) and no recipe
produces `basalt_cobble`, which the whole chain roots on.

Removing a recipe does not remove the item from JEI's list, so recipe removal
and hiding must be kept in step. If a recipe is restored without dropping the
matching hide line, the item becomes craftable but invisible -- worse than the
problem being solved.

### Tinkers materials: tried, reverted, do not retry

Project Red's gems and electrotine were briefly added as Tinkers materials via
datapack. Reverted on 2026-10-13 for a reason that cannot be engineered around:
**datapack materials cannot be melted or cast**, because fluids can only be
registered by a mod. They have to be `craftable` (Part Builder from the solid
item), which puts them outside Tinkers' progression rather than inside it, and
supplying a casting route would mean authoring a large set of part textures.
The generated part textures also failed to resolve.

Project Red has **no** electrotine gear of its own -- Core ships only dust,
ingot and the silicon/iron compounds -- so electrotine tools and armour are not
available from any mod in the pack.

## Sophisticated Storage: added 2026-11-03, and what is gated

Reverses the old "Backpacks only" rule at the owner's request. Chests, barrels
and shulker boxes in six tiers, limited barrels, a Decoration Table, and the
controller/storage-connector network.

### It forced the whole Sophisticated stack forward

Storage's current build declares `sophisticatedcore [1.5.24.+,)` -- a
**bracketed, enforced** range -- and the pack was on Core `1.5.2.2346`. So this
was never "add one mod":

| Mod | Was | Now | Its Core floor |
|---|---|---|---|
| Sophisticated Core | 1.5.2.2346 | **1.5.24.2453** | -- |
| Sophisticated Backpacks | 3.26.6.2176 | **3.26.19.2239** | `[1.5.21.+,)` |
| Sophisticated Storage | -- | **1.5.15.2220** | `[1.5.24.+,)` |
| Backpacks Create Integration | 0.1.11.173 | unchanged | floors at `sophisticatedbackpacks [3.26.3,)` |

**Treat these three as a matched set, like Tinkers' and Mantle.** The author
ships almost daily -- 233 Storage, 285 Core and 164 Backpacks builds exist for
1.20.1 -- and each release floors on a Core from the same week. Old Backpacks
technically satisfies a new Core because its floor is open-ended, but that is a
floor, not a compatibility promise. Update them together or not at all.

> There was a no-update path and it was rejected: Storage `1.5.0.2137`
> (2026-09-27) floors at `[1.5.2.+,)`, which the old Core satisfied. It would
> have pinned a brand-new mod five weeks behind on a mod that moves this fast.

### Adding Storage does NOT re-enable the disabled backpack upgrades

Checked, because it would have been a silent regression. Storage ships **40
recipes whose output is a `sophisticatedbackpacks:` upgrade** -- including the
stack upgrades this pack deliberately disables -- craftable from storage-tier
materials. Every one of those 40 is gated on the **backpacks** registry name,
not the storage one, so the existing `enabledItems` entries still suppress them.

More broadly: 343 of Storage's 345 recipes carry a
`sophisticatedcore:item_enabled` condition. Only `decoration_table` and
`paintbrush` do not, so those two are always craftable.

### What is off, and why

`config/sophisticatedcore-common.toml` now holds **216 entries, 76 disabled** --
one list covering both mods, because they share Sophisticated Core.

| Off on Storage | Reason |
|---|---|
| `hopper_upgrade`, `advanced_hopper_upgrade` | pulls items in and pushes them out by itself -- one item replacing a Create funnel-and-belt build, which is the pack's standing test |
| `compression_upgrade` | auto-compresses into block form, replacing a Create press/packer |
| all 22 `stack_upgrade_*` | same call already made for backpacks. Storage's ladder is bigger: tier 1 through **5**, a `tier_1_plus`, omega, and a full conversion matrix |
| feeding, magnet, compacting, void, alchemy, auto_smelting/blasting/smoking (+ `advanced_`) | the standing automation list from Pack Philosophy |

**Kept on purpose:** the controller and storage connectors (they organise
rather than automate, and replace no Create or IE build), every tier upgrade
(`basic_to_iron` and friends -- these are the storage equivalent of backpack
tiers), filter, pickup, jukebox, crafting, stonecutter, the manual
smelting/blasting/smoking trio, the seven `chipped/` workbench upgrades, and
all 64 blocks.

### The doc and the config had drifted

Until this change the Pack Philosophy section named pump, magnet, compacting
and void as disabled, while all eight of those entries were `true` in the
shipped config. The doc was taken as authoritative, so **backpacks lost those
eight too** -- players carrying one will find it no longer craftable and gone
from JEI. That was a deliberate call, not an accident.

## Serene Seasons is cosmetic (2026-11-03)

Seasons stay for the look -- grass, foliage and birch colour shifts, seasonal
weather, snow in winter -- but no longer gate farming. One tracked file,
`config/sereneseasons/fertility.toml`:

```toml
[general]
	seasonal_crops = false
	crop_tooltips = false
```

`crop_tooltips` goes with it because it would otherwise lie: the tooltip lists
the seasons a crop is "fertile" in, read from the crop's season tags rather
than from `seasonal_crops`, so it would keep telling players wheat needs spring
when it does not.

### Why a partial file is correct here

Serene Seasons does **not** use Forge's config system. It uses **GlitchCore**
(`glitchcore/config/Config`), which loads the file, replaces anything missing
or invalid with the default -- its own log line is `Invalid value {} for key
{}. Reverting to default` -- and writes the completed file back. So shipping
only the keys actually being changed is valid, and it keeps the diff to the
decision rather than to a wall of defaults. Everything else stays at mod
default by omission.

### Where it lives, and why that matters

`FertilityConfig.getConfigPath()` resolves `sereneseasons/fertility.toml`
against **`FMLPaths.CONFIGDIR`**, so it is `config/sereneseasons/...` -- an
ordinary packwiz-shipped file, overwritten in the container on every start.
This is **not** a per-world `defaultconfigs/` case, so no hand-copying into
`world/serverconfig/` is needed and it applies to the existing world
immediately. GlitchCore also syncs config server -> client
(`glitchcore/config/ConfigSync`), so the server's value is the one that counts.

The companion file is `config/sereneseasons/seasons.toml`, which is
**deliberately not tracked**. Colour shifts, snow and ice, and weather
frequency are all left at their defaults, because those are the parts worth
keeping.

> **"8-day seasons" was a misreading, now corrected.** The option is
> `time_settings.sub_season_duration`, and the jar's own comment is "The
> duration of a **sub season** in days." Serene Seasons has twelve sub-seasons
> (Early/Mid/Late of each season), so three of them make one season --
> whatever the number, it is not days-per-season. The pack ships no override,
> so this is on the mod's default either way.

## Shaped recipe collisions, and how to find them

A player reported on 2026-11-03 that the **Drying Rack cannot be crafted**.
Diagnosis: two shaped recipes with the same *trimmed* grid and the same
ingredients are a conflict. Minecraft trims blank leading and trailing rows and
columns before matching, so Tinkers' Thinking's
`["   ","###","   "]` of `minecraft:wooden_slabs` is **the same recipe** as
Supplementaries' `["###"]`. Only whichever the RecipeManager reaches first can
ever be crafted; the other is silently unobtainable, and **JEI still shows
both**, which is why it reads as a bug rather than a conflict.

> Note the item was **not** Farmer's Delight's. "Drying Rack" is
> `tinkers_thinking:drying_rack`. Searching the obvious mod first wasted a
> step.

### Scan the whole pack, not just the reported pair

Normalise every `minecraft:crafting_shaped` recipe to (trimmed pattern x
per-cell ingredient id) and group. Any group with more than one distinct result
is a conflict. On 2026-11-03 that found **five**, from 4702 shaped recipes:

| Grid | Ingredient | Colliding outputs |
|---|---|---|
| `###` | `minecraft:wooden_slabs` | `supplementaries:item_shelf` vs `tinkers_thinking:drying_rack` |
| `#/#` | `forge:cobblestone` | `cb_microblock:stone_rod` vs `tinkers_thinking:stone_stick` |
| `#/#/#` | `minecraft:bamboo` | `mcwwindows:bamboo_shutter` vs `supplementaries:flute` |
| `##/##` x2 | railways locometal | two Steam 'n' Rails hazard stripes, **left alone** |

**Hash the jars against `mods/*.pw.toml` first.** A naive walk of the packwiz
cache scans jars that are no longer in the pack -- the first run of this
reported a sixth conflict involving **Create Deco**, which was removed months
ago. Match `hash-format = "sha512"` for Modrinth entries and `"sha1"` for the
11 CurseForge ones; all 120 resolve.

### The three that were fixed, and which side was changed

Changing *either* side fixes a conflict, so the choice is about which recipe is
least surprising to alter. Overrides live in `kubejs/data/` at the **exact jar
path**, with a `__comment` key as the existing overrides do.

| Changed | New grid | Why that side |
|---|---|---|
| `tinkers_thinking:drying_rack` | 3 slabs **vertical** | the known loser, and Supplementaries' item shelf keeps its documented recipe |
| `tinkers_thinking:stone_stick` | 2 cobblestone **horizontal** | `cb_microblock:stone_rod` feeds **Project Red's four saws**, a progression item; Tinkers' Thinking is the smaller addon. Both matter -- stone_stick feeds its stone torch, soul torch, ladder and the rock tool material, so one of those chains was blocked |
| `supplementaries:flute` | 3 bamboo **horizontal** | every Macaw's shutter is three of its material stacked vertically; breaking that for bamboo alone would confuse a set players craft repeatedly, while the flute is a one-off. Its `supplementaries:flag` condition is preserved verbatim |

Every replacement keeps the same materials and output count, and each new grid
was checked against every other single-ingredient pattern in the pack first.

### The two left alone

Steam 'n' Rails ships `hazard_stripes_a` and `hazard_stripes_b` folders holding
mirror arrangements, so `a/black_on_white` produces the same physical grid as
`b/white_on_black`. Purely decorative, upstream, and confined to the
black/white combination. Fixing it would mean breaking the systematic a/b
pattern the rest of that large family follows, which is worse than the bug.

### Re-run after adding mods

This is a whole-pack property: any new mod can collide with an existing one,
and nothing warns you. Re-run the scan after a mod add, and check that the
`kubejs/data/` override paths still **replace** a real jar file rather than
landing as new files -- a path that stops matching turns the fix into a
silently-ignored extra recipe.

## Armor Visibility: hiding armour, client-side only

Added 2026-11-04 on a player request. Keybind-driven toggle with three states
(visible / all armour hidden / own armour hidden), per-slot switches for
helmet, chestplate, leggings and boots, and options to keep the elytra and cape
visible and to leave mobs and armour stands alone. No gameplay effect at all --
it changes rendering, not stats.

`armor_visibility` is `side = "client"` by platform metadata, which is correct.
It pulls in **Ash API** (`ash_api [3.0.0,)`, bracketed and enforced), a
Fabric/Forge abstraction layer, which packwiz infers as `side = "both"`.

That was checked rather than accepted, because shipping a client library to a
dedicated server is exactly how JEARGH crash-looped it. Ash API is safe: its
`@Mod` entry class `com/diontryban/ash/AshForge` references no client package,
and nothing anywhere in the jar touches `IntegratedServer`. One class,
`impl/resource/ResourceLoaderImpl`, references `net/minecraft/client/Minecraft`
without a dist guard, but it is only loaded if something calls the resource
API, and on the server nothing does -- Armor Visibility is not installed there.
Left at `both` rather than hand-set, since nothing is actually broken and the
"do not hand-set side" rule stands.

## Restarts: no mod required

Verified 2026-10-11 by running it.

**`/stop` is already a restart.** The container runs `restart: unless-stopped`,
so a clean stop exits Java with code 0 and Docker starts it again -- back up in
under 5 seconds. There is no `/restart` command in vanilla or Forge, which is
why that did not work in game; `/stop` as an operator is the one to use. No
server-side utility mod is needed for either scheduled or manual restarts, and
none was added.

**Scheduled restarts are the bot's job (since 2026-11-05).** An administrator
sets them in Discord with `/ia config restart time:05:30` (`warn:15,10,5,1`
is the default). The bot warns online players in game, waits for a running
backup, stops pre-generation, sends `stop`, and reports to the audit channel
how long the server took to come back. It is **off until someone sets a time**,
and as of 2026-11-05 nobody has. The design record is in the bot's handover,
"Daily restart".

`server/scripts/auto-restart.sh` is the fallback for when the bot is down. It
warns players (default 15/10/5/1 minutes), saves, then stops, and lets Docker
relaunch. It skips the countdown when nobody is online, and `--now` skips it
entirely. It was the **first of the server scripts to have actually been
executed** rather than only syntax-checked, and it ran clean end to end, exit 0.
It was never put in a crontab on the host. Do not add one while the bot's
schedule is on, or the server restarts twice.

The player-count parser reads `There are N of a max of M players online`, and
deliberately assumes players ARE online if that reply cannot be parsed -- the
failure mode to avoid is silently skipping warnings on a populated server.

**`PACKWIZ_URL` makes every restart a pack update, which scheduled restarts turn
into a hazard.** Pointed at a branch head, an unattended 5:30am restart installs
whatever was last pushed, including half-finished work. Once friends depend on
the server, point it at a release tag:

```
PACKWIZ_URL=https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/v2.1.1/pack.toml
```

Tags are immutable, so restarts become reproducible and updating becomes a
deliberate `.env` edit followed by `docker compose up -d` -- **not `restart`**,
which reuses the existing container with its old environment and would silently
ignore the new tag.

**Done on 2026-11-04.** `server/.env.example` is pinned to `v2.4.0`, verified
first: the tag resolves to `b8a2fd0`, which is `main`'s head, and
`raw.githubusercontent.com` serves that `pack.toml` at HTTP 200 with
`version = "2.4.0"`. The live `server/.env` is gitignored, so it has to be
changed by hand on the host.

> One consequence worth knowing: **the 5-minute CDN cache stops mattering for
> normal updates.** A tag's content never changes, so there is no stale version
> to race. The warning still applies the moment anything points back at a
> branch.

> **Verify a tag before pinning to it.** An early attempt produced one that
> pointed at the wrong commit: `gh release create` without `--target` tags
> the **default branch's head**, so a release built from `2.0` tagged `main`,
> and `v2.1.0` resolved to a v1.2.3 / NeoForge commit. Pinning `PACKWIZ_URL`
> to it would have installed the v1 pack at the next unattended restart. The
> Release's attached artifacts were correct, built from the right checkout,
> which is what made it easy to miss. `publish.yml` now passes
> `--target "$GITHUB_SHA"`, and the bad release and tag were deleted. So pin
> only after a post-merge version bump produces a verified tag -- and check it
> with `git rev-parse <tag>` plus `git show <sha>:pack.toml` before trusting it.

### A stop must outlive Docker's 10-second kill (2026-11-05)

Reported from 2.4.0: after a crash or an update, **inventories were kept but
the world rolled back**, so placed blocks were simply gone. Minecraft's
shutdown saves **players first, chunks second** (`Saving players`, then
`Saving worlds`, then `All dimensions are saved`). Docker SIGKILLs a container
10 seconds after asking it to stop. Any kill between those two log lines
produces exactly that asymmetry. Moved-into-chest items vanish the same way,
and taken-out-of-chest items duplicate.

Every non-RCON stop went through that window: `stop.sh` (`docker compose
stop`), `restart.sh` (`docker compose restart`), `down`, and every update,
because `up -d` recreates the container. `auto-restart.sh` and in-game `/stop`
were never exposed, because Java exits on its own and the restart policy does
the rest.

Fixed in `server/docker-compose.yml`: `stop_grace_period: 3m`, with the image's
`STOP_DURATION: "150"` below it, because itzg's wrapper kills Java itself once
`STOP_DURATION` (default 60s) runs out. `stop.sh` and `restart.sh` now
`save-all flush` first so the shutdown save is small, and `stop.sh` reports
exit 137 instead of announcing that the world is safe.

**This was not what happened on 2.4.0.** The server's logs, read on
2026-11-05, show every lost run ending in a **host OOM kill** (next section),
and none in a stop that ran out of time. The fix stands because the window is
real. The **first** `up -d` after pulling this change must be preceded by
`docker compose stop -t 180`, because the container being replaced still
carries the old 10-second limit.

**Live on the host since 2026-11-05.** It was stopped with `-t 180` (3 s,
exit 0, `Stopping server` then `All dimensions are saved` in the log), moved
to `main`, and started with `up -d`. `docker inspect` now reports
`StopTimeout=180`. The local Docker Desktop server still needs the same
one-time `stop -t 180` before its first `up -d` on this compose file.

> Counting `All dimensions are saved` per log, which this section originally
> recommended, **does not work**: the line is also printed about a minute after
> every boot, so a killed run scores 1. Count `Stopping server` instead.
> `server/README.md` has the corrected one-liner.

### The rollbacks were the host OOM-killing Java (confirmed 2026-11-05)

Read from the server machine, read-only. **Every run after the 2.4.0 update at
10:31 on 2026-11-04 ended in a SIGKILL.** No rolled log since then contains
`Stopping server`, and each one ends 20-40 seconds before a line like this in
the **host's** kernel log:

```
Out of memory: Killed process 2886128 (java) total-vm:17063452kB, anon-rss:12643528kB
```

Eleven since 2026-10-04, **eight of them on 4-5 November**: 14:30, 15:02, 15:24,
16:00, 16:42, 17:24 and 19:52 on the 4th, and 07:50 on the 5th. That is roughly
every 40 minutes of play.

**Why.** The live `.env` runs `INIT_MEMORY=8G` and `MAX_MEMORY=12G` (the repo
default is 6G) on a 15 GiB host that is also a desktop. Firefox alone was
3.2 GB on 2026-11-05. Java's resident size is the heap plus about 1.3 GB (9.3 GB
at an 8 GB heap), so a 12 GB heap was 12.4-13.0 GB at each kill. `sar` (sysstat
is installed) shows swap at 51% with nobody on. Whenever players were on it
climbed to 98-100%, with 250-800 MB available, and every kill sits at one of
those peaks. Swapping the heap is also the lag: killed runs lost 25-33% of
their wall time to `Can't keep up!`, with single stalls of 15-32 s.

**Why players were kept and blocks were not.** A kill saves nothing. Each
player's file is written whenever that player logs off, and the logs show
constant relogs. The world is written only at the autosave, every 6000 ticks.
At the measured tick rate that was every 6-8 minutes of real time, which
matches the "10+ minutes" lost.

**What Docker shows is misleading.** `OOMKilled` stays `false`, because it only
reflects a container memory limit and this stack sets none. `ExitCode` and
`RestartCount` reset with the automatic restart, and no crash report is
written. The kernel log is the only record, and `journalctl -k` covers one boot
at a time (`-b -1` for the previous).

**Fixed on 2026-11-05, on the owner's instruction:** `MAX_MEMORY` 12G -> 8G
in the live `.env`, with `INIT_MEMORY` left at 8G. Java's command line now
carries `-Xms8G -Xmx8G` (through `user_jvm_args.txt`, so `ps` on the host only
shows `@user_jvm_args.txt`). It sat at 8.97 GB resident after boot, with 2.8 GB
available on the host and swap empty.

`VIEW_DISTANCE` was **left at 24**, because the owner raised it on purpose.
It is the next lever if lag or memory pressure come back. The cost is
quadratic: 2401 chunks per player at 24 against 625 at 12, all generated as a
player explores. The first busy evening is the real test: `sar -r -S` the next
morning should show swap nowhere near 100%, and `journalctl -k | grep 'Killed
process'` should be empty.

Also from the same read:

- **The host froze at about 09:13 on 2026-11-05**, and the owner power-cycled
  it at 09:19 when keyboard, mouse and power button got no response. **It was
  not asleep.** GNOME's automatic suspend is off
  (`sleep-inactive-ac-timeout 0`), the screen only blanks after 5 minutes
  (`idle-delay 300`), and no boot in the journal contains a suspend. A blank
  screen on a hung machine looks exactly like sleep. The evidence for a
  freeze: the 09:20 `sar` sample was never written, Minecraft's watchdog
  killed the server at 09:13 (one 60-second tick, no crash report), systemd
  aborted a stuck `snapd` at 09:18, and journal timestamps arrive out of order.
  **Memory does not explain this one.** At 09:10 there was 1.9 GB available,
  swap was steady at 77%, and paging was idle. The Wi-Fi driver is the main
  suspect but not proven. `rtw88_8821cu` logs `failed to get tx report from
  firmware` all morning, and at the end its deauth requests were failing.
  The power cycle booted kernel 7.0.0-42 (it had been -38). If it happens
  again, `journalctl -k -b -1` right after the reboot is the first read, and a
  wired connection is the real fix.
- **The Wi-Fi drops 20-140 times a day** (`CTRL-EVENT-DISCONNECTED reason=4`).
  Expected, per the owner: the machine sits at the edge of the modem's range.
  Most drops are brief. The one `Couldn't verify username because servers are
  unavailable` in the logs is from the 09:13 freeze. Wi-Fi power saving is on
  for the dongle (`iw dev wlx1cbfce2251d6 get power_save`). The connection is
  on NetworkManager's default, which Ubuntu's `default-wifi-powersave-on.conf`
  sets to 3 (on). The owner turns it off with sudo, per connection:
  `sudo nmcli connection modify "SPARK-SZX7GC-5G" 802-11-wireless.powersave 2`
  then `sudo nmcli connection up "SPARK-SZX7GC-5G"`. The driver's own deep
  power save (`rtw88_core disable_lps_deep`) is still `N`. Setting it to `y`
  in `/etc/modprobe.d/` is the next step if the firmware errors continue.

## Player reports from 2.4.0 (2026-11-05)

Diagnosed by reading jars, and none needed a pack change, so **there was no
2.4.1 release**. Shipping identical content under a new version would only
make every player re-import, which itself costs them their map (see below).

**"Trees don't grow outside their biomes" is Serene Seasons, and 2.4.0 already
turns it off.** SS tags every vanilla sapling to seasons (jungle and acacia
summer only, dark oak autumn only), and `ModFertility.isCropFertile` treats
**`#sereneseasons:tropical_biomes` as permanent summer**. So a jungle sapling
grows in a jungle all year and elsewhere only in summer, which looks exactly
like a biome lock. `SeasonalCropGrowthHandler.onCropGrowth` and
`applyBonemeal` both return immediately when `seasonal_crops` is false,
verified in 9.1.0.3 bytecode. So the 2.4.0 config fixes it, **provided the
server is actually running 2.4.0**. Check
`grep seasonal_crops /data/config/sereneseasons/fertility.toml` before
investigating further. Dark oak and the giant spruce/jungle variants still
need a 2x2 of saplings, which is vanilla.

**Checked on the server on 2026-11-05: `seasonal_crops = false` is live.**
GlitchCore had written its own defaults back into the file, which proves it
loaded it. So the follow-up report, "four dark oak saplings will only grow in
a dark forest, even with bone meal", is **not** Serene Seasons. Nothing else in
the pack touches it either. No jar overrides
`worldgen/configured_feature/dark_oak.json`, and the six that ship
`replaceable_by_trees` tags (Farmer's Delight, Tinkers', Alex's Caves, Chipped,
Deep Aether, Twilight Forest) only *add* blocks, which makes growth easier.
Vanilla dark oak needs about 10 clear blocks above the 2x2, and nothing solid
within 1 block of the trunk or within 2 near the top. A torch, fence, roof
or a neighbouring tree's trunk is enough to stop it. Bone meal only works 45% of
the time, and the first success just advances the sapling a stage. When there is no
room it is still consumed, with no message. Open ground in a dark forest passes
those checks, and a base usually does not.

**"Items don't despawn" is simulation distance, not a mod.** Nothing in the
pack disables despawning globally. Scanned for `ItemExpireEvent`,
`getEntityLifespan`, `ItemEntity.age` (`f_31985_`) and `ItemEntity` mixins.
Items only age in entity-ticking chunks: 4 chunks around a player at the
repo's `SIMULATION_DISTANCE=4`, or 8 on the live server, whose `.env` raises it.
Leave and the timer freezes. The real
exceptions are deliberate:

| Source | Behaviour |
|---|---|
| Tinkers' `IndestructibleItemEntity` | lifespan `Integer.MAX_VALUE`, set by the `netherite`, `reclaim` and `worldbound` modifiers |
| Botania `ItemEntityMixin.disableDespawn` | only for items in `BotaniaItems.isNoDespawn` |
| Open Parties and Claims `MixinItemEntity` | blocks *merging* stacks from different throwers. Does not affect despawn |

**"Explored map resets on update" is the client, not the container.**
Xaero's World Map identifies the server's world by a level id in
`world/xaeromap.txt` (`CommonEvents` resolves it against the world save), so it
lives in the volume and survives rebuilds. Map data, though, sits in the
**instance** folder (`xaero/world-map/Multiplayer_<address>/`), and the install
docs told players to import every release as a new instance. The Modrinth App
names it `Iron.Arcana-<version>`, so each update is a blank map. The docs now
say to copy `xaero/` across, and the packwiz-bootstrap route avoids the
problem entirely. Maps are also filed **per server address**. As of
2026-11-04 the host connects as `Garage-server_wireless` (192.168.1.69) while
players use `minecraft.wrenchintheworks.online`, so those are two separate maps.

**"Failed to verify username" is Mojang, made worse by the crashes.** It is the
vanilla `multiplayer.disconnect.unverified_username`: Mojang's `hasJoined`
returned no profile. The server log, read on 2026-11-05, settles which case:
every instance but one is `Username 'X' tried to join with an invalid session`,
meaning Mojang had no record of the client's join. The exception is a single
`Couldn't verify username because servers are unavailable`, from the host's
09:13 network outage. So this is not the host's network, and not the bot. It
does **cluster after each OOM restart**, when all players reconnect at once.
After the 16:00 restart on 2026-11-04, one player made a dozen attempts in two
minutes, mostly abandoned mid-login, before one got through. On a stable run it
appears only now and then, and a retry works. Stopping the kills removes most
of it, and nothing on the server can remove the rest.

### Overnight pregen lives in the bot, driving the pack's Chunky

Built on 2026-11-05 in the bot repo, branch `feat/chunky-pregen` (not yet
merged or deployed): `pregen.py`, `/ia mod pregen-status|pregen-now|pregen-stop`
and a nightly schedule that is off by default. An administrator sets it from
Discord with `/ia config pregen`; the `PREGEN_*` values in the bot's `.env`
are only defaults. The pack needed **no
change**. Chunky was already in it, and the bot reads region files through its
existing read-only mount. The design record is the bot's handover, "Overnight
pre-generation".

The one fact the pack side should keep in mind: the bot counts a chunk as
explored only when **`InhabitedTime > 0`**, so its own pregenerated ring never
seeds the next night's. Anything that bulk-touches chunks with players nearby
would change that picture, for example a chunk loader parked at the frontier.

`Chunky-1.3.146`, `side = both`. Read out of the jar while designing it:

- `GenerationTask` calls `World.isChunkGenerated` before generating, so a
  selection overlapping explored land costs only its new chunks. That makes
  "a few rectangles around the frontier" cheap.
- Patterns include `csv` (`chunky pattern csv <name>`, one `x,z` chunk per
  line). It needs a file inside the server's config dir, though, and the bot's
  mount is **read-only by design** (bot handover S5). The RCON-only route is
  `chunky world` + `chunky shape rectangle` + `chunky corners`, run one task at
  a time.
- Completion logs `Task finished for <world>. Processed: ...`, which the bot's
  log tail can wait on before starting the next rectangle. A second
  `chunky start` on a busy world asks for confirmation rather than queueing.

**Pregenerated chunks freeze the worldgen they were made with.** The Project Red
deepslate fix rule applies to every future worldgen mod too, so keep the ring
modest rather than pregenerating far ahead.

**The host's memory was fixed on 2026-11-05** (see "The rollbacks were the
host OOM-killing Java"). Before that it swapped to 100% under three players,
and an unattended Chunky run would have added to it. That blocker is gone, but
the branch is not deployed: test it against the local server first, as for any
bot change, and watch `sar -r -S` the morning after its first night.

## The Discord bot — what the pack has to know about it

The pack ships **no Discord mod**, and that is a decision, not an omission.
Discord Integration was removed once the bridge design was settled. The bridge
lives entirely in the **Wrench's Toolkit** bot, which tails
`/data/logs/latest.log` for Minecraft -> Discord and sends RCON for
Discord -> Minecraft.

Two reasons it is not a mod. DI needs its own second Discord bot application,
and its `[[commands]]` system has no role or permission gating at all --
verified in the 2.2.3 jar, where `CommandConfig` carries only
`minecraft_command`, `discord_command`, `description`, `use_parameters` and
`enabled`, with a single `channel_id` shared by chat and commands -- so
privileged commands could not be restricted to moderators. Keeping it out also
means the pack stays fully playable with no bot, which matters because the pack
is published for anyone to use.

The bot repo is `wrenchInTheWorks/wrenchs-toolkit-discord-bot`, checked out at
`Documents\Git\Wrench's Toolkit` -- **private**, so do not link it from this
repo's public docs. Its `IRON_ARCANA_HANDOVER.md` is the design record and is
more current than this file on bot-side matters.

### Whitelisting is self-service, and that changes a server rule

`/ia whitelist <username>` resolves the name against Mojang, calls
`whitelist add` over RCON, and records the Discord-to-UUID link only **after**
the server accepts. `whitelist.json` stays the single source of truth; the bot's
table records who claimed what. One Minecraft account per Discord user, enforced
by a `UNIQUE` index as well as a pre-flight check; re-running with a new name
removes the old entry before adding the new one. Rate limited to two uses per
ten minutes.

The gate is a role set with `/ia config whitelist-role`, and **unset means
closed, not open**. On this server it is deliberately set to `@everyone`, so
anyone who can see the guild can whitelist themselves with no admin involved.

> **Never set `OVERRIDE_WHITELIST=TRUE` (or `OVERRIDE_OPS`) in `server/.env`.**
> The image defaults to `MERGE`, which is the only reason bot-added players
> survive a restart. `SYNCHRONIZE` prunes everyone not named in the `WHITELIST`
> variable, so every self-whitelisted player would silently lose access at the
> next scheduled restart -- and scheduled restarts are unattended. Confirmed
> both ways on 2026-10-12. `server/.env.example` and `server/docker-compose.yml`
> both carry this warning; it is load-bearing, do not tidy it away.

**The bot must run on the same host as the server.** Tailing a log file is not
remote-capable, and RCON's port is deliberately unpublished, so co-location is a
hard requirement of the Linux migration, not a preference.

## Distribution: two artifacts, and what the CurseForge one costs

Every release carries both, built by `publish.yml` from the same commit:

| Asset | Route | Size at 2.4.0 |
|---|---|---|
| `Iron.Arcana-<v>.mrpack` | Modrinth App, Prism, ATLauncher | 178 MB |
| `Iron.Arcana-<v>.zip` | CurseForge launcher | 421 MB |

GitHub rewrites the spaces and `&` in the pack name, so the assets are
`Iron.Arcana-...`, **not** `Iron & Arcana-...`. Anything that hardcodes the
filename gets this wrong -- the README did.

The `.zip` is twice the size because of how packwiz splits it. Re-measured
after adding Sophisticated Storage (2026-11-03): **11** mods resolve as
CurseForge manifest entries (the MineColonies stack, Twilight Forest, Illager
Invasion, TownTalk, Json Things, Puzzles Lib), **104** client-side jars are
bundled into `overrides/mods/`, and **5** are correctly absent as
`side = "server"` (BlueMap, Noisium, YUNG's x3). 11 + 104 + 5 = 120.

Re-run the export and recount after any mod change -- these numbers appear in
`README.md` and `docs/discord-welcome.md` too, and a find-and-replace on the
total silently leaves the split wrong.

**So the CurseForge launcher warns about 104 mods it did not serve and makes the
player approve them.** That is inherent to a Modrinth-first pack imported into
CurseForge, not a fault, but it looks alarming to someone installing their first
pack -- `docs/discord-welcome.md` pre-empts it explicitly. Prefer the `.mrpack`;
it is the route the pack is developed and tested on.

## Durable Technical Notes

### Recipe removal pattern
```js
// Removes ALL recipes producing an item (main + alternates + cross-conversions):
event.remove({ output: 'mod:item_id' })
// Better than event.remove({ id: 'recipe_id' }), which only removes one.
```

### Tag definedness
An **undefined** tag and an **empty** tag behave differently. A mod calling
`tag.isEmpty()` sees `true` for an undefined tag and `false` for one that exists
with no values. Any workaround relying on "exists but empty" must actually
declare the tag file.

### KubeJS data folder
`kubejs/data/` acts as a datapack overlay and overrides JSON from mod jars. It
is validated at **server startup only** — `/kubejs reload` only reloads
`startup_scripts/` and `server_scripts/`. Full restart for data changes.

### Session lock
A file-lock `IOException` on startup means a stale `world/session.lock` from an
unclean kill. Delete it.

### Almost Unified: an intermittent, harmless-looking tag NPE

Seen once in seven boots (2026-10-11), on an async worker during tag reload:

```
NullPointerException: ... "TagReloadHandler.RAW_ITEM_TAGS" is null
  at TagReloadHandler.findDominantItemHolder -> applyInheritance
  -> AlmostUnified.loadReplacementData -> onTagLoaderReload
```

It is a race inside Almost Unified 1.20.1-0.11.0, **not** caused by anything
added to the pack -- the stack trace contains no frames from any other mod.
It first appeared on the boot that added JEI, which is coincidence, not cause.

**Impact appears to be nil.** On the erroring boot the unification still
completed with counts identical to every clean boot (19703 -> 19663). Only the
tag-inheritance step failed. If it ever does matter, the fix is a restart.

Do not chase this as a symptom of a pack change. The per-boot evidence is
`docker compose logs | grep -E 'Recipe count( afterwards)?:'` -- a boot that
unified correctly prints both lines with the usual counts.

Separately, Almost Unified logs a very long "the following tags are invalid and
will be ignored" list (~400 `forge:` tags for materials from mods this pack does
not have, e.g. thermal/mekanism metals). That is its default config being
broader than the pack and is harmless noise.

### Java 17 is a hard ceiling — BlueMap is pinned because of it
Forge 47 / 1.20.1 targets **Java 17** (class file major 61). A mod compiled for
Java 21 (major 65) throws `UnsupportedClassVersionError` at class load.

**BlueMap is deliberately pinned to `5.3-forge-1.20` (version id `aHbq9KFB`).**
BlueMap 5.12 is compiled for Java 21 and crash-loops the server. Measured class
majors: 5.12 = 65 (Java 21), 5.3 = 60, 3.21 = 55. 5.3 is the newest that runs on
Java 17.

**Do not `packwiz update` BlueMap** without re-checking the class version, and
do not switch the container to `java21` casually — Forge 47 does not officially
support it and the pack is mixin-heavy.

**The pin stays even though Valkyrien Skies is gone.** VS was what turned this
into a hard crash — its `LoadedMods.getBluemap()` called `Class.forName` during
mixin selection, forcing the class to load before anything could catch it. With
VS removed a Java-21 mod might only fail softly, but the Java 17 ceiling is
unchanged and an unloadable BlueMap is still a broken BlueMap.

To check a jar: read bytes 6–7 of any `.class` inside it (big-endian major
version), or see the BlueMap investigation in git history for the script.

### Create addon compatibility — and why a declared range can lie
Every Create addon in the pack declares a **hard** `create >= 6.0.x` bound, so
Create 6.0.8 satisfies them. Read `META-INF/mods.toml` out of the jar to check —
`dependencies` in the Modrinth API are unpinned and tell you nothing.

**A bare `versionRange` is not a bound.** Forge parses it as a Maven version
spec, where `"6.0.2"` means "recommended, anything acceptable" — so Forge loads
the mod against *any* Create version without complaint. Only bracketed ranges
(`[6.0.7,)`) are enforced.

This cost a boot. Create Deco `2.0.3` declared a bare `create = "6.0.2"`, was
actually built for the Create 0.5.1 era, loaded silently against 6.0.8, and
disrupted Create's Registrate registration — Create then died in
`AllAdvancements.<clinit>` with `Registry entry not present:
create:chocolate_bucket`. Create Deco's Create-6 line (2.1.x) never shipped for
1.20.1 Forge, only 1.21.1 NeoForge and 1.20.1 Fabric.

**So: check the addon's version *line* against Create's, not just its declared
range.** If Create is ever bumped, re-read every addon's mods.toml and treat a
bare range as unverified.

> The old "Forge floor 47.2.0" note came from Valkyrien Skies and is moot now
> that VS is removed. 47.4.10 remains the pinned Forge build regardless.

---

## Pack Philosophy

A **small private friend server** (~4–8 players) distributed over GitHub. Not a
public pack, and no longer constrained by Modrinth's rules.

- **Tinkers' Construct is the gear progression system.** Silent Gear was removed
  in 2.0 — its default traits were weak and its Materials Book advertised
  materials from absent mods. Do not reintroduce Silent Gear, and do not add a
  third gear mod.
- **Progression matters.** Automation shortcuts that bypass Create/IE gameplay
  are disabled deliberately. Players build factories. The test for any upgrade
  or storage feature: **if a single item replaces a Create or IE build, turn it
  off.** In v1 that meant stripping 29 Sophisticated upgrades via KubeJS; in 2.0
  it is done in Sophisticated Core's config instead.
- **Storage is Sophisticated Backpacks and Sophisticated Storage**, both gated
  through Sophisticated Core's `enabledItems`. Storage was added on 2026-11-03,
  reversing the earlier "Backpacks only" rule — see "Sophisticated Storage"
  below for what is off and why.
  The upgrades to disable are the automation ones: feeding, inception,
  everlasting, pump, magnet, compacting, void, auto_smelting, auto_blasting,
  auto_smoking, alchemy, and their `advanced_` variants — plus, on Storage only,
  hopper, compression and every stack upgrade. Keep the manual ones — filter,
  sort, pickup, deposit, restock, tank, battery. **Stack upgrades are off on
  both.**

  > The doc and the config had drifted apart here. Until 2026-11-03 this list
  > named pump, magnet, compacting and void, but all eight of those entries
  > were `true` in the live config. The doc was taken as authoritative and the
  > config corrected, so the two now agree. If they ever disagree again, the
  > config is what players actually experience — check it first.
- **No flight/airship mod.** Create Aeronautics has no 1.20.1 release;
  Valkyrien Skies + Clockwork were added and then removed as too advanced and
  off-theme for this pack. Do not reintroduce them unasked.
- **Colony is a core pillar.** MineColonies with multiple style packs. Don't add
  mods that fight colony chunk claims or building placement.
- **Magic is secondary.** Ars Nouveau and Botania are present; the pack leans
  tech. Check synergy before adding more magic.
- **No entity-animation pack.** Fresh Animations, plus Entity Model Features
  and Entity Texture Features which drove it, were added and then **removed on
  2026-10-10** after the first test playthrough: mob rendering lagged badly.
  ETF/EMF are the per-entity cost, not the resource pack, so all three went.
  `options.txt` existed only to enable Fresh Animations and was removed with
  them. Do not reintroduce them for looks without re-testing mob-heavy scenes.
- **Seasons are cosmetic, not a farming mechanic.** Serene Seasons is kept for
  the colour, weather and snow; `seasonal_crops` is off. If a mod is ever added
  that reads Serene Seasons' crop tags, check it does not reintroduce the
  gating by its own route.
- **Performance is a real constraint.** BlueMap, MineColonies AI and Create
  contraptions are the known cost centres — see `docs/SERVER_PERFORMANCE_NOTES.md` (v1-era, still directionally right)
  before adding heavy server-side mods.
- **One recipe viewer: JEI.** EMI was the pack's viewer through 2.0 and was
  removed on 2026-10-11 -- every major mod here is JEI-native and none support
  EMI, so EMI could list their recipes but not draw them correctly. Do not add
  a second viewer.
