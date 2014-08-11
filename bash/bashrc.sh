# ~/.bashrc

# If running interactively, and is a login shell try to start zsh
if [[ $- = *i* ]] && shopt -q login_shell; then
	# Start zsh if available
	if type zsh >/dev/null 2>&1; then
		export SHELL=`which zsh`
		if [ $? -eq 0 ]; then
			exec $SHELL -l
		else
			echo 'Unable to locate zsh'
		fi
	fi
fi

# Run shared environment
if [[ -f ~/.environment ]]; then
	. ~/.environment
fi