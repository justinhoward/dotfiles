# shellcheck shell=sh
# Ruby / Bundler aliases — shell-agnostic.
export DISABLE_SPRING=1

alias rb='ruby'
alias rbb='bundle'
alias rbbc='bundle clean'
alias rbbe='bundle exec'
alias rbbi='bundle install'
alias rbbl='bundle list'
alias rbbo='bundle open'
alias rbbp='bundle package'
alias rbbu='bundle update'
# Install into the default gem path
alias rbbI='BUNDLE_PATH="$(ruby -e "puts Gem.dir")" bundle install'
