#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/gromit-mpx/gromit-mpx.cfg ~/.config/gromit-mpx.cfg
dsymlink modules/gromit-mpx/gromit-mpx.ini ~/.config/gromit-mpx.ini
