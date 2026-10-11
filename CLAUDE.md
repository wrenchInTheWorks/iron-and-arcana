# Iron & Arcana — Claude Handover Document
**Forge 1.20.1 | v2.1.0 (branch `2.0`, not yet on `main`) | Small private friend server**

---

## Pack Identity

| Field | Value |
|---|---|
| Name | Iron & Arcana |
| Version | 2.1.0 |
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
| `mods/*.pw.toml` | one metadata file per mod (111 entries, 11 CurseForge-sourced) |
| `server/` | Docker deployment — compose file, `.env.example`, README |
| `server/mods-override/` | jars packwiz-installer cannot fetch |
| `docs/v1-mod-inventory.md` | v1.2.3 snapshot + per-mod 2.0 disposition |
| `C:\Users\email\Desktop\I&A MC Server\` | **legacy** v1 test server — superseded by Docker; still holds the un-ported KubeJS scripts |

---

## Key Workflows

```bash
# After any pack change:
packwiz refresh

# Local export check (CI does this too):
packwiz modrinth export
packwiz curseforge export

# Server: PACKWIZ_URL means restart == update
cd server
docker compose restart
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
| Docker server | `server/` — itzg image, `PACKWIZ_URL` self-install (`bae071e`) |
| Infra stripped | EventBridge and all Modrinth publishing removed (`2db8bf6`) |
| Discord mod removed | DI dropped, 112 -> 111 mods. The bridge is bot-side (log tail + RCON), so the pack needs no Discord mod and stays playable with no bot |

### Not done yet

