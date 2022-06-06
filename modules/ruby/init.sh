#!/usr/bin/bash

# Disable the spring preloader for Rails
export DISABLE_SPRING=1

# Ruby version manager
if dcheck frum; then
  eval "$(frum init)"
fi

alias rb='ruby'
alias rbb='bundle'
alias rbbc='bundle clean'
alias rbbe='bundle exec'
alias rbbi='bundle install --path vendor/bundle'
alias rbbl='bundle list'
alias rbbo='bundle open'
alias rbbp='bundle package'
alias rbbu='bundle update'
