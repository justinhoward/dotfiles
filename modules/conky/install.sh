#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/conky/conkyrc.lua ~/.conkyrc
