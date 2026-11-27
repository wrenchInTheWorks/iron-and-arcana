// Iron & Arcana — 35% fewer rains in the Overworld (2026-11-27).
//
// Why it rained so much: Serene Seasons' change_weather_frequency (on by
// default) caps the dry spell between rains at max_rain_time for the current
// sub-season, re-rolling any longer vanilla spell into
// [min_rain_time, max_rain_time). Its defaults are 36000 ticks in winter and
// 96000 in spring and summer, so the average dry spell is 24000 ticks in
// winter and 54000 in spring and summer, against vanilla's 96000. Autumn's
// 180000 is vanilla's own maximum, so autumn is vanilla. Rain itself lasts
// 12000-24000 ticks, vanilla and untouched. Share of the time spent raining:
// winter ~43%, spring and summer ~25%, autumn ~16%.
//
// Why not its config: Serene Seasons can only SHORTEN a dry spell. A vanilla
// roll below max_rain_time is kept as it is, so no setting makes the wait
// longer than vanilla's, and autumn could not be reduced at all.
//
// So instead, when a rain is about to begin it is called off with a chance
// that depends on the season, and the next tick rolls a fresh dry spell
// (which Serene Seasons caps as usual). With a mean dry spell C and a mean
// rain R = 18000, letting a start through with probability q gives a cycle of
// C/q + R. Solving C/q + R = (C + R) / 0.65 for 35% fewer rains:
//
//   winter   C =  24000   q = 0.515   call off 48.5%
//   spring   C =  54000   q = 0.582   call off 41.8%
//   summer   C =  54000   q = 0.582   call off 41.8%
//   autumn   C =  96000   q = 0.610   call off 39.0%
//
// Every season ends up with 35% fewer rains and 35% less time raining, and
// Serene Seasons' pattern (winter wettest, autumn driest) is kept. Thunder
// only shows while it rains, so thunderstorms drop by about the same share.
//
// These figures assume Serene Seasons' default season_properties, which the
// pack does not override. If config/sereneseasons/seasons.toml is ever
// shipped with different rain times, recompute them.
//
// A natural start is recognised by its state: vanilla flips the raining flag
// on the tick its countdown reaches 0 and leaves rainTime at 0 until the next
// tick rolls the rain's length. /weather rain sets a length directly, so a
// command is never called off. LevelEvents.tick runs once per tick, after the
// level's own tick, so each start is seen exactly once.

const RAIN_CALL_OFF_CHANCE = {
    WINTER: 0.485,
    SPRING: 0.418,
    SUMMER: 0.418,
    AUTUMN: 0.390,
}

// Without Serene Seasons the weather is vanilla, which is the autumn figure.
const RAIN_CALL_OFF_FALLBACK = 0.390

let SeasonHelper = null
try {
    SeasonHelper = Java.loadClass('sereneseasons.api.season.SeasonHelper')
} catch (e) {
    console.warn(`weather: Serene Seasons not found, calling off ${RAIN_CALL_OFF_FALLBACK} of rains`)
}

function currentSeason(level) {
    if (SeasonHelper == null) return null
    try {
        return String(SeasonHelper.getSeasonState(level).getSeason())
    } catch (e) {
        return null
    }
}

LevelEvents.tick('minecraft:overworld', event => {
    const data = event.level.getLevelData()
    if (!data.isRaining() || data.getRainTime() != 0) return

    const season = currentSeason(event.level)
    const chance = RAIN_CALL_OFF_CHANCE[season] || RAIN_CALL_OFF_FALLBACK
    if (Math.random() < chance) {
        data.setRaining(false)
        console.info(`weather: ${season} rain called off (chance ${chance})`)
    } else {
        console.info(`weather: ${season} rain let through (chance ${chance})`)
    }
})
