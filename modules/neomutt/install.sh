if [[ "$dotfiles_platform" == 'linux' ]]; then
  dsymlink modules/neomutt/rc.d ~/.config/neomutt
  mkdir -p ~/.cache/neomutt
fi
