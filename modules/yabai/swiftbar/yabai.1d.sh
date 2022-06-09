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
export LANG="es_ES.UTF-8"

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

# SPACES=('•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•' '•')
SPACES=({1..16})

# Choose weather or not you want to see the type of the current space. i.e. BSP, STACK, or FLOAT
# Options, `true` or `false`

SPACETYPE=true
BSP="◇"
STACK="◆"
FLOAT="◈"
SPACELEFT=""
SPACERIGHT=""

# Choose weather or not you want to see the type of the window. i.e. floating or managed
# Options, `true` or `false`

WINTYPE=false
WINFLOAT="⦿"
WINMANAGED="⦾"
WINLEFT=" "
WINRIGHT=" "

# Set left and right separators for displays
DISPLAYLEFT='['
DISPLAYRIGHT='] '

# -------------------------------------------------------------------------#
# Don't edit anything below this point if you dont know what you're doing! #
# -------------------------------------------------------------------------#

CURRENT="$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].index')"
SPACES_COUNT="$(yabai -m query --spaces | jq -r '. | length')"

if [ "$SPACETYPE" = true ]; then
  TYPE="$(yabai -m query --spaces --space | jq -r .type)"
fi

if [ "$WINTYPE" = true ]; then
  WINDOW="$(yabai -m query --windows --window | jq -r .floating)" 2> /dev/null
fi

readarray -t DISPLAY_SPACES < <(yabai -m query --displays | jq -r '.[].spaces |join(" ")')
STRING="$DEFAULT$LEFT" 

FIRST_SPACES=()
LAST_SPACES=()
for DISPLAY in "${DISPLAY_SPACES[@]}"; do 
  readarray -d ' ' -t THIS_SPACES <<< "$DISPLAY"
  FIRST_SPACES["${THIS_SPACES[0]}"]=1
  LAST_SPACES["${THIS_SPACES[${#THIS_SPACES[@]} - 1]}"]=1
done

for i in $(seq 0 $(( SPACES_COUNT - 1))); do
  SPACE_STR="${SPACES[$i]}"
  if [ "$i" -eq "$CURRENT" ]; then
    SPACE_STR="$COLOR$SELECTLEFT$SPACE_STR$SELECTRIGHT$DEFAULT"
  else
    SPACE_STR="$DIV$SPACE_STR"
  fi

  if [ -n "${FIRST_SPACES[i + 1]}" ]; then
    SPACE_STR="$DISPLAYLEFT$SPACE_STR"
  fi

  if [ -n "${LAST_SPACES[i + 1]}" ]; then
    SPACE_STR="$SPACE_STR$DISPLAYRIGHT"
  else
    SPACE_STR+=' '
  fi

  STRING+="$SPACE_STR"
done

FINALSTRING="$STRING$RIGHT"


if [[ $TYPE == bsp ]]; then
  TYPE=$BSP
elif [[ $TYPE == stack ]]; then
  TYPE=$STACK
elif [[ $TYPE == float ]]; then
  TYPE=$FLOAT
else
  TYPE=''
fi

if [ -n "$WINDOW" ] && [[ "$WINDOW" -eq "0" ]]; then
  WINDOW="$WINMANAGED"
elif [ -n "$WINDOW" ] && [[ "$WINDOW" -eq "1" ]]; then
  WINDOW="$WINFLOAT"
else
  WINDOW=''
fi

if [[ "$SPACETYPE" = true ]] && [[ "$WINTYPE" = true ]]; then
  FINAL=$FINALSTRING$SPACELEFT$TYPE$SPACERIGHT$WINLEFT$WINDOW$WINRIGHT
elif [[ "$SPACETYPE" = true ]]; then
  FINAL=$FINALSTRING$SPACELEFT$TYPE$SPACERIGHT
elif [[ "$WINTYPE" = true ]]; then
  FINAL=$FINALSTRING$WINLEFT$WINDOW$WINRIGHT
elif [[ "$SPACETYPE" = false ]] && [[ "$WINTYPE" = false ]]; then
  FINAL=$FINALSTRING
fi

echo "$FINAL |" "${FONT[@]}"

echo "---"
echo "Restart yabai & skhd | bash='$0' param1=restart terminal=false"
echo "Stop yabai & skhd | bash='$0' param1=stop terminal=false"

