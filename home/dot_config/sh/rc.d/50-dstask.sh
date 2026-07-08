# dstask aliases — shell-agnostic. (Completion is wired per-shell in the rc.)
command -v dstask >/dev/null 2>&1 || return

alias t='dstask'
alias ta='t add'
alias tl='t log'
alias to='t open'
alias tn='t note'
alias tm='t modify'
alias te='t edit'
alias ts='t start'
alias tS='t stop'
alias td='t done'
alias tD='t remove'
alias tp='t sync'
alias tc='t context'

# Views
alias tvr='t show-resolved'
alias tva='t show-active'
alias tvp='t show-paused'
