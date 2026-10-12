// Iron & Arcana — remove Project Red's gem tool and armour tiers.
//
// "Tinkers' Construct is the gear progression system ... do not add a third
// gear mod" (CLAUDE.md, Pack Philosophy). Project Red Exploration ships three
// complete vanilla-style tiers in ruby, sapphire and peridot — 9 pieces each,
// tools and armour — which is exactly that.
//
// The gems themselves stay craftable and keep generating; they are Project Red
// crafting components, and the intent is that gem value flows into Tinkers
// rather than into a parallel tool tier.
//
// Deliberately NOT removed: saws, sickles, the Athame and the Wool Gin. Those
// are utility tools with no Tinkers equivalent, so they compete with nothing.
// The saws in particular are used for microblock cutting.
//
// As with the backpacks, ProjectRed.cfg has no item toggles, so KubeJS is the
// only lever available here.

const PR_GEMS = ['ruby', 'sapphire', 'peridot']

const PR_GEAR_PIECES = [
    'sword', 'pickaxe', 'axe', 'shovel', 'hoe',
    'helmet', 'chestplate', 'leggings', 'boots'
]

ServerEvents.recipes(event => {
    // 3 gems x 9 pieces = 27 removals. Removing by output rather than recipe id
    // catches alternates too.
    PR_GEMS.forEach(gem => {
        PR_GEAR_PIECES.forEach(piece => {
            event.remove({ output: `projectred_exploration:${gem}_${piece}` })
        })
    })
})
