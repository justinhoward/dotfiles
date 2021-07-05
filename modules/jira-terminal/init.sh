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

function jrns {
  jq -r .namespace < ~/.jira_terminal_configuration.json
}

if dcheck xdg-open; then
  function jro {
    xdg-open "https://$(jrns)/browse/$1"
  }
elif dcheck open; then
  function jro {
    open "https://$(jrns)/browse/$1"
  }
fi
