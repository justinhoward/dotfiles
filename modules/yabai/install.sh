if [[ "$dotfiles_platform" == 'osx' ]]; then
  drecommend yabai
  dsymlink modules/yabai/yabairc ~/.config/yabai/yabairc
  dsymlink modules/yabai/swiftbar/yabai.sh ~/.config/swiftbar/plugins/yabai.sh
fi
