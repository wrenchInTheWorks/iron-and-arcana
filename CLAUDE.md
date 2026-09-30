# Iron & Arcana — Claude Handover Document
**NeoForge 1.21.1 | v1.2.3 | Small friend server**

---

## Pack Identity

| Field | Value |
|---|---|
| Name | Iron & Arcana |
| Version | 1.2.3 |
| Minecraft | 1.21.1 |
| Loader | NeoForge 21.1.228 |
| Author | iron-and-arcana |
| Description | A colony-building, engineering, and exploration pack for a small friend server. |
| Modrinth | Published (icon must be set on the website — not via packwiz) |
| GitHub | `C:\Users\email\Documents\Git\Iron & Arcana` (remote: origin/main) |

---

## Directory Layout

| Path | Purpose |
|---|---|
| `C:\Users\email\Documents\Git\Iron & Arcana\` | packwiz project root, git repo |
| `C:\Users\email\Desktop\I&A MC Server\` | Local server for testing |
| `C:\Users\email\Desktop\I&A MC Server\kubejs\` | All KubeJS scripts and data overrides |
| `C:\Users\email\Desktop\I&A MC Server\world\datapacks\ia-silentgear-fixes\` | World datapack (redundant Silent Gear overrides) |

> The server directory is **not** in the git repo. KubeJS files live in the server folder and must be manually synced to the hosted server via `python server_sync.py push` (pushes `kubejs/`, `mods/`, `config/`).
> The world datapack (`ia-silentgear-fixes`) is **not** pushed by the sync script — needs manual SFTP to hosted server.

---

## Key Tools & Workflow

```bash
# Rebuild mrpack after any pack changes:
cd "C:\Users\email\Documents\Git\Iron & Arcana"
packwiz refresh
packwiz modrinth export
# Output: Iron & Arcana-1.2.3.mrpack

# Restart local server:
cd "C:\Users\email\Desktop\I&A MC Server"
.\run.bat

