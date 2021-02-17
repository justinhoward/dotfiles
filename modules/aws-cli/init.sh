#!/usr/bin/env bash
dcheck aws || return

version="$(aws --version | cut -d' ' -f1 | cut -d/ -f2)"
if [[ "$version" =~ 2.* ]]; then
  if [[ "$dotfiles_shell" == 'zsh' ]]; then
    autoload bashcompinit && bashcompinit
    complete -C $(which aws_completer) aws
  elif [[ "$dotfiles_shell" == 'bash' ]]; then
    complete -C $(which aws_completer) aws
  fi
else
  if [[ "$dotfiles_shell" == 'zsh' ]]; then
    dcheck aws_zsh_completer.sh && source `which aws_zsh_completer.sh`
  elif [[ "$dotfiles_shell" == 'bash' ]]; then
    dcheck aws_completer && complete -C `which aws_completer` aws
  fi
fi

if [[ "$dotfiles_shell" == 'zsh' ]]; then
  dcheck aws_zsh_completer.sh && source `which aws_zsh_completer.sh`
elif [[ "$dotfiles_shell" == 'bash' ]]; then
  dcheck aws_completer && complete -C `which aws_completer` aws
fi
