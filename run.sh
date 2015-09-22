#!/usr/bin/env bash

[[ -z "$DOTFILES_PATH" ]] && DOTFILES_PATH="$HOME/.dotfiles"
source "$DOTFILES_PATH"/load.sh
dconfig modules
devent load

if [[ -n $dotfiles_xorg ]]; then
    devent xorg
else
    if [[ -n $dotfiles_interactive ]]; then
        devent interactive
    fi

    if [[ -n $dotfiles_login ]]; then
        devent login
    fi
fi

if [[ -n $dotfiles_xorg ]]; then
	devent xorg_exec
fi
