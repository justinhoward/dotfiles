#!/usr/bin/env sh

dcheck zstyle && zstyle -s ':prezto:module:git:log:cherry' format '_git_log_cherry_format' \
  || _git_log_cherry_format="%m %C(green)%h%C(reset) %s%C(red)%d%C(reset)"

if xargs --version | grep GNU > /dev/null; then
  _xargs='xargs -r'
else
  _xargs='xargs'
fi

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

# Conflict (C)
alias gCl='git --no-pager diff --name-only --diff-filter=U | xargs git -c color.status=always status --short --'
alias gCa='git add $(git --no-pager diff --name-only --diff-filter=U)'
alias gCe='git mergetool $(git --no-pager diff --name-only --diff-filter=U)'
alias gCo='git checkout --ours --'
alias gCO='gCo $(git --no-pager diff --name-only --diff-filter=U)'
alias gCt='git checkout --theirs --'
alias gCT='gCt $(git --no-pager diff --name-only --diff-filter=U)'

# git-forgit
# shellcheck disable=SC2139
alias GCl="gCl | fzf --ansi --exit-0 --multi --preview 'git diff --color=always {2}' --with-nth '[{1}] {-1}' --accept-nth -1 | $_xargs $EDITOR --"
# shellcheck disable=SC2139
alias GCa="gCl | fzf --ansi --exit-0 --multi --preview 'git diff --color=always {2}' --with-nth '[{1}] {-1}' --accept-nth -1 | $_xargs git add --"

unset _xargs
