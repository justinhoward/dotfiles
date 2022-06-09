if [[ "$dotfiles_platform" == 'osx' ]]; then
  drecommend yabai
  dsymlink modules/yabai/yabairc ~/.config/yabai/yabairc
  dsymlink modules/yabai/swiftbar/yabai.1d.sh ~/.config/swiftbar/plugins/yabai.1d.sh
fi
