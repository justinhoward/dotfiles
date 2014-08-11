dir="$(dirname "$0")"

ln -siv "$dir/environment.sh" ~/.environment
ln -siv "$dir/zsh/zshrc.zsh" ~/.zshrc
ln -siv "$dir/xorg/xinitrc.sh" ~/.xinitrc
ln -siv "$dir/bash/bash_profile.sh" ~/.bash_profile
ln -siv "$dir/bash/bashrc.sh" ~/.bashrc

[ -f ~/.profile ] && rm -iv ~/.profile