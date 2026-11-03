# PSA — v2.4.0

For #psa. One message, 1,576 characters including the quote prefixes, so it
fits Discord's 2,000 limit with 424 to spare.

Release: https://github.com/wrenchInTheWorks/iron-and-arcana/releases/tag/v2.4.0
Tag verified: `v2.4.0` → `b8a2fd0`, which is `main`'s head, 120 mods.

> **Post it only after the server has restarted onto 2.4.0.** Telling people to
> update before the server has is the one ordering that guarantees mismatch
> kicks. Wait out the ~5 minute `raw.githubusercontent.com` cache after the
> push, restart, then post.

The backpack-upgrade line is deliberately specific. `isItemEnabled` is
referenced in exactly one class in the Backpacks jar, `BackpackItem`, and only
next to `addCreativeTabItems` — so disabling an item removes it from the
creative tab (and therefore JEI) and stops its recipe loading, but does **not**
gate the upgrade's behaviour. Upgrades players already own keep working. That
was checked in the jar before promising it.

---

> :mega: **Iron & Arcana v2.4.0 is live**
>
> Update before you next join or you'll get a mod-mismatch kick. Grab it from **[Releases](https://github.com/wrenchInTheWorks/iron-and-arcana/releases/latest)** and import it as a **new** instance — or if you set up the auto-updating Prism route, just launch and it syncs itself.
>
> :seedling: **Seasons no longer block farming**
> Every crop grows in every season now. Serene Seasons still shifts the colours, changes the weather and brings snow in winter — it just doesn't tell you what you're allowed to plant any more.
>
> :package: **New — Sophisticated Storage**
> Chests, barrels and shulker boxes in six tiers, plus a controller that links them into one searchable network. Same rule as backpacks: the automation upgrades (hoppers, compression, stack upgrades) are switched off. Moving items around is Create's job.
>
> :shirt: **New — hide your armour**
> Bind a key under *Options → Controls* and you can toggle your armour's appearance off without taking it off. Purely visual — you keep every point of protection.
>
> :hammer: **Three recipes that silently didn't work are fixed**
> The **Drying Rack**, Tinkers' Thinking's **Stone Stick** and the **Flute** each shared a crafting grid with another mod's item, so only one of each pair could ever be crafted. They have new shapes now — same materials, check JEI.
>
> :warning: **Four backpack upgrades are gone**
> Pump, magnet, compacting and void can't be crafted any more and won't appear in JEI. **Ones you already have keep working** — nothing in your bag breaks.
