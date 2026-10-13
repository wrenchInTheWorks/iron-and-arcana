# Discord welcome message — pack 2.3.0

Paste-ready replacement for the pinned welcome post. Rewritten 2026-10-14
against pack **2.3.0** (MC 1.20.1 / Forge 47.4.10 / 117 mods).

Six messages, because Discord's per-message limit is 2000 characters. Each one
below fits inside that limit *including* the `>` quote prefixes, so it can be
copied either way.

## Before posting

| | |
|---|---|
| Server | `play.wrenchintheworks.online` |
| BlueMap | `https://map.wrenchintheworks.online` |

> **Neither address resolves yet.** Checked over DNS-over-HTTPS on 2026-10-14:
> `mc.`, `play.` and `map.wrenchintheworks.online` all return NOERROR with an
> empty answer, and there is no `_minecraft._tcp.play` SRV record. Cloudflare
> is authoritative for the zone, so the records simply have not been created —
> they land when the Linux host comes up with the `cloudflare-ddns` container
> and the tunnel. **Do not post this until both resolve.** A pinned welcome
> post with a dead address is worse than no pinned post.

Two more preconditions, both bot-side:

1. **`/ia config whitelist-role` must be set to `@everyone`.** Unset means
   *closed*, not open, and `/ia whitelist` tells players exactly that. Message
   3 promises self-service whitelisting, so it is a lie until that is set.
2. **`/ia setup` must have been run**, so `/ia map` has a BlueMap URL.

`v2.3.0` is the Latest release and carries both install artifacts, so the
`/releases/latest` links below resolve to the right files.

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

## Message 2 — install

