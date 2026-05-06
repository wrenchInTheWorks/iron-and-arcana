# Iron & Arcana — packwiz Session Brief
**For use with Claude Code**

---

## Pack Metadata

| Field | Value |
|---|---|
| Name | Iron & Arcana |
| Minecraft Version | 1.21.1 |
| Mod Loader | NeoForge |
| Pack Version | 1.0.0 |
| Author | *(set before init)* |
| Description | A colony-building, engineering, and exploration pack for a small friend server. |

---

## Prerequisites

Before starting the session, verify these are in place:

```bash
# packwiz installed and on PATH — test with:
packwiz version

# CurseForge API key configured:
packwiz settings curseforge-api-key <your-key>
# Key generated at: https://console.curseforge.com

# Git repo initialised in working directory:
git init
git commit --allow-empty -m "init"
```

---

## Session Workflow

```bash
# 1. Initialise pack (answer prompts with metadata above)
packwiz init

# 2. Add mods (work through tables below)
packwiz modrinth add <slug>
packwiz curseforge add <slug>

# 3. After all mods added:
packwiz refresh

# 4. Export to .mrpack for Modrinth:
packwiz modrinth export
```

When adding mods, packwiz will automatically resolve the correct version
for 1.21.1 NeoForge. If it prompts for version selection, pick the most
recent stable release for 1.21.1.

---

## Mod List

Side key: `both` = default (omit flag) | `client` = add `--side client` |
`server` = add `--side server`

Confidence key: ✅ slug verified | ⚠️ slug needs runtime verification

---

### COLONY

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Minecolonies | Modrinth | `minecolonies` | both | ✅ |
| Structurize | Modrinth | `structurize` | both | ✅ Required dependency |
| Domum Ornamentum | Modrinth | `domum-ornamentum` | both | ✅ Required dependency |
| Block-UI | Modrinth | `blockui` | both | ✅ Required dependency |
| Multi-Piston | Modrinth | `multi-piston` | both | ✅ Required dependency |
| StyleColonies | CurseForge | `stylecolonies` | both | ⚠️ Verify slug — official blueprint addon, includes FairyTale style (requires TF + Create, both present) |
| Byzantine Styles Pack | CurseForge | `byzantine-styles-pack-for-minecolonies` | both | ⚠️ Verify slug — adds Byzantine, Shogun, Nile styles |
| SmallColonies | CurseForge | `smallcolonies` | both | ⚠️ Verify slug — compact building styles (Littleton, Sandyton) |
| Minecolonies Tweaker | Modrinth | `minecolonies-tweaker` | both | ⚠️ Verify slug — KubeJS integration for colony recipes |

---

### TECH — CREATE

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Create | Modrinth | `create` | both | ✅ |
| Create: Aeronautics | CurseForge | `create-aeronautics` | both | ✅ v1.2.1, April 2026, stable |
| Create: Steam 'n' Rails | CurseForge | `steam-n-rails-neoforge` | both | ⚠️ Unofficial 1.21.1 port — verify slug. Official slug `create-steam-n-rails` is 1.20.1 only |
| Create: Crafts & Additions | Modrinth | `createaddition` | both | ✅ Bridges Create SU ↔ IE RF |
| Create: Slice & Dice | Modrinth | `slice-and-dice` | both | ✅ Create ↔ Farmer's Delight |
| Create: Deco | Modrinth | `create-deco` | both | ⚠️ Verify slug |

---

### TECH — IMMERSIVE ENGINEERING

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Immersive Engineering | Modrinth | `immersiveengineering` | both | ✅ v12.4.2, July 2025 |
| Immersive Petroleum | Modrinth | `immersive-petroleum` | both | ⚠️ **Verify 1.21.1 availability before adding** — may still be on 1.20.1 |

---

### TOOLS

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Silent Gear | Modrinth | `silent-gear` | both | ✅ v4.2.0, May 2026 |
| Silent Lib | Modrinth | `silent-lib` | both | ✅ Required dependency of Silent Gear |

---

### MAGIC

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Ars Nouveau | Modrinth | `ars-nouveau` | both | ✅ |
| Botania | Modrinth | `botania` | both | ✅ |
| Patchouli | Modrinth | `patchouli` | both | ✅ Required by Ars Nouveau and Botania |

---

### EXPLORATION — DIMENSIONS

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Twilight Forest | CurseForge | `the-twilight-forest` | both | ✅ CurseForge primary — no official Modrinth listing. v4.3.2508 for 1.21.1 |
| Alex's Caves | Modrinth | `alexs-caves` | both | ✅ |
| Alex's Mobs | Modrinth | `alexs-mobs` | both | ✅ |

