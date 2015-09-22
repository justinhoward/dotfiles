#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/load.sh
dinstall

echo -e "${dgreen}Dotfiles installed${ddefault}"
