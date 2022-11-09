#!/usr/bin/env bash

# <bitbar.title>Yabai-Spaces</bitbar.title>
# <bitbar.version>v2.0</bitbar.version>
# <bitbar.author>Justin Howard</bitbar.author>
# <bitbar.author.github>justinhoward</bitbar.author.github>
# <bitbar.desc>Plugin for Yabai that displays active spaces and highlights the current space.</bitbar.desc>
# <bitbar.dependencies>brew,yabai,skhd,jq,bash</bitbar.dependencies>

# Inspired by https://github.com/SxC97/Yabai-Spaces

# Sets unicode encoding to UTF-8. Fixes issues with displaying *many* but not *all* unicode charecters.
export LANG="en_EN.UTF-8"
# Exports the plugin to your $PATH to allow execution. Make sure you run `chmod +x yabai.1d.sh` after downloading
export PATH=/usr/local/bin:$PATH

# Restarts yabai and skhd
if [[ "$1" = "restart" ]]; then
  brew services restart yabai
  brew services restart skhd
  exit
fi

# The current space highlight color
HIGHLIGHT=$'\e[30;47m'
# The default text color
DEFAULT_COLOR=$'\e[0;37m'
# Swiftbar options
OPTIONS="font='Victor Mono' trim=true size=12 ansi=true"
# Icon for space with no windows
SPACE_UNUSED='•'
# Icon for space with windows
SPACE_USED='⦿'
# The order that displays should appear in by index
DISPLAYS=(3 1 2)
# Layout icons
BSP="﩯 "
STACK=" "
FLOAT=" "
# Left and right separators for displays
DISPLAY_LEFT='['
DISPLAY_RIGHT='] '

current="$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].index')"
used_spaces="$(yabai -m query --windows | jq -r '[.[]["space"]] | unique | join(" ")')"
layout="$(yabai -m query --spaces --space | jq -r .type)"

readarray -t all_display_spaces < <(yabai -m query --displays | jq -r '. | sort_by(.index)[] | [.index, .spaces[]] | join(" ")')
string="$DEFAULT_COLOR" 

display_strs=()
for display_str in "${all_display_spaces[@]}"; do 
  readarray -d ' ' -t display_parts <<< "$display_str"
  display_index="${display_parts[0]}"
  display_spaces=("${display_parts[@]:1}")
  display_str=''

  i=0
  for space in "${display_spaces[@]}"; do
    space="${space/$'\n'}"
    if [[ " ${used_spaces[*]} " = *" $space "* ]]; then
      space_str="${SPACE_USED}"
    else
      space_str="${SPACE_UNUSED}"
    fi

    if [[ "$space" -eq "$current" ]]; then
      space_str="$HIGHLIGHT$space_str$DEFAULT_COLOR"
    fi

    if [[ "$i" -eq 0 ]]; then
      space_str="$DISPLAY_LEFT$space_str"
    fi

    if [[ "$i" -eq $(( ${#display_spaces[@]} - 1 )) ]]; then
      space_str="$space_str$DISPLAY_RIGHT"
    else
      space_str+=' '
    fi

    display_str+="$space_str"
    i=$(( i + 1 ))
  done

  display_strs[${DISPLAYS[$display_index]}]="$display_str"
done

for dstr in "${display_strs[@]}"; do
  string+="$dstr"
done

if [[ $layout == bsp ]]; then
  layout_icon=$BSP
elif [[ $layout == stack ]]; then
  layout_icon=$STACK
elif [[ $layout == float ]]; then
  layout_icon=$FLOAT
else
  layout_icon=''
fi

string=$string$layout_icon

echo "$string | $OPTIONS"
echo "---"
echo "Restart yabai & skhd | bash='$0' param1=restart terminal=false"

