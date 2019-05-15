if [ -d /usr/local/opt/chruby ]; then
  _chruby_path=/usr/local/opt/chruby
else
  _chruby_path=/usr
fi

if [ -f "$_chruby_path"/share/chruby/chruby.sh ] && [[ "$dotfiles_shell" =~ (zsh|bash) ]]; then
  source "$_chruby_path"/share/chruby/chruby.sh
  source "$_chruby_path"/share/chruby/auto.sh
fi
