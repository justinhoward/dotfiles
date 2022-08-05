#!/usr/bin/env bash

browsers=(
  firefox
  google-chrome
  google-chrome-stable
)

for browser in "${browsers[@]}"; do
  if dcheck "$browser"; then
    export BROWSER="$browser"
    break
  fi
done

unset browsers
