# Dropped & Skipped Mods — 2.0 (MC 1.20.1 / Forge)

Checked 2026-09-30 while rebuilding the pack for 1.20.1 Forge.
See `docs/v1-mod-inventory.md` for the full v1.2.3 snapshot and dispositions.

## No 1.20.1 Forge release

| Mod | Finding | Outcome |
|---|---|---|
| **MineColonies Tweaks** | No 1.20.1 file. Also had no 1.21.1 file in v1 — still unavailable on any version this pack can use. | Not in pack |
| **Create BlueMap** | No 1.20.1 file. Create contraptions will not appear as live markers on the map. | Not in pack — BlueMap itself works fine |
| **Engineer's Decor** | Confirmed frozen; no 1.20.1 build. v1 recorded it as stuck at 1.19.2 and that has not changed. | Not in pack. Decoration gap covered by Create Deco, Chipped, Supplementaries, Macaw's |
| **You're in Grave Danger** | Fabric and NeoForge only — zero 1.20.1 Forge files. | **Replaced by GraveStone Mod** (`gravestone-forge-1.20.1-1.0.35`) |
| **LambDynamicLights** | Fabric, NeoForge and Quilt only — zero 1.20.1 Forge files. | **Replaced by Dynamic Lights** (`dynamiclights-v1.8.6`) |
| **Ars Technic** | 1.21.1 only. | Not in pack. **Ars Creo** remains, so the Ars↔Create bridge is intact |
| **Prickle** | No 1.20.1 build. Dependency-only config library with nothing in 2.0 depending on it. | Not in pack |
| **Create Aeronautics** | **Requested for 2.0, but impossible.** The mod's own files stop at mc1.21.1 on both CurseForge and Modrinth — zero 1.20.1 files for any loader. The 1.20.1 search hits are unrelated modpacks by other authors that bundle Create addons. | Not in pack — see below for the substitute |

### Flying contraptions on 1.20.1 — the Valkyrien Skies route

Since Create Aeronautics cannot be used, the equivalent capability on 1.20.1
Forge is the Valkyrien Skies stack, all at **release** quality rather than
Aeronautics' alpha:

| Mod | 1.20.1 Forge | Role |
|---|---|---|
| Valkyrien Skies 2 | `1.20.1-forge-2.4.11` | Physics/airship engine — the base dependency |
| Clockwork | `3.1.2` | Create-integrated flying contraptions — closest match to Aeronautics |
| Eureka | `1.20.1-forge-1.6.3` | Buildable airships, simpler than Clockwork |

Not added — pending a decision on whether to take this route.

### Dynamic lighting — why not Sodium Dynamic Lights

`sodium-dynamic-lights` does have a 1.20.1 Forge build and would nominally pair
with Embeddium. It was **not** chosen: v1 shipped it in 1.0.0 and swapped away
from it in `4eb7d7d` ("swap sodium-dynamic-lights for lambdynamiclights"). Since
LambDynamicLights is unavailable on Forge, the standalone `dynamic-lights` mod
was used instead rather than revisiting a build that already caused a problem.

## Excluded on purpose

| Mod | Reason |
|---|---|
| **Silent Gear** + Silent Lib | Replaced by Tinkers' Construct. Weak default material traits, and a Materials Book that advertised materials from mods not in the pack — which needed 18 override JSONs plus a dummy tag to suppress, and was never confirmed fixed in-game |
| **Just Enough Items** | EMI is the pack's recipe viewer. JEI was only ever added in `320c30a` to satisfy a crash and never removed |
| **Just Enough Resources** | Hard-depends on JEI, which would reintroduce the duplicate-viewer conflict. Ore-distribution info is the loss here — re-add JEI+JER together if that matters more than having one viewer |
| **Sodium** | Embeddium is the 1.20.1 Forge equivalent |
| **Sophisticated Core / Storage / Backpacks** + both Create integrations | Dropped at the user's request. 2.0 has no dedicated storage mod — storage is vanilla plus Create logistics. This also makes v1's 29 KubeJS upgrade removals obsolete, which was the bulk of the script surface |
| **Spartan Weaponry** | Dropped at the user's request. Better Combat remains as the combat overhaul. It never integrated with the gear system by design anyway |
| **Sable** | Was only present as a Create Aeronautics dependency |
| **isCyclic StackOverflow Crash Fix** | Band-aid for the 1.21.1 unofficial-port stack. All three of those ports are now official 1.20.1 builds, so it should be unnecessary — re-add only if the crash actually reproduces |
| **EventBridge** | Deferred by choice. Needs a 1.20.1 build of the mod first |

## Needs manual verification before use

| Mod | Issue |
|---|---|
| **Byzantine Styles Pack** | packwiz resolved it to `Byzantine-1.21.1-51.1.jar` — a 1.21.1 jar — because the CurseForge file metadata is mis-tagged. The only 1.20-era file is `Byzantine-1.20.1-17.1.jar` from Sept 2024, which CurseForge lists as 1.20.4. MineColonies blueprint formats are version-sensitive, so it was dropped rather than shipped untested. Re-add by pinning that file id if you want to test it against MineColonies 1.1.1300 |

## Version channel notes

Two entries resolved to non-stable builds. Both are normal for the mod in
question but worth knowing:

- **Tinkers' Construct `3.12.1.231`** is a beta, paired with **Mantle
  `1.11.117`** (also beta). Tinkers' has not shipped a non-beta in a long time
  and the pair is designed to match — do not mix a stable Tinkers' with a beta
  Mantle or it will crash.
- **MineColonies `1.1.1300-snapshot`** is from their snapshot channel, which is
  what CurseForge serves as latest and what most MineColonies players run.

## Restored in 2.0

These were cut from v1 purely to satisfy Modrinth's rules, not for technical
reasons. GitHub-only distribution makes them available again:

Twilight Forest · Stylecolonies · SmallColonies · TownTalk · FTB Quests ·
FTB Teams · FTB Library

**Botania** also returns — it was only ever dropped for lacking a NeoForge
1.21.1 build, and has shipped Forge 1.20.1 all along.
