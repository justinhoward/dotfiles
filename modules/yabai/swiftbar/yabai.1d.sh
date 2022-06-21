#!/usr/bin/env bash

# <bitbar.title>Yabai-Spaces</bitbar.title>
# <bitbar.version>v1.5</bitbar.version>
# <bitbar.author>Shrey Choudhary</bitbar.author>
# <bitbar.author.github>SxC97</bitbar.author.github>
# <bitbar.desc>Plugin that displays total number of spaces and highlights the current space.</bitbar.desc>
# <bitbar.dependencies>brew,yabai,skhd,jq,zsh</bitbar.dependencies>

# Info about yabai, see: https://github.com/koekeishiya/yabai
# For skhd, see: https://github.com/koekeishiya/skhd
# Although very little of the original code remains, this plugin was inspired by James Won's "yabai/skhd helper" https://getbitbar.com/plugins/Tools/yabai_skhd.1s.sh

# Sets unicode encoding to UTF-8. Fixes issues with displaying *many* but not *all* unicode charecters.
export LANG="en_EN.UTF-8"

# Exports the plugin to your $PATH to allow execution. Make sure you run `chmod +x yabai.1d.sh` after downloading
export PATH=/usr/local/bin:$PATH

# Stops yabai and skhd
if [[ "$1" = "stop" ]]; then
  brew services stop yabai
  brew services stop skhd
fi

# Restarts yabai and skhd
if [[ "$1" = "restart" ]]; then
  brew services restart yabai
  brew services restart skhd
fi

# Change your color here to one of the options above! $COLOR will be the color of the current space.
# $DEFAULT will be the color of the other spaces

COLOR=$'\e[30;47m'
DEFAULT=$'\e[0;37m'

# Change your icons here! $LEFT and $RIGHT refer to the icons on either end of the bar and $DIV refers to the icon between spaces.
# e.x. if $LEFT='\〈', $RIGHT='\〉', and $DIV='|', your bar would look like this ⟨ ｜ ⟩.
# NOTE: the pipe '｜' is not a valid charecter as it is reserved by Bitbar. Use "vertical line" or "vertical bar" instead.
# List of all Unicode charecters can be found here: https://unicode-table.com/en/
# P.S. Check out the "Math" and "Misc" sections for cool and unique symbols to use!ˈ

# Change your font here! Make sure you only change the stuff on the right of the '='. You can get the exact name of your font from the FontBook application on MacOS.
# A monowidth font (such as FuraCode) is recomended. Ligatures are a plus!

FONT="font='Hack Nerd Font' trim=true size=12 ansi=true"

# Change your space indicies here! Add a space between the indicies if you would like padding.
# Feel free to use this as a template and increase the $SPACES array as you see fit. 
# Make sure you add '' around your elements
# example: SPACES=('I' 'II' 'III' 'IV' 'V' 'VI' 'VII' 'VIII' 'IX' 'X' 'XI' 'XII' 'XIII' 'XIV' 'XV' 'XVI') will give you roman neumerals up to 16 spaces.

SPACE_UNUSED='•'
SPACE_USED='⦿'

# The order that displays should appear in by index
DISPLAYS=(3 1 2)

# Choose weather or not you want to see the type of the current space. i.e. BSP, STACK, or FLOAT
# Options, `true` or `false`

BSP="﩯 "
STACK=" "
FLOAT=" "
SPACELEFT=""
SPACERIGHT=""

# Set left and right separators for displays
DISPLAYLEFT='['
DISPLAYRIGHT='] '

current="$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].index')"
used_spaces="$(yabai -m query --windows | jq -r '[.[]["space"]] | unique | join(" ")')"

TYPE="$(yabai -m query --spaces --space | jq -r .type)"

readarray -t all_display_spaces < <(yabai -m query --displays | jq -r '. | sort_by(.index)[] | [.index, .spaces[]] | join(" ")')
string="$DEFAULT$LEFT" 

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
      space_str="$COLOR$SELECTLEFT$space_str$SELECTRIGHT$DEFAULT"
    else
      space_str="$DIV$space_str"
    fi

    if [[ "$i" -eq 0 ]]; then
      space_str="$DISPLAYLEFT$space_str"
    fi

    if [[ "$i" -eq $(( ${#display_spaces[@]} - 1 )) ]]; then
      space_str="$space_str$DISPLAYRIGHT"
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

string+="$RIGHT"

if [[ $TYPE == bsp ]]; then
  TYPE=$BSP
elif [[ $TYPE == stack ]]; then
  TYPE=$STACK
elif [[ $TYPE == float ]]; then
  TYPE=$FLOAT
else
  TYPE=''
fi

string=$string$SPACELEFT$TYPE$SPACERIGHT

echo "$string |" "${FONT[@]}"
echo "---"
echo "Restart yabai & skhd | bash='$0' param1=restart terminal=false"
echo "Stop yabai & skhd | bash='$0' param1=stop terminal=false"

