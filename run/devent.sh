function devent()
{
	local event_modules module
	eval "event_modules=(\$devent_$1)"

	for module in "${event_modules[@]}"; do
		dmodload $module
	done
}