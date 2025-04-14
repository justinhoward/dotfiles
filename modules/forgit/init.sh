dcheck brew || exit

export FORGIT_LOG_GRAPH_ENABLE=false

alias G=git-forgit
alias Gia='git-forgit add'
alias Gbd='git-forgit branch_delete'
alias Gco='git-forgit checkout_branch'
alias Gcc='git-forgit checkout_commit'
alias Gcf='git-forgit checkout_file'
alias Gct='git-forgit checkout_tag'
alias Gcp='git-forgit cherry_pick'
alias Gcpb='git-forgit cherry_pick_from_branch'
alias Gwc='git-forgit clean'
alias Gwd='git-forgit diff'
alias Gid='git-forgit diff --staged'
alias Gfu='git-forgit fixup'
alias Gi='git-forgit ignore'
alias Gl='git-forgit log'
alias Gr='git-forgit rebase'
alias Gir='git-forgit reset_head'
alias Gcr='git-forgit revert_commit'
alias Gs='git-forgit stash_push'
alias Gsd='git-forgit stash_show'
