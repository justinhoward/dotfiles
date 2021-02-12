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
alias gtl='git tag --sort -v:refname | head -1'

# Submodule (S)
alias gSu='git submodule update --recursive'

# Branch (b)
alias gba='git branch -a'
alias gbr='git branch -r'
alias gbg='git branch --merged master | grep -vE "^\*|^  master$"'
alias gbG='git branch --merged master | grep -vE "^\*|^  master$" | xargs git branch -d'

# Index (i)
alias giA='git add --all'
alias gip='git add --patch'
alias gidt='git difftool --cached'

# Working tree (w)
alias gwdt='git difftool'

# Worktree (W)
alias gWa='git worktree add'
alias gWp='git worktree prune'
