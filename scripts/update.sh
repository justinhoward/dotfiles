#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/scripts/load.sh

for module in "$DOTFILES_PATH"/modules/*; do
  [[ ! -d $module ]] && return
  dload "$module/update"
done

echo -e "${dgreen}Dotfiles updated${ddefault}"
