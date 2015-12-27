dsymlink modules/vim/installed-config ~/.vim
dsymlink modules/vim/installed-config/init.vim ~/.vimrc

dsymlink modules/vim/installed-config ~/.config/nvim

[[ ! -e "$HOME/.vim/backup" ]] && mkdir "$HOME/.vim/backup"
[[ ! -e "$HOME/.vim/swap" ]] && mkdir "$HOME/.vim/swap"
[[ ! -e "$HOME/.vim/undo" ]] && mkdir "$HOME/.vim/undo"

if [[ ! -e "$HOME/.vim/autoload/plug.vim" ]]; then
  echo 'Installing VimPlug...'
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  echo 'Installing vim plugins...'
  (
    dcheck nvim && vim=nvim || vim=vim
    nohup vim -c 'PlugInstall'  -c 'qall' >/dev/null 2>&1
  )
fi

