#!/bin/sh
# Launch-or-focus Slack, using the local stylesheet watcher when installed.
set -eu

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
PATH="$data_home/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH

controller="$config_home/slack-terminal/slack-terminal.mjs"
app=${SLACK_TERMINAL_APP:-/Applications/Slack.app}
if [ ! -f "$controller" ] || ! command -v node >/dev/null 2>&1; then
  exec /usr/bin/open -a "$app"
fi

if node "$controller" launch; then
  exit 0
fi
# A missing runtime or invalid cold-start stylesheet must not break the hotkey.
exec /usr/bin/open -a "$app"