1. **Linux migration.** The runbook is in `server/README.md` ("Moving the
   server to another host"). Only `world/` moves (~40 MB of the ~890 MB volume);
   mods re-download, BlueMap re-renders, `config/` ships from the repo. The two
   things that do not survive on their own are `world/serverconfig/` (23
   per-world Forge configs, including the backpack slowness nerf, which
   `defaultconfigs/` will NOT reseed into an existing world) and `.env`, which
   is gitignored.
2. **Backups.** `server/scripts/backup.sh` exists and is syntax-clean but has
   never been run. The restore path is the migration path, so the migration is
   also the first real test of it.
3. **Cloudflare exposure.** Port-forward 25565, a `cloudflare-ddns` container,
   DNS-only A record plus SRV, and a Tunnel for BlueMap only. No CGNAT (public
   IP confirmed, gateway 192.168.1.254).
4. **Config tuning** after some playtime. Serene Seasons stays at 8-day seasons.
5. **Merge `2.0` into `main` and cut the 2.0.0 release** -- deliberately last.
   The owner wants this only once the Linux host is running and has been played
   on for a while.

### Version and branch state

**The pack version is `2.1.0`; the branch is still called `2.0`.** The branch
name is just a name -- do not rename it or assume the version matches it. 2.1.0
marks the state after the first test playthrough: JEI as the viewer, Fresh
Animations removed, Deep Aether + Treasure Reforging, More Red, Tinkers
Reforged, JER + profiler.

**It moves to `main` when the server goes public for friends**, not before.
That is the owner's gate, not a technical one.

Sequencing agreed 2026-10-11: the merge waits until after the singleplayer
test run and the JEARGH profile, so `world-gen.json` is committed to `config/`
*before* `main` is advanced. The merge itself is a clean fast-forward --
`origin/main` -> `ab1a28c` -> ... -> branch head, no divergence -- and
`ab1a28c` (the v1.x closeout commit, which looks unpushed on local `main`) is
the merge-base of `2.0`, so it arrives with the merge and needs no separate
handling. Flip `PACKWIZ_URL` and the README client route to `main` as part of
the same change.

Bumping the version is what cuts a release: `publish.yml` runs `gh release
create "v<version>"` whenever `pack.toml`'s version changes, on `main` *and*
`2.0`. Pushing 2.1.0 did produce a v2.1.0 Release, but **it was deleted on the
owner's instruction** because its tag was wrong (see below), so `pack.toml`
currently reads 2.1.0 with no release or tag of that name.

A consequence to plan around: CI releases on a version *change* between
commits, so merging `2.0` into `main` will **not** cut a release -- the version
is the same on both sides of the merge. Getting a correctly-tagged release off
`main` needs a version bump after the merge.

### Branch trap: `main` still serves v1

Until that merge happens, **`main` serves v1.2.3 (1.21.1 / NeoForge 21.1.228)**
and the newest GitHub Release is v1.2.3. Neither can join the 1.20.1 Forge
server. So:

- `server/.env` and `.env.example` point `PACKWIZ_URL` at the **`2.0`** branch.
- The root `README.md` client auto-update route points at **`2.0`** too. It was
  pointing at `main`, which silently handed players the 1.21.1 pack.
- The newest GitHub Release is **v1.2.3** again. A v2.1.0 release existed
  briefly on 2026-10-11 and was deleted along with its tag, because the tag
  pointed at the wrong commit. Until a post-merge version bump cuts a new one,
  friends get the `.mrpack` from the maintainer directly.
- **Flip both URLs back to `main` as part of the merge.**

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

The **Ars Nouveau ritual** tab and the **Jumbo Smelting** tab draw magenta
missing-texture boxes where a progress bar belongs. Confirmed cosmetic: the
recipes themselves are correct.

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

## Restarts: no mod required

Verified 2026-10-11 by running it.

**`/stop` is already a restart.** The container runs `restart: unless-stopped`,
so a clean stop exits Java with code 0 and Docker starts it again -- back up in
under 5 seconds. There is no `/restart` command in vanilla or Forge, which is
why that did not work in game; `/stop` as an operator is the one to use. No
server-side utility mod is needed for either scheduled or manual restarts, and
none was added.

**Scheduled restarts are a cron job, not a mod:**
`server/scripts/auto-restart.sh` warns players (default 15/10/5/1 minutes),
saves, then stops, and lets Docker relaunch. It skips the countdown when nobody
is online, and `--now` skips it entirely. This is the **first of the server
scripts to have actually been executed** rather than only syntax-checked; it
ran clean end to end, exit 0.

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
deliberate `.env` edit. **This has not been done yet** -- `.env` and
`.env.example` still point at the `2.0` branch head.

> **There is no release tag to pin to yet.** The first attempt produced one
> that pointed at the wrong commit: `gh release create` without `--target` tags
> the **default branch's head**, so a release built from `2.0` tagged `main`,
> and `v2.1.0` resolved to a v1.2.3 / NeoForge commit. Pinning `PACKWIZ_URL`
> to it would have installed the v1 pack at the next unattended restart. The
> Release's attached artifacts were correct, built from the right checkout,
> which is what made it easy to miss. `publish.yml` now passes
> `--target "$GITHUB_SHA"`, and the bad release and tag were deleted. So pin
> only after a post-merge version bump produces a verified tag -- and check it
> with `git rev-parse <tag>` plus `git show <sha>:pack.toml` before trusting it.

The pack ships **no Discord mod**. Discord Integration was removed once the
bridge design was settled (on `2.0`, no version bump yet -- a bump cuts a
release, see "Version and branch state"). The bridge lives entirely in the Wrench's Toolkit
bot, which tails `/data/logs/latest.log` for Minecraft -> Discord and sends
RCON `tellraw` for Discord -> Minecraft. Two reasons it is not a mod. DI needs
its own second Discord bot application, and its `[[commands]]` system has no
role or permission gating at all -- verified in the 2.2.3 jar, where
`CommandConfig` carries only `minecraft_command`, `discord_command`,
`description`, `use_parameters` and `enabled`, with a single `channel_id`
shared by chat and commands -- so privileged commands could not be restricted
to moderators. Keeping it out also means the pack stays fully playable with no
bot, which matters because it is published for anyone to use. The bot repo's
`IRON_ARCANA_HANDOVER.md` carries the design.

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
- **Storage is Sophisticated Backpacks only** (plus its Create integration).
  Sophisticated *Storage* is deliberately **not** in the pack — only Backpacks.
  The upgrades to disable are the automation ones: feeding, inception,
  everlasting, pump, magnet, compacting, void, auto_smelting, auto_blasting,
  auto_smoking, alchemy, and their `advanced_` variants. Keep the manual
  ones — filter, stack, sort, pickup, deposit, restock, tank, battery.
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
- **Performance is a real constraint.** BlueMap, MineColonies AI and Create
  contraptions are the known cost centres — see `docs/SERVER_PERFORMANCE_NOTES.md` (v1-era, still directionally right)
  before adding heavy server-side mods.
- **One recipe viewer: JEI.** EMI was the pack's viewer through 2.0 and was
  removed on 2026-10-11 -- every major mod here is JEI-native and none support
  EMI, so EMI could list their recipes but not draw them correctly. Do not add
  a second viewer.
