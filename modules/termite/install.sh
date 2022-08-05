#!/usr/bin/env sh

[ "$dotfiles_platform" = 'linux' ] || return

dsymlink modules/termite/installed-config ~/.config/termite

# Set termite as default file manager
dsymlink modules/termite/termite-dir.desktop ~/.local/share/applications/termite-dir.desktop
xdg-mime default termite-dir.desktop inode/directory
