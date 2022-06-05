#!/usr/bin/env bash

devent() {
  local event_modules module reassign

  # We want this to evaluate literally
  # shellcheck disable=2016
  reassign='event_modules=("${devent_'
  reassign+="$1"
  reassign+='[@]}")'
  eval "$reassign"
  for module in "${event_modules[@]}"; do
    dmodload "$module"
  done
}
