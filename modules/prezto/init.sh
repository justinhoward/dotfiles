#!/usr/bin/env bash

if [[ "$dotfiles_shell" != 'zsh' ]]; then
  return 1
fi

fpath=("$DOTFILES_PATH"/modules/prezto/autoload $fpath)
for func in "$DOTFILES_PATH"/modules/prezto/autoload/*; do
  autoload $func
done

unset func

dconfig prezto

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  . "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

for keymap in 'emacs' 'viins' 'vicmd'; do
  # [Ctrl-RightArrow] - move forward one word
  bindkey -M $keymap '^[[1;5C' forward-word
  # [Ctrl-LeftArrow] - move backward one word
  bindkey -M $keymap '^[[1;5D' backward-word
done

if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey -M viins "$key_info[Control]R" \
    history-incremental-pattern-search-backward
  bindkey -M viins "$key_info[Control]S" \
    history-incremental-pattern-search-forward
fi

unset keymap

if is-callable 'dircolors'; then
  if ! ls --group-directories-first /dev/null >/dev/null 2>&1; then
    unalias ls
  fi
fi
