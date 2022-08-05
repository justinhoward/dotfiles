#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

drecommend skhd
dsymlink modules/skhd/skhdrc ~/.config/skhd/skhdrc
dsymlink modules/skhd/scripts ~/.config/skhd/scripts
