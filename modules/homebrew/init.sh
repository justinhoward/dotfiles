#!/usr/bin/env bash

if [ "$dotfiles_platform" = 'osx' ] && [ -e /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  if [ -n "$dotfiles_interactive" ]; then
    if [ "$dotfiles_shell" = zsh ]; then
      FPATH="${HOMEBREW_PREFIX}/share/zsh/site-functions:${FPATH}"
    elif [ "$dotfiles_shell" = bash ]; then
      for completion in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
        [ -r "${completion}" ] && source "${completion}"
      done
    fi
  fi
fi