---

### EXPLORATION — STRUCTURES

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| When Dungeons Arise | Modrinth | `when-dungeons-arise` | both | ✅ |
| Dungeons and Taverns | Modrinth | `dungeons-and-taverns` | both | ⚠️ Verify slug |
| YUNG's Better Dungeons | Modrinth | `yungs-better-dungeons` | both | ✅ |
| YUNG's Better Mineshafts | Modrinth | `yungs-better-mineshafts` | both | ✅ |
| YUNG's Better Strongholds | Modrinth | `yungs-better-strongholds` | both | ✅ |
| Bosses of Mass Destruction | Modrinth | `bosses-of-mass-destruction` | both | ✅ |

---

### BIOMES & SEASONS

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Terralith | Modrinth | `terralith` | both | ✅ Priority biome mod |
| Serene Seasons | Modrinth | `serene-seasons` | both | ✅ Compatible with Terralith on NeoForge without compat mod |

---

### FOOD

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Farmer's Delight | Modrinth | `farmers-delight` | both | ✅ |

---

### STORAGE

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Sophisticated Core | Modrinth | `sophisticated-core` | both | ✅ Required by both Sophisticated mods |
| Sophisticated Storage | Modrinth | `sophisticated-storage` | both | ✅ |
| Sophisticated Backpacks | Modrinth | `sophisticated-backpacks` | both | ✅ |

---

### BUILDING & DECORATION

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Chipped | Modrinth | `chipped` | both | ✅ Native integration with Sophisticated Storage |
| Macaw's Bridges | Modrinth | `macaws-bridges` | both | ✅ |
| Macaw's Roofs | Modrinth | `macaws-roofs` | both | ✅ |
| Macaw's Windows | Modrinth | `macaws-windows` | both | ✅ |
| Macaw's Doors | Modrinth | `macaws-doors` | both | ✅ |
| Supplementaries | Modrinth | `supplementaries` | both | ✅ Vanilla+ functional/decorative items |

---

### COMBAT & SURVIVAL

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Better Combat | Modrinth | `better-combat` | both | ✅ |
| Spartan Weaponry Unofficial | Modrinth | `spartan-weaponry-unofficial` | both | ⚠️ Unofficial 1.21.1 port — verify slug. Does NOT integrate with Silent Gear by design |
| You're in Grave Danger | Modrinth | `yigd` | both | ✅ Supports Curios, restores inventory layout on death |

---

### MOBS

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Friends & Foes | Modrinth | `friends-and-foes` | both | ✅ Mob vote losers — Copper Golem, Glare, etc. |
| Creeper Overhaul | Modrinth | `creeper-overhaul` | both | ✅ |
| Naturalist | Modrinth | `naturalist` | both | ✅ Passive/neutral fauna |
| Illager Expansion | Modrinth | `illager-expansion` | both | ⚠️ Verify slug and 1.21.1 availability |

---

### PERFORMANCE

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Embeddium | Modrinth | `embeddium` | client | ✅ Sodium port for NeoForge |
| FerriteCore | Modrinth | `ferrite-core` | both | ✅ |
| ModernFix | Modrinth | `modernfix` | both | ✅ |
| Noisium | Modrinth | `noisium` | both | ✅ Worldgen thread optimisation |
| Clumps | Modrinth | `clumps` | both | ✅ XP orb merging |
| Chunky | Modrinth | `chunky` | both | ✅ Server-side chunk pre-gen |

---

### ATMOSPHERE

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Sound Physics Remastered | Modrinth | `sound-physics-remastered` | client | ✅ v1.21.1-1.5.1 confirmed |
| Ambient Sounds | Modrinth | `ambientsounds` | client | ⚠️ Verify slug — may be CurseForge primary |
| Dynamic Lights | Modrinth | `dynamiclights` | client | ⚠️ Verify correct NeoForge 1.21.1 variant — may be `dynamic-lights-reforged` or similar |
| Entity Model Features (EMF) | Modrinth | `entity-model-features` | client | ✅ Required for Fresh Animations resource pack |
| Entity Texture Features (ETF) | Modrinth | `entity-texture-features` | client | ✅ Required for Fresh Animations resource pack |

---

