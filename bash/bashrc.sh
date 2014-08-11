# ~/.bashrc

# If running interactively, try to start zsh
if [[ $- = *i* ]]; then
	# Start zsh if available
	if shopt -q login_shell && type zsh >/dev/null 2>&1; then
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