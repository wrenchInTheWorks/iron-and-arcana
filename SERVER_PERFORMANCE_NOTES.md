# Iron & Arcana — Server Performance Investigation Notes
_Last updated: 2026-05-16_

## Symptoms
- Entity jitter / choppy movement shortly after logging in
- Periodic MSPT spikes every few seconds
- Server appeared fine after ~5 minutes of play
- Issue was most noticeable at session start, especially after server ran overnight with no players

## Tools Used
- **Spark profiler** — added directly to `mods/` folder (NeoForge 1.21.1 jar from modrinth.com/mod/spark)
- Commands: `/spark profiler start` → wait 30s → `/spark profiler stop`

---

## Root Cause: JVM Warmup

The primary cause of startup jitter is **JVM cold start behaviour**:

1. When no players are online, the server does very little work and the JVM heap stays small
2. When a player logs in, object allocation spikes — GC starts firing every ~4 seconds to keep up
3. Each GC pause briefly freezes the server thread, causing entity jitter
4. After 2–5 minutes, the JIT compiler optimises hot code paths and the heap grows to an efficient size
5. GC settles to every ~10 seconds, MSPT max drops from ~300ms to ~85ms, performance normalises

**This is expected behaviour — not a bug.** The jitter at session start will always be present to some degree and resolves on its own.

---

## Secondary Cause: Autosave Spikes

- World autosave fires every 6000 ticks (~5 minutes)
- Causes a one-off MSPT spike of 300–500ms while chunk data is written to disk
- Becomes more noticeable as the world grows (more explored chunks = more data to save)
- ModernFix (already in pack) mitigates this somewhat with async saving enabled by default

---

## What Was Ruled Out

| Suspected Cause | Finding |
|---|---|
| TPS drops | TPS held solid at 20.00 throughout — not the issue |
| High CPU | Only 5–10% CPU usage — not the issue |
| RAM shortage | 6GB plan, JVM heap correctly set to ~6GB by Modrinth panel |
| Network latency | Base ping is 134ms (consistent, zero packet loss) — acceptable |
| MineColonies AI | Only 3 colonists, negligible pathfinding load |
| Memory cap too low | Modrinth panel injects `-Xmx6000M` at startup — overrides user_jvm_args.txt |

---

## Fixes Applied

### 1. JVM GC Flags (`user_jvm_args.txt` on hosted server)
Replaces default settings. Tunes G1GC to work in smaller increments rather than large stop-the-world pauses:

```
-Xms2G
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:InitiatingHeapOccupancyPercent=15
-XX:SurvivorRatio=32
-XX:MaxTenuringThreshold=1
```

> **Note:** Do NOT add `-Xmx` here — Modrinth panel appends `-Xmx6000M` last and will override it.
> `-Xms2G` pre-allocates 2GB at startup to reduce early GC pressure.

### 2. Simulation Distance Reduced (`server.properties`)
```
simulation-distance=4
view-distance=8
```
Reduces the number of ticking chunks and entities — biggest single TPS improvement available.

---

## Memory Architecture (for reference)

- **Modrinth panel RAM:** 6 GiB (container limit)
- **Java heap max:** 5.9 GB (panel sets `-Xmx6000M`, G1GC reserves ~100MB)
- **Non-heap (Metaspace):** ~480MB — stores class definitions for all loaded mods, normal for this modpack size
- **Heap behaviour:** G1GC dynamically grows heap from `-Xms` up to `-Xmx` as needed. Spark showing e.g. "3 GB" is the current committed size, not the cap.
- **`user_jvm_args.txt` -Xmx is overridden** by the panel — do not set it there

---

## Spark Reading Guide

| Metric | Healthy | Investigate |
|---|---|---|
| TPS (1m) | 20.00 | < 18 |
| MSPT median | < 10ms | > 20ms |
| MSPT max | < 200ms | > 500ms |
| GC Young freq | > 5s | < 2s |
| Ping median | ~130–200ms | > 400ms sustained |

> High Spark ping does not always mean network problems — MSPT spikes delay keepalive processing, artificially inflating the ping reading.

---

## If Jitter Returns — Checklist

1. Log in, wait 5 minutes — does it resolve on its own? → JVM warmup, normal
2. Run `/spark profiler start` → wait 30s → `/spark profiler stop`, check the report URL
3. Check MSPT max — if > 500ms and not resolving, something is wrong
4. Check GC Young frequency — if < 2s, GC is thrashing (memory pressure)
5. Expand "Server thread" in Spark flame graph to find the specific method causing spikes
6. Check Modrinth panel RAM — if approaching 6 GiB total, consider upgrading plan
