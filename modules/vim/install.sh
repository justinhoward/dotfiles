dsymlink modules/vim/installed-config ~/.vim
dsymlink modules/vim/vimrc ~/.vimrc

[[ ! -e "$HOME/.vim/backup" ]] && mkdir "$HOME/.vim/backup"
[[ ! -e "$HOME/.vim/swap" ]] && mkdir "$HOME/.vim/swap"
[[ ! -e "$HOME/.vim/undo" ]] && mkdir "$HOME/.vim/undo"

if [[ ! -e "$HOME/.vim/autoload/plug.vim" ]]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo 'Installing vim plugins...'
nohup vim -c 'PlugInstall'  -c 'qall' >/dev/null 2>&1
