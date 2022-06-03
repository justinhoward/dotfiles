#!/usr/bin/env bash

[[ "$dotfiles_shell" != 'zsh' ]] && return 1

# Add our own autoloads
fpath=("$DOTFILES_PATH"/modules/prezto/autoload "${fpath[@]}")
for func in "$DOTFILES_PATH"/modules/prezto/autoload/*; do
  autoload "$func"
done
unset func

dconfig prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  . "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
