pushd `dirname $0` > /dev/null
dir=`pwd`
popd > /dev/null

function backup()
{
	local path=$1

	# Don't back up symbolic links or missing files
	if [ ! -e $path ] || [ -h $path ]; then
		return
	fi

	echo "$path exists. Moving to $path.bak"
	if [ -f "$path.bak" ]; then
		echo "Could not back up $path. Exiting"
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

	if [ -d $target ]; then
		ln -sfT $target $link
	else
		ln -sf $target $link
	fi
}

symlink environment.sh ~/.environment
symlink zsh/zshrc.zsh ~/.zshrc
symlink xorg/xinitrc.sh ~/.xinitrc
symlink bash/bash_profile.sh ~/.bash_profile
symlink bash/bashrc.sh ~/.bashrc
symlink vim/vimrc.vim ~/.vimrc
symlink vim/vim ~/.vim

remove ~/.profile

echo 'Dotfiles installed'