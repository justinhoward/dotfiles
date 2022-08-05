#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/picom/picom.conf ~/.config/picom/picom.conf
