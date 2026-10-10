# Server management scripts

Bash scripts for the Ubuntu host. They find the compose file relative to
themselves, so you can run them from anywhere — or drop launchers on the desktop.

```bash
cd ~/iron-and-arcana/server/scripts
./setup.sh
```

If the executable bit is missing after a clone: `chmod +x *.sh`

| Script | What it does |
|---|---|
| `setup.sh` | First run only. Checks Docker, creates `.env`, prompts for whitelist/ops, generates a random RCON password, starts the server |
| `start.sh` | Start the server |
| `stop.sh` | `save-all` over RCON, then stop. Deletes nothing |
| `restart.sh` | Save, wait for GitHub's CDN, restart. **This is also how pack updates are applied.** `--now` skips the wait |
| `logs.sh` | Follow the log. `./logs.sh 500` for more history, `./logs.sh errors` to filter |
| `console.sh` | Server console. Interactive, or `./console.sh list` for one command |
| `shell.sh` | Shell inside the container **as uid 1000** |
| `status.sh` | Container state, players, CPU/RAM, world size, and whether the server matches the repo |
| `files.sh` | Reach `/data` with the server up or down — `path`, `ls`, `cat`, `pull`, `open` |
| `backup.sh` | Stops the server, tars the world to `~/ia-backups`, keeps the last 10, restarts |
| `auto-restart.sh` | Scheduled restart for cron. Warns players, saves, stops; Docker brings it back. `--now` skips warnings |
| `docker-stats.sh` | Host-wide: all containers, resource usage, `system df`, volume sizes |

## Desktop launchers

Create `~/Desktop/IA Start.desktop` (same pattern for stop/restart/logs):

```ini
[Desktop Entry]
Type=Application
Name=IA Server — Start
Exec=gnome-terminal -- bash -c "~/iron-and-arcana/server/scripts/start.sh; read -p 'Press enter'"
Terminal=false
Icon=~/iron-and-arcana/icon.png
```

Then right-click → *Allow Launching*.

## Automatic restarts

No mod is needed. The container runs `restart: unless-stopped`, so a clean
server stop exits Java with code 0 and Docker starts it again immediately --
measured at under 5 seconds. A "restart" is therefore just a graceful stop, and
`auto-restart.sh` is only the warning countdown around it.

```bash
# 05:30 daily. Warnings start then, so the server is actually back ~05:45.
30 5 * * * /home/<user>/iron-and-arcana/server/scripts/auto-restart.sh >> /home/<user>/ia-restart.log 2>&1
```

Warning schedule defaults to 15/10/5/1 minutes and is overridable:
`WARN_MINUTES="30 10 5 1" ./auto-restart.sh`. With nobody online it skips the
countdown and restarts straight away.

**The one thing to be careful about:** `PACKWIZ_URL` means every restart
re-installs the pack from whatever that URL points at. If it points at a branch
head, an unattended 5:30am restart will pick up whatever was last pushed --
including half-finished work. Once friends are relying on the server, point
`PACKWIZ_URL` at a **release tag** instead:

```
PACKWIZ_URL=https://raw.githubusercontent.com/wrenchInTheWorks/iron-and-arcana/v2.1.0/pack.toml
```

Tags are immutable, so scheduled restarts become reproducible and updating
becomes a deliberate one-line `.env` change plus a restart.

## Restarting from in game

`/stop` as an operator is already a restart, for the same reason -- Docker
brings the container back. There is no `/restart` command in vanilla or Forge;
`/stop` is the one to use. Verified 2026-10-11.

Discord Integration is also in the pack, so server control from Discord is
available without adding anything new.

## Two traps these scripts defend against

Both cost real debugging time, so the behaviour is deliberate:

**`restart.sh` waits for the CDN.** `raw.githubusercontent.com` sends
`Cache-Control: max-age=300`. Restarting straight after a push makes
packwiz-installer fetch the **previous** version of changed files — the server
boots healthy and looks correct while running stale config. The script polls
until GitHub serves an `index.toml` matching your local one. Use `--now` only
when you have not just pushed.

**`shell.sh` runs as uid 1000, never root.** Editing a file as root leaves it
root-owned, and the mod that owns it then dies with `AccessDeniedException` on
its next write. This took out Sophisticated Core once already.

## Note on configs

`config/` is shipped by packwiz from the repo, so **edits inside the container
are overwritten on the next restart**. Change configs in the repo and push.

`defaultconfigs/` is different: Forge server-scoped configs live per-world in
`world/serverconfig/`, so those only seed **new** worlds. Changing one on a live
world means stopping the server and copying the file in.
