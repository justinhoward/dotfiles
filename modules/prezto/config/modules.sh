#!/usr/bin/env sh

# Set the Prezto modules to load (browse modules).
# The order matters.

# syntax-highlighting: should be second to last
# prompt: should be last
zstyle ':prezto:load' pmodule \
  'environment' \
  'utility' \
  'terminal' \
  'editor' \
  'history' \
  'history-substring-search' \
  'directory' \
  'homebrew' \
  'git' \
  'node' \
  'pacman' \
  'completion' \
  'syntax-highlighting' \
  'prompt' \
