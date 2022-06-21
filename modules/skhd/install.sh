if [[ "$dotfiles_platform" == 'osx' ]]; then
  drecommend skhd
  dsymlink modules/skhd/skhdrc ~/.config/skhd/skhdrc
  dsymlink modules/skhd/scripts ~/.config/skhd/scripts
fi