> :gear: **Installation**
>
> Grab **one** of the two files from **[the latest release](https://github.com/wrenchInTheWorks/iron-and-arcana/releases/latest)** — whichever matches your launcher. Both give you the same pack, and either way the launcher downloads Forge and Java 17 for you.
>
> :white_check_mark: **Modrinth App, Prism Launcher or ATLauncher** — `Iron.Arcana-2.3.0.mrpack` *(~170 MB)*
> `Add Instance → Import from file`, pick the `.mrpack`, done. **This is the recommended route** — it's the one the pack is built and tested on.
>
> :orange_circle: **CurseForge launcher** — `Iron.Arcana-2.3.0.zip` *(~400 MB)*
> `Minecraft → Create Custom Profile → Import`, pick the `.zip`.
>
> :warning: **CurseForge will warn you that the pack contains mods it can't verify, and make you approve them. That's expected — approve it.**
> Most of this pack comes from Modrinth rather than CurseForge: only 11 of the 117 mods are CurseForge-hosted, and the other 101 are bundled inside the `.zip` itself. CurseForge can't vouch for files it didn't serve, so it lists them and asks. Nothing is wrong — it's also why that file is more than twice the size of the `.mrpack`.
>
> :bulb: Import as a **new instance** rather than on top of an old one. Reusing an instance leaves stale jars behind, which causes mod-mismatch kicks and launch crashes.
>
> Stuck on any of this? Ask in here — someone will sort you out.

## Message 3 — whitelist and connect

> :unlock: **Whitelist yourself — you don't need to ask anyone**
>
> Run this here in Discord:
> ```
> /ia whitelist YourMinecraftUsername
> ```
> That's it. The bot checks the name with Mojang, adds you to the server, and replies privately — only you see it. You can join immediately.
>
> **Worth knowing**
> • Use your **Java Edition** username. Bedrock accounts can't join this server.
> • One Minecraft account per Discord account. Run it again with a different name and it swaps you over — the old name comes off the whitelist.
> • Mistyped it? Just run it again with the right name.
>
> :satellite: **Connect**
> ```
> play.wrenchintheworks.online
> ```
> No port number needed — paste that straight into *Add Server*.
>
> :map: **Live world map**
> A live 3D map of the world, updating as you build: **[map.wrenchintheworks.online](https://map.wrenchintheworks.online)**
> `/ia map` gets you the link any time, and `/ia info` has the pack details.
>
> :speech_balloon: Chat is bridged both ways — what you type in the Minecraft chat channel reaches players in game, and their chat, joins, leaves and deaths show up here.

## Message 4 — keeping up to date

> :arrows_counterclockwise: **Updates**
>
> The server updates itself from the pack repo every time it restarts. **Your client doesn't** — so when the pack changes you need to update too, or you'll get a mod-mismatch kick. Watch #psa for announcements.
>
> **The simple way:** download the new release and import it as a new instance.
>
> **The better way — auto-updating, Prism Launcher only.** Set this up once and your client syncs itself on every launch:
> 1. Create the instance from the `.mrpack` as normal.
> 2. Download `packwiz-installer-bootstrap.jar` from **[here](https://github.com/packwiz/packwiz-installer-bootstrap/releases)** and put it in the instance's `.minecraft` folder.
> 3. `Edit Instance → Settings → Custom Commands`, tick **Custom Commands**, and set **Pre-launch command** to:
> ```
> "$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/main/pack.toml
> ```
>
> Every launch then adds, removes and updates mods to match the server. No more re-importing and no more mismatch kicks.
>
> Your own settings are safe — the pack ships no `options.txt`, so your video settings, keybinds and resource-pack choices are never touched.
>
> :sparkles: **Shaders** *(optional)* — install **Oculus** alongside the pack; it works with the Embeddium already bundled. Complementary Reimagined suits the pack's lighting best; BSL and Sildur's Vibrant are lighter alternatives.

## Message 5 — what's in the pack

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

## Message 6 — in-game notes

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
> Wires that sit on any block face, bundled cable carrying 16 colours in one line, and real logic parts — timers, counters, sequencers, latches. Get far enough in and Fabrication lets you design a circuit on a workbench and print it to a single gate.
>
> **Seasons are on**
> Serene Seasons, 8 real days per season. Crops only grow in the seasons that suit them, so check before you plant a field of something.
>
> **:skull: On death** — graves. Your items are locked in a grave where you died; they won't burn, despawn or disappear. You can have several at once, so dying on the way back isn't fatal to your stuff.
>
> **The red cross on the server list is normal**
> Hover it and it says "mods are incompatible". It isn't — you'll connect fine. The pack ships 9 mods only to clients (Embeddium, Mouse Tweaks, the JEI add-ons) and 5 only to the server (BlueMap, the YUNG's structure mods), and Forge flags any difference between the two lists. Nothing to fix.
>
> *More notes will be added here as questions come up.*

---

## What changed from the 2.2.0 version of this post

| Change | Why |
|---|---|
| Install split into two labelled routes | The `.zip` exists on every release and nothing told players what it was for |
| CurseForge approval prompt pre-empted, with the real numbers | 101 of 117 jars are bundled, so the warning lists a lot of mods and looks alarming. Explaining it beforehand is cheaper than answering it afterwards |
| Whitelisting rewritten as self-service | It said *"please DM a @Server Admin to get added"*. The bot's `/ia whitelist` now does it, gated on `@everyone` |
| New message on staying updated | The server self-updates and clients do not — that asymmetry is the most likely cause of a confused "it won't let me in" |
| Chat bridge mentioned | It exists and nothing said so |
| Asset filenames corrected | GitHub rewrites `Iron & Arcana-2.3.0.mrpack` to `Iron.Arcana-2.3.0.mrpack`; the old post named a file that does not exist |
| Shaders and the packwiz auto-update route | Were only in the repo README, where no player looks |
| Red-cross example corrected | The old post named *"Embeddium, the minimap, Mouse Tweaks"* as client-only. Xaero's Minimap is `side = "both"`, so it was the wrong example — the pack's 9 client-only mods are Embeddium, Mouse Tweaks, AmbientSounds, Athena, libIPN, Inventory Profiles Next, JER, JEED and JEARGH |
