# Dropped & Skipped Mods

**Current as of pack 2.1.0 (MC 1.20.1 / Forge 47.4.10), 2026-10-11.**
See `docs/v1-mod-inventory.md` for the v1.2.3 snapshot and per-mod dispositions.

---

## No 1.20.1 Forge release

| Mod | Finding | Outcome |
|---|---|---|
| **Create Aeronautics** | Requested for 2.0 but impossible: the mod's own files stop at 1.21.1 on both platforms. The 1.20.1 search hits are unrelated modpacks that bundle Create addons. | Not in pack. **The pack has no flight/airship mod** — see below |
| **MineColonies Tweaks** | No 1.20.1 file, and none for 1.21.1 either. | Not in pack |
| **Create BlueMap** | No 1.20.1 file. Create contraptions will not appear as live map markers. | Not in pack — BlueMap itself works |
| **Engineer's Decor** | Frozen at 1.19.2. | Not in pack. Decoration covered by Chipped, Supplementaries, Macaw's |
| **You're in Grave Danger** | Fabric and NeoForge only. | **Replaced by GraveStone Mod** |
| **LambDynamicLights** | Fabric, NeoForge and Quilt only. | **Replaced by Dynamic Lights** |
| **Ars Technic** | 1.21.1 only. | Not in pack. **Ars Creo** remains, so the Ars↔Create bridge is intact |
| **Prickle** | No 1.20.1 build. Dependency-only library with nothing depending on it. | Not in pack |
| **Sophisticated Backpacks: Ars Compat** | CurseForge-only, published for 1.21.1 NeoForge only. | Not in pack |

---

## Added, then removed

Everything here was in the pack at some point during 2.0/2.1 and was taken back
out for a stated reason. Re-adding any of them means re-litigating that reason.

| Mod | Why it went |
|---|---|
| **Valkyrien Skies 2 + Clockwork** | Added as the Create Aeronautics substitute, then removed as **too advanced and off-theme** for this pack. The pack now deliberately has no flight/airship mod. Do not reintroduce unasked |
| **Create Deco** | **Crashed the server.** Its newest 1.20.1 Forge build (`2.0.3`) is from the Create 0.5.1 era; the Create-6 line never shipped for 1.20.1 Forge. It declared a *bare* `create = "6.0.2"` range, which Forge treats as non-binding, so it loaded against Create 6.0.8 anyway and broke Registrate: `Registry entry not present: create:chocolate_bucket` |
| **Fresh Animations** + Entity Model Features + Entity Texture Features | **Mob rendering lagged badly** in the first test playthrough. ETF/EMF are the per-entity cost, not the resource pack, so all three went. `options.txt` existed only to enable Fresh Animations and went with them |
| **EMI** | Was the pack's recipe viewer through 2.0. Every major mod here ships JEI integration and **none** ship EMI support, so EMI could list their recipes but not draw them — Tinkers casting showed an error panel and Jumbo Furnace drew missing-texture placeholders. Replaced by JEI. See CLAUDE.md "Recipe viewing" for the full measurements |
| **FTB Quests / Teams / Library** | Removed at the owner's request — quests not wanted, and Open Parties & Claims covers chunk claiming. The 15 authored v1 quest chapters remain in git history at `git show 5a36352^:config/ftbquests/...` |
| **Carry On** | Removed at the owner's request |
| **SmallColonies** | Has CurseForge third-party distribution **disabled**, so packwiz cannot download it and CI export fails. Working around it means committing the author's jar to a public repo, which is precisely what they opted out of. Stylecolonies covers the style-pack role |
| **Discord Integration** | Shipped through 2.1.0 but never configured (`active = false`, no token). Removed once the Discord bridge was settled in favour of the Wrench's Toolkit bot reading the server log. DI would need its own second Discord bot application, and its `[[commands]]` system has **no role or permission gating** — verified in the 2.2.3 jar: `CommandConfig` holds only `minecraft_command`, `discord_command`, `description`, `use_parameters`, `enabled`, and one `channel_id` serves both chat and commands, so moderator-only commands are impossible. The pack is now bridge-agnostic and needs no mod for Discord |

