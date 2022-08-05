#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/xorg/xinitrc.sh ~/.xinitrc
