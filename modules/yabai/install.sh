#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

drecommend yabai
dsymlink modules/yabai/yabairc ~/.config/yabai/yabairc
dsymlink modules/yabai/swiftbar/yabai.1d.sh ~/.config/swiftbar/plugins/yabai.1d.sh
