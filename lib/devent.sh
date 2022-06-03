#!/usr/bin/env bash

devent() {
  local event_modules module reassign

  reassign='event_modules=("${devent_'
  reassign+="$1"
  reassign+='[@]}")'
  eval "$reassign"
  for module in "${event_modules[@]}"; do
    dmodload "$module"
  done
}
