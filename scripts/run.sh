#!/usr/bin/env bash

[ -n "$DOTFILES_LOADED" ] && return
[ -z "$DOTFILES_PATH" ] && DOTFILES_PATH="$HOME/.dotfiles"
. "$DOTFILES_PATH"/scripts/load.sh
dconfig modules
devent load

if [ -n "$dotfiles_xorg" ]; then
  devent xorg
else
  if [ -n "$dotfiles_interactive" ]; then
    devent interactive
  fi

  if [ -n "$dotfiles_login" ]; then
    devent login
  fi
fi

DOTFILES_LOADED=1

if [ -n "$dotfiles_xorg" ]; then
  devent xorg_exec
fi
