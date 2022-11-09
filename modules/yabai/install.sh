#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

drecommend yabai
dsymlink modules/yabai/yabairc ~/.config/yabai/yabairc
