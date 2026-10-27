# Slack / terminal

A Sonokai/Everforest and Victor Mono theme for native macOS Slack, applied by a
local CSS watcher without modifying the app bundle.

## Install

Install Node 22+, run `chezmoi apply`, and launch
`~/.config/skhd/scripts/slack_terminal.sh` or use **skhd app mode → s**.
Current Slack refuses remote debugging against its normal profile, so the theme
uses a separate profile at `~/.local/share/slack-terminal/profile` (under
`$XDG_DATA_HOME` if set). **Sign in again on the first themed launch.** Your normal
Slack profile is never copied or moved, and normal Slack can remain open.
Override the themed profile with `SLACK_TERMINAL_USER_DATA_DIR` or
`--user-data-dir PATH`; do not point it at Slack's normal profile.
Set Slack's color mode to **System**; edits to
`~/.config/slack-terminal/slack-terminal.css` reload automatically. Run
`node ~/.config/slack-terminal/slack-terminal.mjs` with `status`, `enable`,
`disable`, or `stop` to control the watcher. It opens a loopback DevTools port:
use only on a trusted machine where workspace policy allows debugging. Stopping
the watcher does not close that port; quit Slack and relaunch normally to close
debugging access.

## Troubleshooting

The launcher uses macOS LaunchServices with a separate app instance and waits
about ten seconds for the dedicated profile's actual process and a verified
loopback DevTools listener before starting the watcher. If startup fails, the
hotkey falls back to opening ordinary, unthemed Slack and prints the error when
run from a terminal. To diagnose without that fallback, run
`node ~/.config/slack-terminal/slack-terminal.mjs launch` directly.

After Slack loads, `status` should show `phase: "attached"`, `watcherRunning: true`,
and a positive `applied` count. `waiting` is expected until you finish signing in.
Check `~/.local/state/slack-terminal/watcher.log`
for injection errors (or `$XDG_STATE_HOME/slack-terminal/watcher.log` if set).
If the themed profile is already running without debugging, save work in that
instance, quit it with **Cmd+Q**, and use the themed launcher again; it never
quits either Slack instance automatically. Disabling styling and launching opens
normal Slack; stopping the watcher alone does not close the debugging port.
