#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/neomutt/rc.d ~/.config/neomutt
mkdir -p ~/.cache/neomutt
