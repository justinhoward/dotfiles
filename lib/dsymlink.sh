#!/usr/bin/env bash

dsymlink() {
  local relTarget="$1" link="$2" target

  target="$DOTFILES_PATH/$relTarget"

  dbackup "$link"

  if [ ! -e "$target" ] || [ "$(readlink "$link")" != "$target" ]; then
    local dir
    dir="$(dirname "$link")"
    if [ ! -d "$dir" ]; then
      echo "Creating directory $dir"
      mkdir -p "$dir"
    fi

    echo "Symlinking $link => $target"
    ln -sf "$target" "$link"
  fi
}
