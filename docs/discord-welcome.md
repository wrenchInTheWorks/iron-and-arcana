# Discord welcome message — pack 2.1.0

Paste-ready replacement for the pinned welcome post. Written 2026-10-11 against
pack **2.1.0** (MC 1.20.1 / Forge 47.4.10 / 112 mods).

**Two placeholders must be filled before posting** — marked `<<< >>>` below:
the server address and the BlueMap URL. The old `fuzzy-horse364.modrinth.gg`
host is from the Modrinth-hosted v1 server and is dead; the new address depends
on the Cloudflare/DDNS setup on the Linux box.

**Also check before posting:** the Releases link points at `/releases/latest`,
which currently serves **v1.2.3** — the old 1.21.1 NeoForge pack, which cannot
join this server. Either cut a 2.x release first, or replace that step with
"ask an admin for the `.mrpack`".

Discord's per-message limit is 2000 characters, so this is split into the
messages it was already split into.

---

## Message 1 — intro

> :crossed_swords: **Iron & Arcana — Welcome!**
>
> *Iron & Arcana is a small friend server built around one question: what happens when a medieval colony, a sprawling factory floor, and an arcane workshop all exist in the same world?*
>
> You'll start the way everyone does — punching trees, finding shelter, figuring out where you are. But the world you've landed in isn't vanilla. Terralith has rewritten the terrain from the ground up; rolling steppes, ancient highlands, and dense volcanic ranges stretch out in every direction. Deep below, Alex's Caves opens into a separate underground ecosystem — flooded grottos, fungal networks, and things that probably shouldn't exist. Above it all, past the clouds, the Aether waits — and below *that*, the Twilight Forest is its own entire world to get lost in.
>
> The rest is yours to figure out in whatever order makes sense. MineColonies is there if you want to build a settlement and watch it grow into something genuinely lived in. Create is there if you'd rather spend your first week building a machine that does one very specific thing extremely well. Ars Nouveau and Botania are there if you want to ignore both and write spell glyphs or grow a garden of living machinery instead. Nothing is gated behind anything else — it all exists from day one, and it interacts in ways that are fun to stumble into.
>
> The world is dangerous but not punishing. Illager Invasion sends the occasional raid party your way. Bosses of Mass Destruction puts real encounters out there if you go looking. Tinkers' Construct is how you'll arm yourself — you build your tools part by part and they grow with you. But none of it gates your progress: die, collect your grave, carry on.
>
> Do whatever sounds fun. There's no checklist.

## Message 2 — install & connect

> :gear: **Installation**
> 1. Download the latest `.mrpack` from **[GitHub Releases](https://github.com/wrenchInTheWorks/iron-and-arcana/releases/latest)**
> 2. Import it into your launcher — **Prism Launcher**, **ATLauncher** or the **Modrinth App** *(File → Import → select the .mrpack)*
> 3. Launch and connect — no extra steps. The launcher fetches Forge and Java 17 itself.
>
> Import as a **new instance** rather than over an old one — reusing an instance leaves stale jars behind, which causes mod-mismatch kicks.
>
> An @Server Admin can help if you get stuck.
>
> > Check #psa for update announcements. When a new version drops, download the latest release and re-import.
>
> :satellite: **Connection**
> ```
> IP: <<< server address — not yet set >>>
> ```
> *Server is whitelisted — please DM a @Server Admin to get added.*
>
> :map: **Live World Web Map**
> A live, interactive 3D map of the world, from the BlueMap mod.
> **[BlueMap](<<< bluemap url — not yet set >>>)**

## Message 3 — what's in the pack

> :package: **What's in the pack** *(112 mods)*
>
> `Colony` — MineColonies · Structurize · Domum Ornamentum · Stylecolonies · TownTalk
> `Engineering` — Create · Crafts & Additions · Slice & Dice · Steam 'n' Rails
> `Industry` — Immersive Engineering · Immersive Petroleum
> `Gear` — Tinkers' Construct (+ Compatibility, Delight, Jewelry, Levelling, Things, Thinking, Reforged)
> `Magic` — Ars Nouveau · Ars Creo · Botania
> `World` — Terralith · Alex's Caves · Alex's Mobs · The Aether · Deep Aether · Treasure Reforging · Twilight Forest · Serene Seasons
> `Dungeons` — YUNG's Better Dungeons / Strongholds / Mineshafts · Dungeons and Taverns · Bosses of Mass Destruction · Illager Invasion
> `Combat` — Better Combat · Naturalist · Creeper Overhaul · Friends&Foes
> `Redstone` — More Red *(logic gates, counters, timers, wire on any block face)*
> `Food` — Farmer's Delight
> `Storage` — Sophisticated Backpacks
> `Building` — Chipped · Macaw's (Bridges, Roofs, Windows, Doors) · Supplementaries · Amendments
> `QoL` — JEI · JER · Jade · Waystones · Xaero's Minimap & World Map · Lootr · Open Parties & Claims · GraveStone

## Message 4 — in-game notes

> :clipboard: **In-Game Notes**
>
> **The item list looks massive — ignore most of it**
> JEI (the recipe panel on the right) is your friend. Hover any item and press **R** to see how to make it, **U** to see what it's used for. Search for things as you need them and don't worry about the rest.
>
> **Tinkers' is how you make tools**
> Don't craft a vanilla pickaxe and wonder why it's bad. Start with a Crafting Station and the Materials and You book you spawn with — tools are built from parts, and they level up as you use them.
>
> **Backpacks are storage, not automation**
> Sophisticated Backpacks is in, but the automation upgrades (feeding, magnets, auto-smelting, void, the Infinity upgrades and all stack upgrades) are deliberately turned off — building a Create or Immersive Engineering factory *is* the game here. Carrying more than one backpack gives you Slowness.
>
> **Seasons are on**
> Serene Seasons, 8 real days per season. Crops only grow in the seasons that suit them, so check before you plant a field of something.
>
> **:skull: On Death**
> Graves. Your items are locked in a grave where you died — they won't burn, despawn, or disappear. Go get them. You can have multiple graves, so dying on the way back isn't fatal to your stuff.
>
> *More notes will be added here as questions come up.*

---

## What changed from the old message, and why

| Old text | Problem |
|---|---|
| "Silent Gear and Spartan Weaponry give you real options" | Both removed. Tinkers' Construct is the gear system now |
| `Create Aeronautics` in the Engineering list | Never existed for 1.20.1 — the pack has no flight mod |
| `Ars Technic` in the Magic list | 1.21.1 only, not in the pack |
| `Sophisticated Storage` in Storage | Deliberately excluded — Backpacks only |
| `Carry On` in QoL | Removed |
| "EMI (the recipe panel on the right)" | EMI was removed; it's JEI now. The **R** and **U** keys are the same |
| `IP: fuzzy-horse364.modrinth.gg` | The Modrinth-hosted v1 server, now dead |
| BlueMap on `:23904` | Same — old host and port. BlueMap is on `8100` now |
| Releases "latest" | Currently serves v1.2.3, which cannot join this server |
| Mod list generally | Missing Tinkers' and its 7 addons, Botania, Twilight Forest, Deep Aether, More Red, JER, Farmer's Delight, Friends&Foes, Dungeons and Taverns |

Added that weren't covered at all: the Tinkers' pointer (new players reliably
craft a vanilla pickaxe first), the backpack-upgrade explanation (otherwise it
reads as mods being broken), and seasons (otherwise crops look broken).
