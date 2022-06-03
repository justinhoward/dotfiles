#!/usr/bin/env bash

_dmods=()
dmodload() {
  case "${_dmods[@]}" in *"$1"*) return ;; esac
  _dmods+=("$1")

  local module_load_path="$DOTFILES_PATH/modules/$1"

  dload "$module_load_path/init"
}
