#!/usr/bin/env bash

if [[ "$dotfiles_platform" != 'osx' ]]; then
  return
fi

dcheck ggrep && alias grep='ggrep'
dcheck gtar && alias tar='gtar'
