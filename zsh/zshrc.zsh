# ~/.zshrc

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# oh-my-zsh theme name
ZSH_THEME="agnoster-custom"

# Used by agnoster theme to determine if the username/hostname should be shown
DEFAULT_USER=justin_howard

# Disable oh-my-zsh bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Enable oh-my-zsh plugins
plugins=(git)

# Run shared environment
if [[ -f ~/.environment ]]; then
	. ~/.environment
fi

# oh-my-zsh custom folder path
ZSH_CUSTOM="$DOTFILE_PATH/zsh/oh_my_zsh_custom"

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh