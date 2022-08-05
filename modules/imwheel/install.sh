#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/imwheel/imwheelrc ~/.imwheelrc
