cd "$(dirname "$0")"

ln -siv environment.sh ~/.environment
ln -siv zsh/zshrc.zsh ~/.zshrc
ln -siv xorg/xinitrc.sh ~/.xinitrc
ln -siv bash/bash_profile.sh ~/.bash_profile
ln -siv bash/bashrc.sh ~/.bashrc

[ -f ~/.profile ] && rm -iv ~/.profile