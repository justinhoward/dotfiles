#!/usr/bin/env bash

for lib in "$DOTFILES_PATH"/lib/*.sh; do
  # Allow non-constant source
  # shellcheck disable=1090
  . "$lib"
done
unset lib

denv
dcolors
