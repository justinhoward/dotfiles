dsymlink modules/core/zshrc.zsh ~/.zshrc
dsymlink modules/core/bashrc.sh ~/.bashrc
dsymlink modules/core/bash_profile.sh ~/.bash_profile
dsymlink modules/core/dotfilesrc.sh ~/.dotfilesrc

dremove ~/.profile
dremove ~/.zprofile
dremove ~/.zlogin
dremove ~/.zshenv

if [[ ! -e "$DOTFILES_PATH/config" ]]; then
	echo "Copying config templates to $DOTFILES_PATH/config"
	cp -r "$DOTFILES_PATH/config_templates" "$DOTFILES_PATH/config"
fi
