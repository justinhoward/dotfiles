#!/usr/bin/env bash
dcheck aws || return

if [[ "$dotfiles_shell" == 'zsh' ]]; then
  dcheck aws_zsh_completer.sh && source `which aws_zsh_completer.sh`
elif [[ "$dotfiles_shell" == 'bash' ]]; then
  dcheck aws_completer && complete -C `which aws_completer` aws
fi
