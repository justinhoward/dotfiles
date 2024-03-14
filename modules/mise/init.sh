#!/usr/bin/env sh

dcheck mise || return

if [ "$dotfiles_shell" = zsh ]; then
  eval "$(mise activate zsh)"
elif [ "$dotfiles_shell" = bash ]; then
  eval "$(mise activate bash)"
fi
