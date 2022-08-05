#!/usr/bin/env sh

ddg() {
  "$dotfiles_opener" "https://duckduckgo.com/?q=$(url_encode "$@")"
}
alias s=ddg

goog() {
  "$dotfiles_opener" "https://www.google.com/search?q=$(url_encode "$@")"
}
alias sg=goog


sb() {
  bang="$1"
  shift
  ddg "!${bang}" "$@"
}

dev() {
  sb devdocs "$@"
}

unset url_encode
