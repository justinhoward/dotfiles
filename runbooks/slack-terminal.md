# Slack / terminal

A Sonokai/Everforest and Victor Mono theme for native macOS Slack, applied by a
local CSS watcher without modifying the app bundle.

## Install

Install Node 22+, run `chezmoi apply`, quit Slack with **Cmd+Q** after saving work,
and launch `~/.config/skhd/scripts/slack_terminal.sh` or use **skhd app mode → s**.
Set Slack's color mode to **System**; edits to
`~/.config/slack-terminal/slack-terminal.css` reload automatically. Run
`node ~/.config/slack-terminal/slack-terminal.mjs` with `status`, `enable`,
`disable`, or `stop` to control the watcher. It opens a loopback DevTools port:
use only on a trusted machine where workspace policy allows debugging. Stopping
the watcher does not close that port; quit Slack and relaunch normally to close
debugging access.