# Push kubejs/mods/config to hosted server:
python server_sync.py push
```

**KubeJS reload** (in-game) only reloads `startup_scripts/` and `server_scripts/`. The `kubejs/data/` folder is validated at **server startup only** — always do a full restart when changing data overrides.

---

## What Has Been Done (v1.0 → v1.2.3)

### 1. Tag Fixes (KubeJS server_scripts)
Immersive Engineering's aluminum and refined iron ingots were not registered under the common NeoForge tags, breaking Silent Gear material discovery and recipe unification.

**Fix:** `kubejs/server_scripts/main.js`
```js
ServerEvents.tags('item', event => {
    event.add('c:ingots/aluminum', 'immersiveengineering:ingot_aluminum')
    event.add('c:ingots/refined_iron', 'immersiveengineering:ingot_iron_refined')
})
```

---

### 2. Sophisticated Backpacks / Storage — Disabled Upgrades

**Intent:** Remove upgrades that shortcut automation gameplay intended for Immersive Engineering and Create. Players should build autocraft setups; not drop a single upgrade into a backpack to achieve the same result.

**Method:** `ServerEvents.recipes(event => event.remove({ output: id }))` — removes ALL recipes producing the item (main, alternate, cross-conversion) in one call.

**Also:** `ClientEvents.hideEmiStacks(event => event.hide(Item.of(id)))` hides the items from EMI so they don't appear as obtainable.

**Files:**
- `kubejs/server_scripts/main.js` — recipe removals
- `kubejs/client_scripts/main.js` — EMI hiding

**Removed upgrades (29 items total):**

| Upgrade | Backpacks | Storage | Reason |
|---|---|---|---|
| feeding / advanced_feeding | ✅ removed | ✅ removed | Auto-feeds player |
| inception | ✅ removed | — | Backpack-in-backpack |
| everlasting | ✅ removed | — | Infinite durability |
| pump / advanced_pump | ✅ removed | — | Auto-fills/drains fluid tank |
| magnet / advanced_magnet | ✅ removed | ✅ removed | Item magnet |
| compacting / advanced_compacting | ✅ removed | ✅ removed | Auto-compacts ingots→blocks |
| void / advanced_void | ✅ removed | ✅ removed | Auto-voids excess items |
| auto_smelting | ✅ removed | ✅ removed | Auto-smelts items |
| auto_blasting | ✅ removed | ✅ removed | Auto-blasts items |
| auto_smoking | ✅ removed | ✅ removed | Auto-smokes items |
| alchemy / advanced_alchemy | ✅ removed | ✅ removed | Auto-brews potions |

**Kept:** All non-auto upgrades — filter, stack, sort, pickup, deposit, restock, tank, battery, etc.
**Kept:** `deposit_upgrade` (requires manual keypress to deposit to storage — not automation).
**Deferred:** Stack upgrades and slots-per-tier balance pass — explicitly deferred by user, to be done separately.

> **Note:** `ClientEvents.hideEmiStacks` — verify this event name is correct for KubeJS 2101.7.2. If items still show in EMI after testing, the event name may need updating.

---

### 3. Silent Gear Material Overrides

**Intent:** Disable Silent Gear materials whose source mods are not in the pack. These would show in the Materials Book as gear materials, confuse players, and reference items that don't exist.

**Mods NOT in the pack (18 materials disabled):**
- Mekanism: signalum, lumium, enderium, osmium, refined_obsidian, refined_glowstone
- Mekanism Generators: (covered above)  
- Thermal Series: bismuth, bismuth_brass, bismuth_steel, platinum, titanium, tin, invar
- Immersive Engineering extra: compressed_iron, redstone_alloy, aluminum_steel
- Silent Gear defaults: barrier, example

**Method — critical detail:**
Silent Gear's `isValid()` checks `ingredient.isEmpty()` AND `ingredient.hasNoItems()`. The distinction matters:
- Undefined tag → `isEmpty()=true` → `isValid()=true` → material **shows** (wrong)
- Tag exists but empty → `isEmpty()=false`, `hasNoItems()=true` → `isValid()=false` → material **hidden** (correct)

**Two-part fix (both must be present):**

**Part A** — Override each material JSON to use the dummy tag:
`kubejs/data/silentgear/silentgear_materials/<name>.json`
```json
{
  "type": "silentgear:simple",
  "parent": "silentgear:empty",
  "crafting": {
    "can_salvage": false,
    "categories": ["intangible"],
    "gear_type_blacklist": ["silentgear:all"],
    "ingredient": {"tag": "kubejs:hidden_silent_gear_material"},
    "part_substitutes": {}
  },
  "display": {
    "color": "#FFFFFFFF",
    "main_texture_type": "LOW_CONTRAST",
    "name": {"translate": "material.silentgear.example"},
    "name_prefix": ""
  },
  "properties": {}
}
```

**Part B** — Make the dummy tag exist-but-empty (CRITICAL):
`kubejs/data/kubejs/tags/item/hidden_silent_gear_material.json`
```json
{
  "replace": false,
  "values": []
}
```
Without this file, NeoForge treats the tag as undefined → `isEmpty()=true` → materials still show.

**Redundant world datapack** at `world/datapacks/ia-silentgear-fixes/` contains the same 18 JSON files. This was added as a fallback. The KubeJS data folder is the primary override source (confirmed in server logs: "KubeJS File Resource Pack [data]").

> **Status:** Fix applied but not yet confirmed in-game. This was the most recent change before the v1.2.3 mrpack export. **Restart server and verify Materials Book shows only pack-relevant materials.**

---

## Pending Tests (After v1.2.3 Build)

Test in this order after restarting the local server:

1. **Silent Gear Materials Book** — open the book, confirm the 18 disabled materials do NOT appear. Aluminum and refined_iron SHOULD appear (they are IE materials and the tag fix makes them work).
2. **Sophisticated upgrade recipes** — try to craft any removed upgrade (e.g. `sophisticatedbackpacks:magnet_upgrade`). Should give "no recipe" result.
3. **EMI item list** — open EMI, search for removed upgrade names. Should return no results.
4. **Pack icon** — launch the mrpack in a launcher, confirm the Iron & Arcana icon shows on the pack card.
5. **Tag fixes** — in Silent Gear's Materials Book, confirm `aluminum` and `refined_iron` show as available materials.

---

## Pending Work (Deferred)

These are confirmed tasks that have been explicitly deferred — not forgotten, not done yet.

| Task | Notes |
|---|---|
| Sophisticated Storage stack/slots per tier balance pass | Explicitly deferred by user until after general upgrade pass |
| Silent Gear balance — quartz/Haste III ring (ungraded) | User crafted ungraded ring; deferred for separate balance session |
| Silent Gear rod substitute flashing visual bug | Deferred |
| KubeJS recipe fixes running list | User is building a list of broken recipes to fix all at once. Includes Silent Gear repair kit crafting. |
| BlueMap default map | Change `defaultMap: "world"` in `config/bluemap/webapp.conf` on hosted server |
| Discord onboarding automation | Whitelist bot setup — deferred |
| World datapack sync to hosted server | `world/datapacks/ia-silentgear-fixes/` is NOT in `server_sync.py`'s PUSH_DIRS — must be manually SFTP'd |
| EMI event name verification | Confirm `ClientEvents.hideEmiStacks` is correct for KubeJS 2101.7.2 |

---

## Key Technical Notes

### NeoForge Tag Behaviour
- Tags that are undefined (never declared) are treated differently from tags that exist but are empty. This distinction is critical for any mod that calls `tag.isEmpty()` vs checking for items — see Silent Gear section above.
- KubeJS `ServerEvents.tags` runs after all mod tags are loaded, so additions via this event are safe and final.

### KubeJS Data Folder
- `kubejs/data/` works as a datapack overlay — JSON files here override those from mod JARs.
- Validated at **server startup** only, not on `/kubejs reload`. Always do a full restart when changing data files.
- Confirmed working in logs: "KubeJS File Resource Pack [data]" as the source for overridden materials; "Validated 18 files in kubejs/data/ in 7ms".

### packwiz Icon
- `icon = "..."` is not a valid `pack.toml` field — packwiz will strip it on next `refresh`.
- The Modrinth icon must be set on the project page directly (Project Settings → Icon).
- `icon.png` is tracked in the git repo for reference only.

### Recipe Removal Pattern
```js
// Remove ALL recipes producing an item (main + alternates + cross-conversions):
event.remove({ output: 'mod:item_id' })
// This is better than event.remove({ id: 'recipe_id' }) which only removes one recipe.
```

### Session Lock
If the server fails to start with a file-lock IOException, delete `world/session.lock`. This happens when the server is killed rather than stopped cleanly.

---

## Files Quick Reference

| File | What It Does |
|---|---|
| `kubejs/server_scripts/main.js` | Tag fixes + all recipe removals |
| `kubejs/client_scripts/main.js` | EMI item hiding for removed upgrades |
| `kubejs/data/silentgear/silentgear_materials/*.json` | 18 Silent Gear material overrides (→ hidden) |
| `kubejs/data/kubejs/tags/item/hidden_silent_gear_material.json` | Dummy tag (must exist-but-empty) |
| `world/datapacks/ia-silentgear-fixes/` | Redundant world datapack with same 18 material overrides |
| `C:\Users\email\Documents\Git\Iron & Arcana\pack.toml` | packwiz pack metadata |
| `C:\Users\email\Documents\Git\Iron & Arcana\index.toml` | packwiz file index (auto-generated) |
| `C:\Users\email\Documents\Git\Iron & Arcana\SKIPPED.md` | Mods considered and skipped (with reasons) |
| `C:\Users\email\Documents\Git\Iron & Arcana\SERVER_PERFORMANCE_NOTES.md` | Performance tuning notes |
| `C:\Users\email\Documents\Git\Iron & Arcana\iron-and-arcana-packwiz-brief.md` | Original packwiz session brief (full mod list with slugs) |

---

## Pack Philosophy (for future decisions)

This is a **small friend server** (~4–8 players), not a public pack. Design decisions should reflect that:

- **Progression matters** — automation shortcuts that bypass IE/Create gameplay are removed (see Sophisticated upgrades section). Players are expected to build proper factories.
- **Colony is a core pillar** — MineColonies with multiple style packs. Don't add mods that conflict with colony chunk claims or building placement.
- **Magic is secondary** — Ars Nouveau and Botania are present but the pack leans tech. Don't add more magic mods without checking synergy.
- **Performance is a real constraint** — BlueMap, MineColonies AI, and Create contraptions all have CPU cost. Avoid adding more heavy server-side mods without checking SERVER_PERFORMANCE_NOTES.md.
- **Silent Gear is the gear progression system** — do not add other gear mods (Tinkers' Construct, etc.) without user explicitly requesting it.
