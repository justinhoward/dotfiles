#!/usr/bin/env bash

# <bitbar.title>Input Muted</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Justin Howard</bitbar.author>
# <bitbar.author.github>justinhoward</bitbar.author.github>
# <bitbar.desc>Displays if the current audio input is muted</bitbar.desc>
# <bitbar.dependencies>bash,osascript</bitbar.dependencies>

# Sets unicode encoding to UTF-8. Fixes issues with displaying *many* but not *all* unicode characters.
export LANG="en_EN.UTF-8"

# Swiftbar options
OPTIONS="font='Symbols Nerd Font' ansi=true size=16 bash=osascript param0=~/.config/skhd/scripts/toggle_input_mute.scpt terminal=false refresh=true"
RED=$'\e[31m'
DEFAULT_COLOR=$'\e[0m'

unmuted=''
muted=''

if [ "$(osascript -e 'input volume of (get volume settings)')" = 0 ]; then
  string="$RED$muted$DEFAULT_COLOR"
else
  string="$unmuted"
fi


echo "$string | $OPTIONS"
