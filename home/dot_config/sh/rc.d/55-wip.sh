# shellcheck shell=sh
# wip aliases — shell-agnostic. (The `wip` function and completion come from
# `wip shell-init`, wired per-shell in the rc; these go through the function,
# so `wo` can cd.) Each is w + the command's first letter; uppercase is its
# opposite or bigger variant. Where two commands share a letter, the more
# used one has it and the other takes its first two letters.
command -v wip >/dev/null 2>&1 || return

alias w='wip'                              # shadows /usr/bin/w (who's logged in)
alias wl='w ls'
alias wL='w ls --parked'
alias ws='w search'
alias wS='w search --all'
alias wsh='w show'
alias wit='w item'
alias wn='w new'
alias wN='w new -c'                        # …then open it and launch an agent
alias wno='w note'
alias wo='w open'                          # wo -w: its PR in the browser
alias wO='w open -c'                       # …and continue its agent session
alias wd='w do'                            # the next action `wip ls` labels
alias wr='w rename'
alias wx='w done'

# Items on a task
alias wa='w attach'
alias wA='w detach'

# Set aside / back on your plate
alias wp='w park'
alias wP='w unpark'

# Unclaimed inventory
alias wi='w ignore'
alias wI='w unignore'
