#!/usr/bin/bash

# Disable the spring preloader for Rails
export DISABLE_SPRING=1

# Ruby version manager
if dcheck frum; then
  eval "$(frum init)"
fi

if [ "$dotfiles_platform" = 'osx' ] && [ -f /opt/homebrew/opt/chruby/share/chruby/chruby.sh ]; then
  source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
  source /opt/homebrew/opt/chruby/share/chruby/auto.sh
fi

alias rb='ruby'
alias rbb='bundle'
alias rbbc='bundle clean'
alias rbbe='bundle exec'
alias rbbi='bundle install'
# Install into default gem path
alias $'rbbI=BUNDLE_PATH="$(ruby -e \'puts Gem.dir\')" bundle install'
alias rbbl='bundle list'
alias rbbo='bundle open'
alias rbbp='bundle package'
alias rbbu='bundle update'
