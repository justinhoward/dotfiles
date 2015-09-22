dsymlink modules/vim/config ~/.vim
dsymlink modules/vim/vimrc ~/.vimrc

[[ ! -e "$HOME/.vim/backup" ]] && mkdir "$HOME/.vim/backup"
[[ ! -e "$HOME/.vim/swap" ]] && mkdir "$HOME/.vim/swap"
[[ ! -e "$HOME/.vim/undo" ]] && mkdir "$HOME/.vim/undo"

if [[ ! -e "$HOME/.vim/bundle/neobundle.vim" ]]; then
	curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
fi
