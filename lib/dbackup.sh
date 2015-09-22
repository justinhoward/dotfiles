function dbackup() {
	local path="$1"

	# Don't back up symbolic links or missing files
	if [[ ! -e "$path" ]] || [[ -h "$path" ]]; then
		return
	fi

	echo "$path exists. Moving to $path.bak"
	if [[ -f "$path.bak" ]]; then
		echo "Could not back up $path to $path.bak. Exiting"
		exit 1
	fi

	mv "$path" "$path.bak"
}