### UI & QoL

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| EMI | Modrinth | `emi` | client | ✅ Replaces JEI — has material tier grouping |
| Just Enough Resources | Modrinth | `just-enough-resources` | client | ✅ EMI compat confirmed |
| Just Enough Effect Descriptions | Modrinth | `just-enough-effect-descriptions` | client | ✅ |
| Enchantment Descriptions | Modrinth | `enchantment-descriptions` | client | ✅ Tooltip lore for enchantment books |
| Jade | Modrinth | `jade` | client | ✅ Block/entity info on hover |
| AppleSkin | Modrinth | `appleskin` | client | ✅ |
| Xaero's Minimap | Modrinth | `xaeros-minimap` | client | ✅ |
| Xaero's World Map | Modrinth | `xaeros-world-map` | client | ✅ |
| Inventory Profiles Next | Modrinth | `inventory-profiles-next` | client | ✅ |
| Mouse Tweaks | Modrinth | `mouse-tweaks` | client | ✅ |
| Carry On | Modrinth | `carry-on` | both | ✅ |
| Crafting Tweaks | Modrinth | `crafting-tweaks` | both | ✅ |
| Waystones | Modrinth | `waystones` | both | ✅ |
| Curios API | Modrinth | `curios` | both | ✅ Required by Ars Nouveau, You're in Grave Danger, others |

---

### CHUNK PROTECTION

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Open Parties and Claims | Modrinth | `open-parties-and-claims` | both | ✅ Replaces FTB Chunks + Teams. Has native Create + Xaero's integration |

---

### SERVER UTILITIES

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Discord Integration (DI) | Modrinth | `discord-integration-di` | server | ⚠️ Verify slug. Server-side only. Bridges in-game chat ↔ Discord channel via bot webhook |
| BlueMap | Modrinth | `bluemap` | server | ✅ 3D web map, integrated webserver on port 8100. Throttle render threads in config on first boot |
| BlueMap-Discord Addon | Modrinth | `bluemap-discord` | server | ⚠️ Verify slug — posts player events to Discord with map links |
| BlueMap-Create Addon | Modrinth | `bluemap-create` | server | ⚠️ Verify slug — renders Create contraptions as live markers on the map |

---

### COMPAT & INTEGRATION

| Mod | Source | Slug | Side | Notes |
|---|---|---|---|---|
| Almost Unified | Modrinth | `almost-unified` | both | ✅ Recipe unification across all tech mods — add early |
| KubeJS | Modrinth | `kubejs` | both | ✅ |
| GeckoLib | Modrinth | `geckolib` | both | ✅ Required by Alex's Mobs, Alex's Caves, Ars Nouveau, BoMD, others |
| Ars Creo | Modrinth | `ars-creo` | both | ✅ Ars Nouveau ↔ Create. Official addon from AN team |
| Ars Technica | Modrinth | `ars-technica` | both | ⚠️ Verify slug — Create-themed content addon for Ars Nouveau |
| Sophisticated Storage Create Integration | Modrinth | `sophisticated-storage-create-integration` | both | ✅ Full SS functionality on moving contraptions |
| Sophisticated Backpacks Create Integration | Modrinth | `sophisticated-backpacks-create-integration` | both | ⚠️ Verify slug |
| Minecolonies Tweaker | Modrinth | `minecolonies-tweaker` | both | ⚠️ Verify slug |

---

## Resource Packs

### Fresh Animations — Default Enabled

Fresh Animations adds smooth procedural mob animations without changing any
textures or art style. It ships as a resource pack, not a mod. EMF and ETF
(listed in the atmosphere mod table above) must be installed for it to render.

**Step 1 — Download the pack:**
```bash
# Fresh Animations is on Modrinth as a resource pack file.
# Download the latest zip for 1.21 from:
# https://modrinth.com/resourcepack/fresh-animations
# Place the zip in the resourcepacks/ folder of your packwiz project.
```

**Step 2 — Track it in packwiz:**
```bash
# packwiz treats resource packs as plain files — add it to pack index:
packwiz refresh
```

**Step 3 — Enable it by default:**

Include an `options.txt` file in the pack root. Packwiz distributes this
alongside mods and it lands in the player's `.minecraft` folder, pre-configuring
the resource pack as active.

```
# options.txt (place in packwiz project root)
resourcePacks:["file/Fresh Animations x32 v1.9.zip","vanilla"]
incompatibleResourcePacks:[]
```

Replace `Fresh Animations x32 v1.9.zip` with the exact filename of the
downloaded zip. The `vanilla` entry keeps the default pack active underneath it.

