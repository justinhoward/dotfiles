#!/usr/bin/env sh

[ "$dotfiles_platform" = linux ] || return

# Some window managers (xmonad, awesome) don't know what the default cursor should be, set it to cursor
xsetroot -cursor_name left_ptr
