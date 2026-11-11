# shellcheck shell=sh
# wip aliases — shell-agnostic. (The `wip` function and completion come from
# `wip shell-init`, wired per-shell in the rc; these go through the function,
# so `wo` can cd.) Uppercase is the opposite or bigger variant.
command -v wip >/dev/null 2>&1 || return

alias w='wip'                              # shadows /usr/bin/w (who's logged in)
alias wl='w ls'
alias wL='w ls --later'
alias ws='w search'
alias wS='w search --all'
alias wn='w new'
alias wv='w show'
alias wo='w open'
alias wd='w done'
alias wm='w note'
alias wr='w rename'

# Items on a task
alias wa='w attach'
alias wx='w detach'

# Set aside / back on your plate
alias wz='w later'
alias wZ='w start'

# Unclaimed inventory
alias wi='w ignore'
alias wI='w unignore'
alias wC='w clean'
