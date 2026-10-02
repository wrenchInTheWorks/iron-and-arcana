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
