#!/usr/bin/env bash

path="$DOTFILES_PATH"

[[ -z "$path" ]] && path="$HOME/.dotfiles"
source "$path"/scripts/load.sh

[[ ! -e "$path/config" ]] && mkdir "$path/config"
dinstall "$path/scripts/default-modules" modules "$path/config"

for module in "$path"/modules/*; do
  [[ ! -d $module ]] && return

  dinstall "$module/config" `basename $module` "$path/config"
  dload "$module/install"
done

echo -e "${dgreen}Dotfiles installed${ddefault}"
