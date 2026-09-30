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
| `mods/*.pw.toml` | one metadata file per mod (100 entries) |
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
  269 MB.
- **Do not hand-set `side`.** packwiz infers it from platform metadata; v1's
  hand-set flags drifted. Sides were audited on 2026-09-30 and are correct —
  Embeddium in particular is correctly `client`.
- Run `packwiz refresh` every 10–15 additions to catch index errors early.

---

## 2.0 Progress

### Done

| | |
|---|---|
| Pack rebuilt | 100 entries re-resolved for 1.20.1 Forge from scratch (`247b367`) |
| Flight | Valkyrien Skies 2 + Clockwork replace Create Aeronautics, which has no 1.20.1 release |
| Gear swap | Tinkers' Construct 3.12.1.231 + Mantle replace Silent Gear |
| Restored | Twilight Forest, Stylecolonies, SmallColonies, TownTalk, FTB Quests/Teams/Library, Botania |
| Unofficial ports retired | Alex's Caves, Alex's Mobs, Citadel, Spartan Weaponry, Steam 'n' Rails now official 1.20.1 builds |
| EMI/JEI conflict resolved | JEI **and** JER dropped — JER hard-depends on JEI |
| Docker server | `server/` — itzg image, `PACKWIZ_URL` self-install (`bae071e`) |
| Infra stripped | EventBridge and all Modrinth publishing removed (`2db8bf6`) |

### Not done yet — in priority order

1. **First Docker boot has never been run.** Nothing in 2.0 has started a
   server. This is the real verification of the whole rebuild.
2. **KubeJS scripts are not ported.** They still live only in the legacy
   Desktop server folder and target the `2101.x` API; 1.20.1 needs `2001.x`.
   See below for what must carry over and what must be deleted.
3. **No mod configs are tracked.** `config/` has zero tracked files while the
   legacy server has 283. Do **not** copy the v1 configs over — schemas change
   between mod versions. Boot once, let 1.20.1 configs generate, then tune and
   commit the ones that matter.
4. **FTB Quests content not restored.** 15 authored chapters (3,557 lines) are
   recoverable with `git show 5a36352^:config/ftbquests/...`. Chapter 11 is
   Twilight Forest (valid again); every Silent Gear reference needs rewriting
   for Tinkers'.
5. Tinkers' addons (`tinkers-levelling-addon`, `tinkers-reforged`) deferred
   until the base pack boots.
6. `options.txt` for enabling Fresh Animations by default.
7. Client install instructions in the root README.

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

**Do not port — the 29 Sophisticated upgrade removals.** Obsolete: the
Sophisticated mods were dropped from 2.0 entirely, so there are no upgrades to
remove. This was the bulk of v1's KubeJS surface, which makes the port far
smaller than it looks in the v1 scripts. The *intent* behind those removals
still stands as pack philosophy — see below.

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

### Create addon compatibility
Every Create addon in the pack declares `create >= 6.0.x`, so Create 6.0.8
satisfies them. Read `META-INF/mods.toml` out of the jar to check a range —
`dependencies` in the Modrinth API are unpinned and tell you nothing. Addon
breakage across Create majors is the usual failure mode.

**Forge floor: Valkyrien Skies 2 requires `forge >= 47.2.0`.** Do not drop
below that; 47.4.10 is well clear.

---

## Pack Philosophy

A **small private friend server** (~4–8 players) distributed over GitHub. Not a
public pack, and no longer constrained by Modrinth's rules.

- **Tinkers' Construct is the gear progression system.** Silent Gear was removed
  in 2.0 — its default traits were weak and its Materials Book advertised
  materials from absent mods. Do not reintroduce Silent Gear, and do not add a
  third gear mod.
- **Progression matters.** Automation shortcuts that bypass Create/IE gameplay
  are removed deliberately. Players build factories. In v1 this meant stripping
  29 Sophisticated Backpacks/Storage upgrades; in 2.0 the Sophisticated mods are
  simply absent. Apply the same test to any storage mod proposed later: if a
  single upgrade item replaces a Create or IE build, it does not belong.
- **No dedicated storage mod, by choice.** Sophisticated Core/Storage/Backpacks
  were dropped in 2.0 at the user's request. Storage is vanilla plus Create
  logistics. Do not add a replacement unasked.
- **Colony is a core pillar.** MineColonies with multiple style packs. Don't add
  mods that fight colony chunk claims or building placement.
- **Magic is secondary.** Ars Nouveau and Botania are present; the pack leans
  tech. Check synergy before adding more magic.
- **Performance is a real constraint.** BlueMap, MineColonies AI and Create
  contraptions are the known cost centres — see `SERVER_PERFORMANCE_NOTES.md`
  before adding heavy server-side mods.
- **One recipe viewer: EMI.** JEI is deliberately absent. Anything that
  hard-depends on JEI (such as Just Enough Resources) is therefore out too.
