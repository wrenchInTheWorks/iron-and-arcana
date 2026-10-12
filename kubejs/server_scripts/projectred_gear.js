// Iron & Arcana — remove Project Red's gem ARMOUR only.
//
// "Tinkers' Construct is the gear progression system ... do not add a third
// gear mod" (CLAUDE.md, Pack Philosophy). Three full armour tiers in ruby,
// sapphire and peridot is that; three sets of simple tools is not, so the
// tools stay craftable.
//
// History worth keeping: the tools were briefly removed too, on the theory
// that Project Red's gems would instead become Tinkers materials. That was
// reverted — datapack-defined materials cannot be melted or cast, because
// fluids can only be registered by a mod, so they sat outside Tinkers'
// progression rather than inside it, and the generated part textures did not
// resolve. The gems are simply Project Red tool materials again.
//
// ProjectRed.cfg has no item toggles, so KubeJS remains the only lever here.

const PR_GEMS = ['ruby', 'sapphire', 'peridot']

const PR_ARMOUR_PIECES = ['helmet', 'chestplate', 'leggings', 'boots']

ServerEvents.recipes(event => {
    // 3 gems x 4 pieces = 12 removals. Tools (sword, pickaxe, axe, shovel,
    // hoe) are deliberately left alone.
    PR_GEMS.forEach(gem => {
        PR_ARMOUR_PIECES.forEach(piece => {
            event.remove({ output: `projectred_exploration:${gem}_${piece}` })
        })
    })
})
