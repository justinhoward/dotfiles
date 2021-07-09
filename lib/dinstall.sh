#!/usr/bin/env bash

dinstall() {
  local source="$1"
  local name="$2"
  local dest="$3"

  if [ ! -e "$dest/$name.sh" ] && [ -f "$source.sh" ]; then
  	echo "Creating $dest/$name.sh"
  	cp "$source.sh" "$dest/$name.sh"
  fi

  if [ ! -e "$dest/$name" ] && [ -d "$source" ]; then
    echo "Creating $dest/$name"
  	cp -r "$source" "$dest/$name"
  fi
}
