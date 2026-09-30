# v1.2.3 Mod Inventory — Rebuild Checklist for 2.0

Snapshot of the **NeoForge 1.21.1** pack as it stood at tag `v1.2.3-final` (105 entries).
This is the working checklist for re-adding mods on **MC 1.20.1 / Forge 47.4.10**.

> **Historical.** The dispositions below were the plan at the start of the
> rebuild. Several changed during execution — Sophisticated and Spartan Weaponry
> were later dropped, and Create Aeronautics turned out to have no 1.20.1 release
> at all. `../SKIPPED.md` and `../CLAUDE.md` are authoritative for what 2.0
> actually contains; this file remains useful as the v1.2.3 snapshot.

Source: `MR` = Modrinth, `CF` = CurseForge, `URL` = direct download.
Disposition: **Keep** = re-add as-is · **Replace** = re-add a different build · **Drop** = not in 2.0 · **Verify** = availability unconfirmed on 1.20.1 Forge.

Modrinth 1.20.1 availability has been confirmed in bulk: **83 of 86** Modrinth entries have 1.20.1 builds.
Every `CF` row still needs checking (Phase 3a).

---

## Libraries & APIs — re-add first, in this order

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Architectury API | CF | `architectury-api` | both | Keep — prefer the Modrinth listing |
| Balm | MR | `balm` | both | Keep |
| Bookshelf | MR | `bookshelf-lib` | client | Keep — audit side |
| CERBON's API | MR | `cerbons-api` | both | Keep (BoMD dep) |
| Citadel | CF | `citadel-1-21-1-port` | both | **Replace** — official 1.20.1 build |
| Cloth Config API | MR | `cloth-config` | both | Keep |
| CreativeCore | MR | `creativecore` | client | Keep (AmbientSounds dep) |
| Curios API | MR | `curios` | both | Keep |
| GeckoLib | MR | `geckolib` | both | Keep |
| GlitchCore | MR | `glitchcore` | both | Keep |
| Kotlin for Forge | MR | `kotlin-for-forge` | both | Keep — **side must be `both`** (Slice & Dice needs it server-side; fixed in `ab238b4`) |
| Moonlight Lib | MR | `moonlight` | both | Keep |
| owo-lib | MR | `owo-lib` | both | Keep (Aether dep) |
| Patchouli | MR | `patchouli` | both | Keep |
| playerAnimator | MR | `playeranimator` | both | Keep |
| Puzzles Lib | CF | `puzzles-lib` | both | Keep — prefer Modrinth |
| Resourceful Config | MR | `resourceful-config` | both | Keep |
| Resourceful Lib | MR | `resourceful-lib` | both | Keep |
| Rhino | MR | `rhino` | both | Keep (KubeJS dep) |
| Athena | MR | `athena-ctm` | client | Keep (Chipped CTM) |
| libIPN | MR | `libipn` | client | Keep (IPN dep) |
| YUNG's API | MR | `yungs-api` | both | Keep |
| Prickle | MR | `prickle` | client | **Drop** — no 1.20.1 build; dependency-only |
| Silent Lib | MR | `silent-lib` | both | **Drop** — goes with Silent Gear |
| Sable | CF | `sable` | both | **Drop** — believed to be a Create Aeronautics dependency; confirm before removing |
| isCyclic StackOverflow Crash Fix | CF | `iscyclic-stackoverflow-crash-fix` | both | **Drop** — band-aid for the 1.21.1 unofficial-port stack |

## Colony — core pillar

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| MineColonies | CF | `minecolonies` | both | **Verify** — critical |
| Structurize | CF | `structurize` | both | **Verify** — critical |
| Domum Ornamentum | CF | `domum-ornamentum` | both | **Verify** — critical |
| BlockUI | CF | `blockui` | both | **Verify** — critical |
| Multi-Piston | CF | `multi-piston` | both | **Verify** — critical |

## Tech — Create

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Create | CF | `create` | both | Keep — use Modrinth (`mc1.20.1-6.0.8`) |
| Create Crafts & Additions | MR | `createaddition` | both | Keep |
| Create Slice & Dice | MR | `slice-and-dice` | both | Keep |
| Create Deco | MR | `create-deco` | both | Keep |
| Steam 'n' Rails | CF | `steam-n-rails-neoforge` | both | **Replace** — official 1.20.1 build, drop the unofficial port |
| Create Aeronautics | CF | `create-aeronautics` | both | **Drop** — alpha, and CF API distribution disabled (forces the `pack-import-cache/` workaround) |