---

## Excluded on purpose

| Mod | Reason |
|---|---|
| **Silent Gear** + Silent Lib | Replaced by Tinkers' Construct. Weak default material traits, and a Materials Book advertising materials from absent mods, which needed 18 override JSONs plus a dummy tag to suppress and was never confirmed fixed in-game |
| **Sophisticated Storage** | Deliberately absent. Storage is **Sophisticated Backpacks only**, plus its Create integration |
| **Spartan Weaponry** | Dropped at the owner's request. Better Combat remains as the combat overhaul |
| **Sodium** | Embeddium is the 1.20.1 Forge equivalent and is in the pack |
| **Sable** | Only ever present as a Create Aeronautics dependency |
| **isCyclic StackOverflow Crash Fix** | Band-aid for the 1.21.1 unofficial-port stack. Those ports are now official 1.20.1 builds — re-add only if the crash actually reproduces |
| **Byzantine Styles Pack** | packwiz resolved it to a **1.21.1 jar** because the CurseForge file metadata is mis-tagged. MineColonies blueprint formats are version-sensitive, so it was dropped rather than shipped untested |
| **EventBridge** | The in-house WebSocket event mod. Its source targets **NeoForge 1.21.1**, so using it here means a port across both loader and version. Deferred: the chat bridge is now done bot-side by tailing the server log, which needs no mod at all |

---

## Not added (yet), with a visible symptom

| Mod | Finding |
|---|---|
| **Amendments** | Supplementaries split at version 2.8.0 and moved content into Amendments, so the pack shows a one-time startup warning: *"Amendments is not installed."* Nothing breaks, but ~10 blocks and ~46 items of former Supplementaries content (wall lanterns, hanging flower pots, tool hooks, carpet stairs/slabs, directional and double cake, skull pile, cauldrons) are absent. `amendments-1.20-2.2.6` exists for 1.20.1 Forge, its only hard dependency beyond Forge/Minecraft is Moonlight (already in the pack at 2.16.35), and its worldgen is 3 structure-**tag** files, so it is safe to add mid-world. Not added pending a decision |

## Previously skipped, now in the pack

These were excluded under the old "EMI is the viewer, anything needing JEI is
out" rule. That rule was reversed on 2026-10-10 when it turned out to be
costing the pack most of its recipes, so all three are now in:

| Mod | Previously | Now |
|---|---|---|
| **Just Enough Items (JEI)** | Excluded in favour of EMI | **The pack's recipe viewer** |
| **Just Enough Resources (JER)** | Excluded for hard-depending on JEI | In. Mob drops, dungeon loot, villager trades, plants, and ore distribution |
| **Tinkers Reforged** | Excluded for hard-depending on JEI; it crashed the server with "Missing or unsupported mandatory dependencies" | In. Adds barium, thallium and yttrium ores |

> JER's ore-distribution tab ships **no data** and cannot derive it from the
> worldgen system. **JEARGH** (JER Profiler) is in the pack to restore the
> scan command — it is singleplayer-only, so profiling happens in a local world
> and the resulting `world-gen.json` is committed to `config/`.

---

## Version channel notes

Two entries resolve to non-stable builds. Both are normal for the mod:

- **Tinkers' Construct `3.12.1.231`** is a beta, paired with **Mantle
  `1.11.117`** (also beta). Tinkers' has not shipped a non-beta in a long time
  and the pair is designed to match — do not mix a stable Tinkers' with a beta
  Mantle or it will crash.
- **MineColonies `1.1.1300-snapshot`** is from their snapshot channel, which is
  what CurseForge serves as latest and what most MineColonies players run.

---

## Restored for 2.0

Cut from v1 purely to satisfy Modrinth's publishing rules, not for technical
reasons. GitHub-only distribution makes them available again:

**Twilight Forest · Stylecolonies · TownTalk · Botania**

Botania was only ever dropped for lacking a NeoForge 1.21.1 build, and has
shipped Forge 1.20.1 all along.
