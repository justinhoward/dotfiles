alias gs='git status -sb'
alias gd="git diff --color-words"
alias gdc="gd --cached"
alias gl='git log --graph --abbrev-commit --decorate --name-status'
alias gll='git log --abbrev-commit --color-words --decorate -p'
alias gls='git log --oneline --decorate'
alias gb='git branch -a'
alias gco='git checkout'
alias grp='git remote prune origin'
alias gsu='echo $(cd "$(git rev-parse --show-toplevel)"; git submodule update)'
alias gt='git fetch; git describe --tags --abbrev=0 origin/master'
alias gf='git fetch'
