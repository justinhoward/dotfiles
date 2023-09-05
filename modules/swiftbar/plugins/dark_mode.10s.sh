#!/usr/bin/env bash

# <bitbar.title>Dark Mode</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Justin Howard</bitbar.author>
# <bitbar.author.github>justinhoward</bitbar.author.github>
# <bitbar.desc>Toggle and display dark mode status</bitbar.desc>
# <bitbar.dependencies>bash,osascript</bitbar.dependencies>

# Sets unicode encoding to UTF-8. Fixes issues with displaying *many* but not *all* unicode characters.
export LANG="en_EN.UTF-8"

# Swiftbar options
OPTIONS="font='Symbols Nerd Font' ansi=true size=16 terminal=false refresh=true bash=osascript \
param0=~/.config/skhd/scripts/toggle_dark_mode.scpt"

dark_icon=''
light_icon=''

if [ "$(osascript -e 'tell app "System Events" to tell appearance preferences to get dark mode')" = 'true' ]; then
  string="$dark_icon"
else
  string="$light_icon"
fi


echo "$string | $OPTIONS"
