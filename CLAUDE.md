# Iron & Arcana — Claude Handover Document
**Forge 1.20.1 | v2.0.0 (in progress, branch `2.0`) | Small private friend server**

---

## Pack Identity

| Field | Value |
|---|---|
| Name | Iron & Arcana |
| Version | 2.0.0 |
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
| `mods/*.pw.toml` | one metadata file per mod (95 entries, 11 CurseForge-sourced) |
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
| EMI/JEI conflict resolved | JEI **and** JER dropped — JER hard-depends on JEI |
| Docker server | `server/` — itzg image, `PACKWIZ_URL` self-install (`bae071e`) |
| Infra stripped | EventBridge and all Modrinth publishing removed (`2db8bf6`) |

### Not done yet — in priority order

1. **Sophisticated Backpacks upgrade gating.** The automation-shortcut upgrades
   are to be disabled through **Sophisticated Core's own config**, not by KubeJS
   recipe removal as in v1. See the philosophy section for which ones and why.
2. **No mod configs are tracked.** `config/` has zero tracked files. 1.20.1
   configs have now generated inside the `iron-and-arcana_data` volume, so this
   is unblocked — pull the tuned ones out and commit them. Do **not** copy the
   v1 configs over; schemas change between mod versions.
3. **KubeJS scripts are not ported.** Now a very small job: the only thing left
   to carry over is the Immersive Engineering tag fix (below). Everything else
   from v1 is obsolete.
4. Tinkers' addons (`tinkers-levelling-addon`, `tinkers-reforged`) — optional.
5. `options.txt` for enabling Fresh Animations by default.
6. Client install instructions in the root README, and optionally the
   packwiz-installer client route to stop client/server drift.

**No longer applicable:** FTB Quests was removed, so the 15 authored v1 quest
chapters are not being restored. They remain in git history at
`git show 5a36352^:config/ftbquests/...` if a quest mod is ever reintroduced.

---

## KubeJS Port — What Carries Over

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
- **Performance is a real constraint.** BlueMap, MineColonies AI and Create
  contraptions are the known cost centres — see `SERVER_PERFORMANCE_NOTES.md`
  before adding heavy server-side mods.
- **One recipe viewer: EMI.** JEI is deliberately absent. Anything that
  hard-depends on JEI (such as Just Enough Resources) is therefore out too.
