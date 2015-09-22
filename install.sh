#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/load.sh
denv
dinstall

green='\033[0;32m'
default='\033[0m'
echo -e "${green}Dotfiles installed${default}"
unset green default
