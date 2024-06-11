#!/usr/bin/env sh

drecommend 'git'
drecommend 'delta'

dsymlink modules/git/installed-config/gitignore-global ~/.config/git/ignore

git config --global include.path "$DOTFILES_PATH"/modules/git/installed-config/default
