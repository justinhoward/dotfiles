#!/usr/bin/env sh

# Only use this prompt if not zsh
[ "$dotfiles_shell" = 'zsh' ] && return

export PS1="${dwhite}[${dblue}\u${dwhite}@\h${ddefault} ${dcyan}\W${dwhite}]\$${ddefault} "
