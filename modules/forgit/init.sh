#!/usr/bin/env sh

dcheck git-forgit || exit
dcheck brew || exit

export FORGIT_NO_ALIASES=1

if [ "$dotfiles_shell" = bash ]; then
  [ -f "$(brew --prefix)"/share/forgit/forgit.plugin.sh ] && . "$(brew --prefix)"/share/forgit/forgit.plugin.sh
elif [ "$dotfiles_shell" = zsh ]; then
  [ -f "$(brew --prefix)"/share/forgit/forgit.plugin.zsh ] && . "$(brew --prefix)"/share/forgit/forgit.plugin.zsh
fi

alias G=git-forgit
alias Gia='G add'
alias Gbd='G branch_delete'
alias Gco='G checkout_branch'
alias Gcc='G checkout_commit'
alias Gcf='G checkout_file'
alias Gct='G checkout_tag'
alias Gcp='G cherry_pick'
alias Gcpb='G cherry_pick_from_branch'
alias Gwc='G clean'
alias Gwd='G diff'
alias Gid='G diff --staged'
alias Gfu='G fixup'
alias Gi='G ignore'
alias Gl='G log'
alias Gr='G rebase'
alias Gir='G reset_head'
alias Gcr='G revert_commit'
alias Gs='G stash_push'
alias Gsd='G stash_show'
