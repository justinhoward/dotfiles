if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$dotfiles_virtual" ]]; then
	export TERM='xterm-256color'
else
	export TERM='xterm-color'
fi

if [[ "$dotfiles_shell" =  "zsh" ]]; then
	export KEYTIMEOUT=1
fi
