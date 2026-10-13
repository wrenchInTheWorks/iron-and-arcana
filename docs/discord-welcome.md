# Discord welcome message — pack 2.3.0

Paste-ready replacement for the pinned welcome post. Updated 2026-10-12 against
pack **2.3.0** (MC 1.20.1 / Forge 47.4.10 / 117 mods).

**No placeholders left — but do not post it until DNS is live.** Both addresses
are filled in with their final values:

| | |
|---|---|
| Server | `play.wrenchintheworks.online` |
| BlueMap | `https://map.wrenchintheworks.online` |

`play.` is an **SRV** record pointing at the `mc.` A record on port 25565, which
is why players type no `:25565` — see step 3 of the
[cloudflare-ddns runbook](https://github.com/wrenchInTheWorks/cloudflare-ddns).
`map.` is a **CNAME** to a Cloudflare Tunnel, so it serves HTTPS on 443 with no
port and no inbound hole. Neither resolves until the DDNS container and the
tunnel are deployed on the Linux box.

The `/releases/latest` link in step 1 is now correct — **v2.2.0** is Latest and
carries a working `.mrpack`. It used to serve v1.2.3, which could not join.

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
> IP: play.wrenchintheworks.online
> ```
> *Server is whitelisted — please DM a @Server Admin to get added.*
>
> :map: **Live World Web Map**
> A live, interactive 3D map of the world, from the BlueMap mod.
> **[BlueMap](https://map.wrenchintheworks.online)**

## Message 3 — what's in the pack

> :package: **What's in the pack** *(117 mods)*
>
> `Colony` — MineColonies · Structurize · Domum Ornamentum · Stylecolonies · TownTalk
> `Engineering` — Create · Crafts & Additions · Slice & Dice · Steam 'n' Rails
> `Industry` — Immersive Engineering · Immersive Petroleum
> `Gear` — Tinkers' Construct (+ Compatibility, Delight, Jewelry, Levelling, Things, Thinking, Reforged)
> `Magic` — Ars Nouveau · Ars Creo · Botania
> `World` — Terralith · Alex's Caves · Alex's Mobs · The Aether · Deep Aether · Treasure Reforging · Twilight Forest · Serene Seasons
> `Dungeons` — YUNG's Better Dungeons / Strongholds / Mineshafts · Dungeons and Taverns · Bosses of Mass Destruction · Illager Invasion
> `Combat` — Better Combat · Naturalist · Creeper Overhaul · Friends&Foes
> `Redstone` — Project Red *(timers, counters, sequencers, bundled cable, and circuits you design yourself)*
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
> **Project Red is the redstone mod, and it goes deep**
> Wires that sit on any block face, bundled cable that carries 16 colours in one line, and proper logic parts — timers, counters, sequencers, latches. If you get far enough in, Fabrication lets you design a circuit on a workbench and print it to a single gate.
>
> **Seasons are on**
> Serene Seasons, 8 real days per season. Crops only grow in the seasons that suit them, so check before you plant a field of something.
>
> **:skull: On Death**
> Graves. Your items are locked in a grave where you died — they won't burn, despawn, or disappear. Go get them. You can have multiple graves, so dying on the way back isn't fatal to your stuff.
>
> **The red cross on the server list is normal**
> Hover it and it says "mods are incompatible". It isn't — you'll connect fine. The pack deliberately ships some mods only to clients (Embeddium, the minimap, Mouse Tweaks) and some only to the server (BlueMap, the YUNG's structure mods), and Forge flags any difference between the two lists. Nothing to fix.
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
| BlueMap on `:23904` | Same — old host and port. It is now `map.wrenchintheworks.online` over HTTPS via a Cloudflare Tunnel, with no port in the URL |
| Releases "latest" | Served v1.2.3, which could not join. Fixed — **v2.2.0** is Latest since 2026-10-11 |
| Mod list generally | Missing Tinkers' and its 7 addons, Botania, Twilight Forest, Deep Aether, More Red, JER, Farmer's Delight, Friends&Foes, Dungeons and Taverns |

Added that weren't covered at all: the Tinkers' pointer (new players reliably
craft a vanilla pickaxe first), the backpack-upgrade explanation (otherwise it
reads as mods being broken), and seasons (otherwise crops look broken).