> **Note:** If players already have an `options.txt`, this will overwrite their
> resource pack selection on next launch. Acceptable for a friend server where
> you control the install, but worth documenting in the pack description.

---

## Shaders — Recommended, Not Bundled

Shaders are user preference — hardware requirements vary too much to bundle.
Include this section in the pack's Modrinth description or a bundled `README.md`.

### To use shaders with Iron & Arcana

Install **Oculus** (the NeoForge port of Iris) as an additional client-side mod.
Oculus is compatible with Embeddium which is already in the pack.

- Modrinth: `oculus`
- Install manually alongside the pack — do not add to the packwiz project

### Recommended shader packs

| Shader | Character | Performance Cost |
|---|---|---|
| **Complementary Reimagined** | Warm, atmospheric, good colony/forest look | Medium |
| **BSL Shaders** | Clean and versatile, works with most aesthetics | Medium |
| **Sildur's Vibrant Shaders** | Lighter option, good for lower-end hardware | Low–Medium |

All three are available at [shaderlabs.org](https://shaderlabs.org) or their
respective Modrinth/CurseForge pages. Complementary Reimagined is the strongest
fit for this pack's aesthetic — warm lighting suits both the colony and
exploration dimensions well.

---

## Dropped Mods

| Mod | Reason |
|---|---|
| Engineer's Decor | Frozen at 1.19.2 — no official or credible unofficial 1.21.1 port exists. Decoration gap covered by Create: Deco, Chipped, Supplementaries, and Macaw's series. |

Run these checks before or during the session. If a mod is unavailable on
1.21.1 NeoForge, note it in a `SKIPPED.md` file for later review.

### Check 1.21.1 availability before adding:
- Immersive Petroleum
- Illager Expansion

### Verify slugs at runtime (packwiz will error if wrong):
- StyleColonies (CurseForge)
- Byzantine Styles Pack (CurseForge)
- SmallColonies (CurseForge)
- Minecolonies Tweaker
- Create: Steam 'n' Rails unofficial (CurseForge)
- Create: Deco
- Dungeons and Taverns
- Spartan Weaponry Unofficial
- Ars Technica
- Ambient Sounds
- Dynamic Lights (NeoForge variant)
- Discord Integration DI
- BlueMap-Discord addon
- BlueMap-Create addon
- Sophisticated Backpacks Create Integration
- Fresh Animations zip filename (must match options.txt exactly)

### Suggested verification approach:
```bash
# For Modrinth slugs — search before adding:
packwiz modrinth search "<mod name>"

# For CurseForge — check URL slug at:
# https://www.curseforge.com/minecraft/mc-mods/<slug>
```

---

## Post-Add Config Notes

Note these for after the pack is built — configs to adjust before
distributing or running a server:

| Mod | Config Note |
|---|---|
| BlueMap | Throttle `renderThreadCount` in `bluemap.conf` — default will saturate CPU on first world render |
| Open Parties and Claims | Set per-player chunk claim limits appropriate for small server |
| Serene Seasons | Default season length is 8 in-game days — consider 16–24 for a friend server |
| Minecolonies | Set `maxColonySize` and `initialCitizenCount` in colony config to taste |
| Create: Aeronautics | Alpha — monitor for crash reports on first session, have world backup ready |
| Create: Steam 'n' Rails (unofficial) | Same caution as Aeronautics — unofficial port |
| Discord Integration | Requires bot token setup in `discord-integration.toml` after install |
| Chunky | Run `/chunky start` server-side before players join to pre-gen spawn area |

---

## Export & Distribution

```bash
# Generate .mrpack for Modrinth upload:
packwiz modrinth export

# Output: iron-and-arcana-1.0.0.mrpack
# Upload to: https://modrinth.com/modpacks (new project)

# For server pack:
# packwiz exports server-side only mods automatically
# Client-only mods (Embeddium, sound mods, UI mods) are stripped
```

---

## Session Behaviour Notes for Claude Code

- Work through mod tables in order — dependencies before dependents
- If a slug resolves to wrong mod, stop and search before proceeding
- If a mod has no 1.21.1 NeoForge release, add to `SKIPPED.md` and continue
- Run `packwiz refresh` after every 10–15 additions to catch index errors early
- Commit to git after each category block completes
- Do not add mods not on this list without flagging to user first

---

*Iron & Arcana — packwiz brief v1.1*
*NeoForge 1.21.1 | ~87 mods + Fresh Animations resource pack | Small friend server*
