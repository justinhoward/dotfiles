#!/usr/bin/env bash

# <bitbar.title>AeroSpace-Spaces</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Justin Howard</bitbar.author>
# <bitbar.author.github>justinhoward</bitbar.author.github>
# <bitbar.desc>Compact occupied/visible workspaces for AeroSpace, grouped by screen.</bitbar.desc>
# <bitbar.dependencies>aerospace,jq,bash</bitbar.dependencies>

# Inspired by https://github.com/SxC97/Yabai-Spaces

# Sets unicode encoding to UTF-8. Fixes issues with displaying *many* but not *all* unicode characters.
export LANG="en_EN.UTF-8"
# SwiftBar may not inherit the shell PATH. Preserve existing entries first.
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"

# The current space highlight color
HIGHLIGHT=$'\e[30;47m'
# The default text color
DEFAULT_COLOR=$'\e[0m'
# Swiftbar options
OPTIONS="font='Victor Mono' trim=true size=12 ansi=true refresh=true"
# Icon for space with no windows
SPACE_UNUSED='•'
# Icon for space with windows
SPACE_USED='⦿'
# Layout icons
BSP="󰕰 "
STACK="󰌨 "
FLOAT=" "
# Left and right separators for displays
DISPLAY_LEFT='['
DISPLAY_RIGHT='] '

# AeroSpace's queries are read-only and include parked windows. Polling catches
# new/closed windows and layout changes that don't switch workspaces.
case "${1:-}" in
  '') ;;
  reload-aerospace) exec aerospace reload-config ;;
  *) echo "Unknown AeroSpace plugin action: $1" >&2; exit 2 ;;
esac

if command -v aerospace >/dev/null 2>&1 && \
    workspaces="$(aerospace list-workspaces --all \
      --format '%{workspace} %{monitor-id} %{workspace-is-focused} %{workspace-is-visible}' \
      --json 2>/dev/null)"; then
  if ! windows="$(aerospace list-windows --all --format '%{workspace}' --json 2>/dev/null)" || \
      ! rows="$(printf '%s' "$workspaces" | jq -r --argjson windows "$windows" '
        if type != "array" or ($windows | type) != "array" then
          error("Expected workspace/window arrays")
        else
          ([$windows[].workspace] | unique) as $used |
          [.[] | .workspace as $name |
            . + {occupied: ($used | index($name) != null)} |
            select(.occupied or ."workspace-is-visible")] |
          sort_by(."monitor-id", .workspace)[] |
          [."monitor-id", .occupied, ."workspace-is-focused"] | @tsv
        end
      ' 2>/dev/null)"; then
    echo "Spaces unavailable | $OPTIONS"
    exit 0
  fi

  string="$DEFAULT_COLOR"
  last_monitor=''
  while IFS=$'\t' read -r monitor occupied focused; do
    [[ -n "$monitor" ]] || continue
    if [[ "$monitor" != "$last_monitor" ]]; then
      [[ -z "$last_monitor" ]] || string+="$DISPLAY_RIGHT"
      string+="$DISPLAY_LEFT"
      last_monitor="$monitor"
    else
      string+=' '
    fi
    if [[ "$occupied" = true ]]; then
      space_str="$SPACE_USED"
    else
      space_str="$SPACE_UNUSED"
    fi
    [[ "$focused" != true ]] || space_str="$HIGHLIGHT$space_str$DEFAULT_COLOR"
    string+="$space_str"
  done <<< "$rows"
  if [[ -z "$last_monitor" ]]; then
    echo "Spaces unavailable | $OPTIONS"
    exit 0
  fi
  string+="$DISPLAY_RIGHT"

  layout="$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)"
  case "$layout" in
    h_tiles|v_tiles) string+="$BSP" ;;
    h_accordion|v_accordion) string+="$STACK" ;;
    floating) string+="$FLOAT" ;;
  esac
  echo "$string | $OPTIONS"
  echo '---'
  echo 'AeroSpace workspaces'
  # Names in the menu explain slot gaps (1, 3 aren't renumbered to 1, 2).
  # Sanitize SwiftBar's line/parameter delimiters; these are read-only labels.
  printf '%s' "$workspaces" | jq -r --argjson windows "$windows" '
    ([$windows[].workspace] | unique) as $used |
    sort_by(."monitor-id", .workspace)[] |
    .workspace as $name |
    select(."workspace-is-visible" or ($used | index($name) != null)) |
    "Monitor \(."monitor-id"): \($name | gsub("[\\r\\n|]"; " "))"
  '
  echo '---'
  echo "Reload AeroSpace config | bash='$0' param1=reload-aerospace terminal=false refresh=true"
  exit 0
fi

echo "Spaces unavailable | $OPTIONS"
