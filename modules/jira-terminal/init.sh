#!/usr/bin/env bash

alias jr='jira-terminal'
alias jra='jr assign'
alias jrc='jr comment'
alias jrd='jr detail'
alias jrf='jr fields'
alias jrl='jr list'
alias jru='jr update'
alias jrn='jr new'
alias jrt='jr transition'

function jro {
  namespace="$(jq -r .namespace < ~/.jira_terminal_configuration.json)"
  xdg-open "https://${namespace}/browse/$1"
}
