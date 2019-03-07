if [ -f /usr/share/chruby/chruby.sh ] && [[ "$dotfiles_shell" =~ (zsh|bash) ]]; then
  source /usr/share/chruby/chruby.sh
  source /usr/share/chruby/auto.sh
fi
