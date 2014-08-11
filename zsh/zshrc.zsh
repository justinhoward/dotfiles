# ~/.zshrc

# Run shared environment
if [[ -f ~/.environment ]]; then
	. ~/.environment
fi

# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# oh-my-zsh theme name
ZSH_THEME="agnoster-custom"

# Used by agnoster theme to determine if the username/hostname should be shown
DEFAULT_USER=justin_howard

# Disable oh-my-zsh bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# oh-my-zsh custom folder path
ZSH_CUSTOM=~/.zsh-custom

# Enable oh-my-zsh plugins
plugins=(git)

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh