// Iron & Arcana — hide uncraftable Project Red items from JEI.
//
// Removing a recipe does not remove the item from JEI's item list: it just
// leaves an entry with no recipes, which reads as a bug rather than a choice.
// This hides the ones that can never be obtained.
//
// Client-side on purpose — JEI's item list is a client concern, so this lives
// in client_scripts rather than server_scripts. KubeJS ships its own JEI
// integration (JEIEvents), so no extra addon is needed.
//
// Keep this in step with server_scripts/projectred_backpacks.js and
// server_scripts/projectred_gear.js. If a recipe is restored there, drop the
// matching line here or the item becomes craftable but invisible.

const PR_COLOURS = [
    'white', 'orange', 'magenta', 'light_blue',
    'yellow', 'lime', 'pink', 'gray',
    'light_gray', 'cyan', 'purple', 'blue',
    'brown', 'green', 'red', 'black'
]

const PR_GEMS = ['ruby', 'sapphire', 'peridot']

const PR_ARMOUR_PIECES = ['helmet', 'chestplate', 'leggings', 'boots']

// Project Red's basalt line is dead content, not a duplicate of vanilla's.
// Nothing generates it — MarbleCaveWorldCarver places marble and never
// references basalt — and no recipe produces basalt_cobble, which the whole
// chain roots on. So all six are unobtainable in survival and only serve to
// put a second, identical-looking "Basalt" next to minecraft:basalt.
const PR_DEAD_BASALT = [
    'basalt', 'basalt_cobble', 'basalt_brick',
    'basalt_wall', 'basalt_cobble_wall', 'basalt_brick_wall'
]

JEIEvents.hideItems(event => {
    // storage — recipes removed in projectred_backpacks.js
    PR_COLOURS.forEach(colour => {
        event.hide(`projectred_exploration:${colour}_backpack`)
    })

    // armour — recipes removed in projectred_gear.js. Tools are NOT hidden;
    // they are still craftable on purpose.
    PR_GEMS.forEach(gem => {
        PR_ARMOUR_PIECES.forEach(piece => {
            event.hide(`projectred_exploration:${gem}_${piece}`)
        })
    })

    // unobtainable regardless of any recipe removal here
    PR_DEAD_BASALT.forEach(block => {
        event.hide(`projectred_exploration:${block}`)
    })
})
