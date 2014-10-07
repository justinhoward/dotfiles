pushd `dirname $0` > /dev/null
dir=`pwd`
popd > /dev/null

function backup()
{
	local path=$1

	# Remove symbolic links
	if [ -h $path ]; then
		rm -f $path
	fi

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

	rm -rf $path
}

function symlink()
{
	local relTarget=$1 link=$2 target

	target="$dir/$relTarget"

	backup $link

	ln -sf $target $link
}

symlink installed/zshrc.zsh ~/.zshrc
symlink installed/xinitrc.sh ~/.xinitrc
symlink installed/bash_profile.sh ~/.bash_profile
symlink installed/bashrc.sh ~/.bashrc
symlink installed/vimrc.vim ~/.vimrc
symlink installed/vim ~/.vim
symlink installed/xmonad ~/.xmonad
symlink installed/dotfilesrc.sh ~/.dotfilesrc

remove ~/.profile
remove ~/.zprofile
remove ~/.zlogin
remove ~/.zshenv

if [[ ! -d "$dir/config" ]]; then
	cp -r "$dir/config_templates" "$dir/config"
fi

echo 'Dotfiles installed'
