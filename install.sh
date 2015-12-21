#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/load.sh

[[ ! -e "$DOTFILES_PATH/config" ]] && mkdir "$DOTFILES_PATH/config"
dinstall default-modules modules config

for module in "$DOTFILES_PATH"/modules/*; do
  [[ ! -d $module ]] && return

  dinstall "$module/config" `basename $module` "$DOTFILES_PATH/config"
  dload "$module/install"
done

echo -e "${dgreen}Dotfiles installed${ddefault}"
