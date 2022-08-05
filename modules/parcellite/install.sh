#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/parcellite/installed-config ~/.config/parcellite
