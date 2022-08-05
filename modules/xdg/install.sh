#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/xdg/user-dirs.dirs ~/.config/user-dirs.dirs
