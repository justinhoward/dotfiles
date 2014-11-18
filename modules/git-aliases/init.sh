# Log (l)
alias glf='git log --topo-order --name-status --pretty=format:${_git_log_medium_format}'

# Tag (t)
alias gt='git tag --sort v:refname'
alias gtl='git tag --sort v:refname | head -1'
