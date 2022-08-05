#!/usr/bin/env sh

if [ "$TERM" = xterm-kitty ]; then
  true
elif [ -n "$dotfiles_virtual" ]; then
  export TERM='xterm-256color'
else
  export TERM='xterm-color'
fi

if [ "$dotfiles_shell" =  "zsh" ]; then
  export KEYTIMEOUT=1
fi