## Tech — Immersive Engineering

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Immersive Engineering | MR | `immersiveengineering` | both | Keep (`10.2.0-183` on 1.20.1) |
| Immersive Petroleum | MR | `immersivepetroleum` | both | Keep |

## Gear — the swap

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Silent Gear | MR | `silent-gear` | both | **Drop** — replaced by Tinkers' |
| — | MR | `tinkers-construct` | both | **Add** (`3.11.2.166` stable / `3.12.1.231` beta) |
| — | MR | `mantle` | both | **Add** — required |
| — | MR | `tinkers-levelling-addon` | both | Optional, after base boots |
| — | MR | `tinkers-reforged` | both | Optional, after base boots |

## Magic

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Ars Nouveau | MR | `ars-nouveau` | both | Keep (`4.12.7` on 1.20.1) |
| Ars Creo | MR | `ars-creo` | both | Keep — the Ars↔Create bridge |
| Ars Technic | MR | `ars-technic` | both | **Drop** — 1.21.1 only |
| — | MR | `botania` | both | **Add back** — Forge 1.20.1 exists; was cut for lacking NeoForge 1.21.1 |

## Dimensions

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| The Aether | MR | `aether` | both | Keep |
| Alex's Caves | CF | `alexs-caves-unofficial-port` | both | **Replace** — official 1.20.1 build |
| Alex's Mobs | CF | `alexs-mobs-1-21-1-port` | both | **Replace** — official 1.20.1 build |
| — | CF | `the-twilight-forest` | both | **Add back** — cut for Modrinth policy in `785d157` |

## Worldgen & Structures

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Terralith | MR | `terralith` | both | Keep (`2.5.4` on 1.20.1) |
| Serene Seasons | MR | `serene-seasons` | both | Keep — set season length 16–24 days |
| YUNG's Better Dungeons | MR | `yungs-better-dungeons` | server | Keep — **audit side** |
| YUNG's Better Mineshafts | MR | `yungs-better-mineshafts` | server | Keep — **audit side** |
| YUNG's Better Strongholds | MR | `yungs-better-strongholds` | server | Keep — **audit side** |
| Dungeons and Taverns | MR | `dungeons-and-taverns` | both | Keep |
| Bosses of Mass Destruction | MR | `bosses-of-mass-destruction-forge` | both | Keep |
| Lootr | MR | `lootr` | both | Keep |
| Noisium | MR | `noisium` | server | Keep |

## Storage

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Sophisticated Core | MR | `sophisticated-core` | both | Keep |
| Sophisticated Storage | MR | `sophisticated-storage` | both | Keep |
| Sophisticated Backpacks | MR | `sophisticated-backpacks` | both | Keep |
| SS Create Integration | MR | `sophisticated-storage-create-integration` | both | Keep |
| SB Create Integration | MR | `sophisticated-backpacks-create-integration` | both | Keep |

> The 29 upgrade-removal recipes carry over — see Phase 4.

## Building & Decoration

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Chipped | MR | `chipped` | both | Keep |
| Macaw's Bridges / Doors / Roofs / Windows | MR | `macaws-*` | both | Keep (4 entries) |
| Supplementaries | MR | `supplementaries` | both | Keep |
| Carry On | MR | `carry-on` | both | Keep |
| — | CF | `engineers-decor` | both | **Verify** — was frozen at 1.19.2; check for a 1.20.1 build |

## Food

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Farmer's Delight | MR | `farmers-delight` | both | Keep |

## Combat & Survival

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Better Combat | MR | `better-combat` | both | Keep |
| Spartan Weaponry | MR | `spartan-weaponry-unofficial` | both | **Replace** — official `spartan-weaponry` has 1.20.1 |
| You're in Grave Danger | MR | `yigd` | both | Keep |

## Mobs

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Friends & Foes | MR | `friends-and-foes-forge` | both | Keep |
| Creeper Overhaul | MR | `creeper-overhaul` | both | Keep |
| Naturalist | MR | `naturalist` | both | Keep |
| Illager Invasion | CF | `illager-invasion` | both | **Verify** |

