#!/usr/bin/env sh

dcheck zstyle && zstyle -s ':prezto:module:git:log:cherry' format '_git_log_cherry_format' \
  || _git_log_cherry_format="%m %C(green)%h%C(reset) %s%C(red)%d%C(reset)"

# Log (l)
alias glp='git log --topo-order --stat --patch --full-diff --pretty=format:"${_git_log_medium_format}"'
alias glf='git log --topo-order --name-status --pretty=format:${_git_log_medium_format}'
alias gld='git log --left-right --cherry-mark --no-merges --topo-order --pretty=format:${_git_log_cherry_format}'
# changelog
alias glcl='gh-changelog'

# Tag (t)
alias gt='git tag --sort v:refname'
alias gT='git tag --sort v:refname -n99'
alias gtl='git describe --tags --abbrev=0'
alias gtd='git show "$(gtl)" 2>/dev/null'

# Submodule (S)
alias gSu='git submodule update --recursive'

# Branch (b)
alias gdefault='git symbolic-ref --short refs/remotes/origin/HEAD | sed "s@^origin/@@" || git config --get init.defaultBranch'
alias gba='git branch -a'
alias gbr='git branch -r'
alias gbg='git branch --merged "$(gdefault)" | grep -vE "^\*|^  $(gdefault)$"'
alias gbG='git branch --merged "$(gdefault)" | grep -vE "^\*|^  $(gdefault)$" | xargs -r git branch -d'

# Checkout (co)
alias gcod='git checkout "$(gdefault)"'

# Index (i)
alias giA='git add --all'
alias gip='git add --patch'
alias gidt='git difftool --cached'

# Working tree (w)
alias gwdt='git difftool'

# Worktree (W)
alias gWa='git worktree add'
alias gWp='git worktree prune'
