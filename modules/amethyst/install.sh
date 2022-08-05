#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

dsymlink modules/amethyst/installed-config ~/.amethyst
