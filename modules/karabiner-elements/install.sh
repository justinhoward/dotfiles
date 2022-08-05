#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

dsymlink modules/karabiner-elements/installed-config/karabiner.json ~/.config/karabiner/karabiner.json
