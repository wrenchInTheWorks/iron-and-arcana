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
| **Create Aeronautics** | **Requested for 2.0, but impossible.** The mod's own files stop at mc1.21.1 on both CurseForge and Modrinth — zero 1.20.1 files for any loader. The 1.20.1 search hits are unrelated modpacks by other authors that bundle Create addons. | **Replaced by Valkyrien Skies 2 + Clockwork** |

### Flying contraptions on 1.20.1 — the Valkyrien Skies route

Create Aeronautics cannot be used, so 2.0 uses the Valkyrien Skies stack
instead. Both are at **release** quality, where Aeronautics was alpha with
CurseForge distribution disabled:

| Mod | Version | Role | In pack |
|---|---|---|---|
| Valkyrien Skies 2 | `1.20.1-forge-2.4.11` | Physics/airship engine, base dependency | Yes |
| Clockwork | `1.20.1-forge-0.5.6` | Create-integrated flying contraptions | Yes |
| Eureka | `1.20.1-forge-1.6.3` | Simpler buildable airships | No — Clockwork covers the Create-flavoured use case |

> The Modrinth project at slug `clockwork` is a **modpack**, not the mod.
> The mod is `create-clockwork` (project `84USeAvk`), confusingly titled
> "Clockwork". Adding the wrong one fails with a modpack-import error.

Declared ranges, read from the jars: Clockwork needs `create [6.0.7,)` and
`valkyrienskies [2.4.6,)`; VS2 needs `create [6.0.6,)` and **`forge >= 47.2.0`**.
Forge 47.4.10 and Create 6.0.8 satisfy all of them — but note VS2 rules out
older Forge builds, so do not drop below 47.2.0.

### Dynamic lighting — why not Sodium Dynamic Lights

`sodium-dynamic-lights` does have a 1.20.1 Forge build and would nominally pair
with Embeddium. It was **not** chosen: v1 shipped it in 1.0.0 and swapped away
from it in `4eb7d7d` ("swap sodium-dynamic-lights for lambdynamiclights"). Since
LambDynamicLights is unavailable on Forge, the standalone `dynamic-lights` mod
was used instead rather than revisiting a build that already caused a problem.

## Removed after the first playtest build

| Mod | Reason |
|---|---|
| **Valkyrien Skies 2** + **Clockwork** | Removed as too advanced and off-theme for a simple-ish pack. Clockwork had to go with it regardless — it hard-requires `valkyrienskies [2.4.6,)` and cannot load alone. 2.0 therefore has **no flight/airship mod**, since Create Aeronautics has no 1.20.1 release either |
| **Carry On** | Removed by choice |
| **FTB Quests / Teams / Library** | Removed by choice — quests not wanted, and Open Parties and Claims already covers chunk claiming and parties. The 15 authored v1 quest chapters stay in git history at `git show 5a36352^:config/ftbquests/...` |

> Architectury API was **kept** after the FTB removal — KubeJS depends on it.

## Requested but unavailable on 1.20.1 Forge

| Mod | Finding |
|---|---|
| **Sophisticated Backpacks: Ars Compat** | Adds Ars Nouveau Source, Sourcelink, potion and repair upgrades for Sophisticated Backpacks. CurseForge-only (author LuminaCherry) and published for **1.21.1 NeoForge only** — no 1.20.1 Forge build, and not on Modrinth at all. The same author's TaCZ compat does cover 1.20.1, so a backport is possible but does not exist today |

## Excluded on purpose

| Mod | Reason |
|---|---|
| **Silent Gear** + Silent Lib | Replaced by Tinkers' Construct. Weak default material traits, and a Materials Book that advertised materials from mods not in the pack — which needed 18 override JSONs plus a dummy tag to suppress, and was never confirmed fixed in-game |
| **Just Enough Items** | EMI is the pack's recipe viewer. JEI was only ever added in `320c30a` to satisfy a crash and never removed |
| **Just Enough Resources** | Hard-depends on JEI, which would reintroduce the duplicate-viewer conflict. Ore-distribution info is the loss here — re-add JEI+JER together if that matters more than having one viewer |
| **Sodium** | Embeddium is the 1.20.1 Forge equivalent |
| **Sophisticated Core / Storage / Backpacks** + both Create integrations | Dropped at the user's request. 2.0 has no dedicated storage mod — storage is vanilla plus Create logistics. This also makes v1's 29 KubeJS upgrade removals obsolete, which was the bulk of the script surface |
| **Tinkers Reforged** | Hard-requires **JEI** (`jei 15.56.0.204+`), which this pack excludes in favour of EMI — the same trap that removed Just Enough Resources. It crashed the server at startup with "Missing or unsupported mandatory dependencies". Re-adding it means accepting JEI alongside EMI. The other six Tinkers addons are in |
| **Spartan Weaponry** | Dropped at the user's request. Better Combat remains as the combat overhaul. It never integrated with the gear system by design anyway |
| **Create Deco** | **Crashed the server.** Its newest 1.20.1 Forge build is `2.0.3`, from the Create 0.5.1 era — the Create-6 line (2.1.x) shipped only for 1.21.1 NeoForge and 1.20.1 Fabric. It declared a **bare** `create = "6.0.2"` range, which Forge treats as non-binding, so it loaded against Create 6.0.8 anyway and broke Create's Registrate registration: `Registry entry not present: create:chocolate_bucket` in `AllAdvancements.<clinit>`. Decoration is covered by Chipped, Macaw's and Supplementaries |
| **SmallColonies** | Has CurseForge third-party API distribution **disabled**, so packwiz cannot download it. The CI export failed on it, and packwiz-installer would fail the same way on server start. Working around it means committing the author's jar to a public repo, which is the thing they opted out of. Stylecolonies covers the style-pack role |
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
