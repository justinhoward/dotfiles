#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/rsibreak/installed-config/rsibreakrc ~/.config/rsibreakrc
dsymlink modules/rsibreak/installed-config/rsibreak.kmessagebox ~/.config/rsibreak.kmessagebox
dsymlink modules/rsibreak/installed-config/rsibreak.notifyrc ~/.config/rsibreak.notifyrc