## Performance

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Sodium | MR | `sodium` | client | **Replace** — use Embeddium on 1.20.1 Forge |
| FerriteCore | MR | `ferrite-core` | both | Keep |
| ModernFix | MR | `modernfix` | both | Keep |
| Clumps | MR | `clumps` | both | Keep |
| Chunky | MR | `chunky` | both | Keep |
| spark | MR | `spark` | both | Keep |

## Atmosphere — client

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Sound Physics Remastered | MR | `sound-physics-remastered` | client | Keep |
| AmbientSounds | MR | `ambientsounds` | client | Keep |
| LambDynamicLights | MR | `lambdynamiclights` | client | Keep — recheck against Embeddium |
| Entity Model Features | MR | `entity-model-features` | client | Keep (Fresh Animations) |
| Entity Texture Features | MR | `entitytexturefeatures` | client | Keep (Fresh Animations) |

## UI & QoL — client

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| EMI | MR | `emi` | client | Keep — the chosen recipe viewer |
| Just Enough Items | MR | `jei` | client | **Drop** — added in `320c30a` for a crash, never removed; conflicts with EMI |
| Just Enough Resources | MR | `just-enough-resources-jer` | client | Keep — EMI compat |
| JEED | MR | `just-enough-effect-descriptions-jeed` | client | Keep — EMI compat |
| Enchantment Descriptions | MR | `enchantment-descriptions` | client | Keep |
| Jade | MR | `jade` | client | Keep |
| AppleSkin | MR | `appleskin` | client | Keep |
| Xaero's Minimap | MR | `xaeros-minimap` | client | Keep |
| Xaero's World Map | MR | `xaeros-world-map` | client | Keep |
| Inventory Profiles Next | MR | `inventory-profiles-next` | client | Keep |
| Mouse Tweaks | MR | `mouse-tweaks` | client | Keep |
| Crafting Tweaks | MR | `crafting-tweaks` | both | Keep |
| Waystones | MR | `waystones` | both | Keep |

## Chunk Protection & Teams

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Open Parties and Claims | MR | `open-parties-and-claims` | both | Keep — decide vs FTB Chunks now that FTB is unblocked |
| — | CF | `ftb-teams-forge` | both | **Add back** — cut for Modrinth policy |
| — | CF | `ftb-library-forge` | both | **Add back** — FTB Quests/Teams dep |

## Quests

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| — | CF | `ftb-quests-forge` | both | **Add back** — 15 authored chapters recoverable from `5a36352^` |

## Server Utilities

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| BlueMap | CF | `bluemap` | both | **Verify** — also set `defaultMap: "world"` in `webapp.conf` |
| Create BlueMap | CF | `create-bluemap` | server | **Verify** |
| Discord Integration | CF | `discord-integration` | server | **Verify** — needs bot token in config |
| EventBridge | URL | `eventbridge` | server | **Drop** — deferred to a later release; needs a 1.20.1 build first |

## Compat & Integration

| Mod | Src | Slug | Side | 2.0 |
|---|---|---|---|---|
| Almost Unified | MR | `almost-unified` | both | Keep — add early |
| KubeJS | MR | `kubejs` | both | Keep — **`2001.x` API**, scripts need porting from `2101.x` |
| — | CF | `minecolonies-tweaks` | both | **Verify** — had no 1.21.1 build; check 1.20.1 |
| — | CF | `stylecolonies` | both | **Add back** — cut for Modrinth policy |
| — | CF | `byzantine-styles-pack-for-minecolonies` | both | **Add back** — cut for Modrinth policy |
| — | CF | `smallcolonies` | both | **Add back** — cut for Modrinth policy |
| — | CF | `towntalk` | both | **Add back** — cut for Modrinth policy |

---

## Resource pack

Fresh Animations — ships as a resource pack, not a mod. Requires EMF + ETF. Enable by default via `options.txt` at pack root; the filename in `resourcePacks:[...]` must match the downloaded zip exactly.

---

## Counts

| | |
|---|---|
| v1.2.3 entries | 105 |
| Keep as-is | ~70 |
| Replace with official/different build | 6 |
| Drop | 9 |
| Add back (Modrinth-policy casualties) | 7 |
| Add new (Tinkers' stack) | 2–4 |
| Needs 1.20.1 verification | 13 |
