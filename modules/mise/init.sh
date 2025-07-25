#!/usr/bin/env bash

dcheck mise || return

[ "$dotfiles_shell" != zsh ] && [ "$dotfiles_shell" != bash ] && return

eval "$(mise activate "$dotfiles_shell")"

# Mise gets called twice, once in the login event, and another time
# in the interactive event. We want to wait for the interactive event
# to load completions
if [ "$dotfiles_event" = "interactive" ]; then
  eval "$(mise completion "$dotfiles_shell")"
fi

