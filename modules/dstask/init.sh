#!/usr/bin/env sh

dcheck dstask || return

if [ "$dotfiles_shell" = zsh ]; then
  eval "$(dstask zsh-completion)"
elif [ "$dotfiles_shell" = bash ]; then
  eval "$(dstask bash-completion)"
fi

alias t='dstask'
alias ta='t add'
alias tl='t log'
alias to='t open'
alias tn='t note'
alias tm='t modify'
alias te='t edit'
alias ts='t start'
alias td='t done'
alias tD='t remove'
alias tp='t sync' # Push
alias tc='t context'

# View
alias tvr='t show-resolved'
alias tva='t show-active'
alias tvp='t show-paused'
