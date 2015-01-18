#!/usr/bin/env bash

pushd `dirname $0` > /dev/null
dir=`pwd`
popd > /dev/null

red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
default='\033[0m'

[[ -n "$ZDOTDIR" ]] && dotfiles_zdir="$ZDOTDIR" || dotfiles_zdir="$HOME"

require=(
	git
)

recommend=(
	zsh
	colormake
	fasd
)

for req in "${require[@]}"; do
	if ! command -v "$req" > /dev/null 2>&1; then
		>&2 echo -e "Requires installing ${red}${req}${default}"
		exit 1
	fi
done

function backup()
{
	local path=$1

	# Don't back up symbolic links or missing files
	if [ ! -e $path ] || [ -h $path ]; then
		return
	fi

	echo "$path exists. Moving to $path.bak"
	if [ -f "$path.bak" ]; then
		echo "Could not back up $path to $path.bak. Exiting"
		exit 1
	fi

	mv $path "$path.bak"
}

function remove()
{
	local path=$1

	backup path

	if [[ -e "$path" ]]; then
		echo "Removing $path"
		rm -rf $path
	fi
}

function symlink()
{
	local relTarget=$1 link=$2 target

	target="$dir/$relTarget"

	backup $link

	if [[ ! -e "$target" ]] || [[ `readlink "$link"` != "$target" ]]; then
		echo "Symlinking $link => $target"
		ln -sf $target $link
	fi
}

symlink installed/zshrc.zsh ~/.zshrc
symlink installed/xinitrc.sh ~/.xinitrc
symlink installed/bash_profile.sh ~/.bash_profile
symlink installed/bashrc.sh ~/.bashrc
symlink installed/vim ~/.vim
symlink installed/vimrc ~/.vimrc
symlink installed/xmonad ~/.xmonad
symlink installed/dotfilesrc.sh ~/.dotfilesrc

remove ~/.profile
remove ~/.zprofile
remove ~/.zlogin
remove ~/.zshenv

[[ ! -e "$dir/installed/vim/backup" ]] && mkdir "$dir/installed/vim/backup"
[[ ! -e "$dir/installed/vim/swap" ]] && mkdir "$dir/installed/vim/swap"
[[ ! -e "$dir/installed/vim/undo" ]] && mkdir "$dir/installed/vim/undo"

if [[ ! -e "$dir/config" ]]; then
	echo "Copying config templates to $dir/config"
	cp -r "$dir/config_templates" "$dir/config"
fi

for rec in "${recommend[@]}"; do
	if ! command -v "$rec" > /dev/null 2>&1; then
		echo -e "Recommends installing ${cyan}${rec}${default}"
	fi
done

if [[ ! -e "$dotfiles_zdir/.zprezto" ]]; then
	git clone --recursive https://github.com/sorin-ionescu/prezto.git "${dotfiles_zdir}/.zprezto"
fi

if [[ ! -e "$HOME/.vim/bundle/neobundle.vim" ]]; then
	curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
fi

echo -e "${green}Dotfiles installed${default}"
