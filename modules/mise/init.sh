#!/usr/bin/env sh

dcheck mise || return

if [ "$dotfiles_shell" = zsh ]; then
  eval "$(mise activate zsh)"
  eval "$(mise completion zsh)"
elif [ "$dotfiles_shell" = bash ]; then
  eval "$(mise activate bash)"
  eval "$(mise completion bash)"
fi
