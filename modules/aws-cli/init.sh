#!/usr/bin/env sh

# Allow use of "complete"
# shellcheck disable=3044

dcheck aws || return

if [ "$dotfiles_shell" = 'zsh' ]; then
  autoload bashcompinit && bashcompinit
  complete -C "$(which aws_completer)" aws
elif [ "$dotfiles_shell" = 'bash' ]; then
  complete -C "$(which aws_completer)" aws
fi

if [ "$dotfiles_shell" = 'zsh' ]; then
  dcheck aws_zsh_completer.sh && . "$(which aws_zsh_completer.sh)"
elif [ "$dotfiles_shell" = 'bash' ]; then
  dcheck aws_completer && complete -C "$(which aws_completer)" aws
fi
