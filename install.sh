#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/load.sh

for module in "$DOTFILES_PATH"/modules/*; do
  [[ ! -d $module ]] && return

  dload "$module/install"
  [[ ! -e "$DOTFILES_PATH/config" ]] && mkdir "$DOTFILES_PATH/config"
  dinstall "$module/config" `basename $module` "$DOTFILES_PATH/config"
done

echo -e "${dgreen}Dotfiles installed${ddefault}"
