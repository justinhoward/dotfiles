dconfig umask
if [[ -n "$dotfiles_umask" ]]; then
  umask "$dotfiles_umask"
fi
