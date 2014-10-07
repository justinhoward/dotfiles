function devent()
{
	local event_modules module

	if [[ "$dotfiles_shell" == 'zsh' ]]; then
		eval "event_modules=(\${devent_$1})"
	else
		eval "event_modules=\${devent_$1[@]}"
	fi

	for module in ${event_modules[@]}; do
		dmodload $module
	done
}
