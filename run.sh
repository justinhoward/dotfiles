# Run shared environment scripts
for file in "$DOTFILE_PATH"/share/*.sh; do
	[ -f "$file" ] && . "$file"
done

# Run custom scripts
if [ -d "$DOTFILE_PATH"/custom ]; then
	for file in "$DOTFILE_PATH"/custom/*.sh; do
		[ -f "$file" ] && . "$file"
	done
fi

unset file