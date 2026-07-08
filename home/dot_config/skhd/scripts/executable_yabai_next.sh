#!/usr/bin/env sh
query="${1:-1}"
if [ "$query" = first ]; then
  selector="| .[0]"
elif [ "$query" = last ]; then
  selector="| .[-1]"
else
  if [ "$query" -lt 0 ]; then
    query=$((0 - query))
  else
    reverse='| reverse'
  fi
  selector="| nth(index(map(select(.\"has-focus\" == true))) - $query)"
fi

yabai -m query --windows --space | jq -re "
  sort_by(.display, .space, .\"stack-index\", .frame.y, .frame.x, .id) 
  | map(select(.\"is-visible\" == true and .role != \"AXUnknown\"))
  $reverse
  $selector
  .id"
