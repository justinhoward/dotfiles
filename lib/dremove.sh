function dremove() {
	local path=$1

	dbackup path

	if [[ -e "$path" ]]; then
		echo "Removing $path"
		rm -rf $path
	fi
}
