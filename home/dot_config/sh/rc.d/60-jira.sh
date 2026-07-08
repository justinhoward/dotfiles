# shellcheck shell=sh
# jira-terminal aliases + helpers — shell-agnostic.
command -v jira-terminal >/dev/null 2>&1 || return

alias jr='jira-terminal'
alias jra='jr assign'
alias jrc='jr comment'
alias jrd='jr detail'
alias jrf='jr fields'
alias jrl='jr list'
alias jru='jr update'
alias jrn='jr new'
alias jrt='jr transition'

jrns() { jq -r .namespace < ~/.jira_terminal_configuration.json; }

if command -v xdg-open >/dev/null 2>&1; then
  jro() { xdg-open "https://$(jrns)/browse/$1"; }
elif command -v open >/dev/null 2>&1; then
  jro() { open "https://$(jrns)/browse/$1"; }
fi
