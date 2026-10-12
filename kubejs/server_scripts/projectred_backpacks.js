// Iron & Arcana — remove Project Red's backpacks.
//
// "Storage is Sophisticated Backpacks only" is a standing pack rule (CLAUDE.md,
// Pack Philosophy). Project Red Exploration ships 16 dyed backpacks, which is a
// parallel storage system.
//
// Why KubeJS rather than a config: ProjectRed.cfg exposes world-gen toggles and
// render/machine settings only — there is nothing for items. This is the case
// the KubeJS escape hatch exists for. Contrast Sophisticated Backpacks, whose
// upgrades ARE config-gated and must NOT be stripped this way.
//
// Exploration is otherwise kept: it is the only source of electrotine, which
// Fabrication's silicon chain needs. The gem tool and armour tiers are
// deliberately left craftable.

const PR_BACKPACK_COLOURS = [
    'white', 'orange', 'magenta', 'light_blue',
    'yellow', 'lime', 'pink', 'gray',
    'light_gray', 'cyan', 'purple', 'blue',
    'brown', 'green', 'red', 'black'
]

ServerEvents.recipes(event => {
    // Remove by OUTPUT, not by recipe id: that catches the main craft plus any
    // alternates or cross-conversions, which an id-based removal would miss.
    PR_BACKPACK_COLOURS.forEach(colour => {
        event.remove({ output: `projectred_exploration:${colour}_backpack` })
    })

    // The re-dye recipe is a custom serializer with no item result, so it has
    // no output to match on and has to go by type.
    event.remove({ type: 'projectred_exploration:backpack_dye' })
})
