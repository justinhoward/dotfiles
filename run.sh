dir="$(dirname "$0")"

# Run shared environment scripts
for file in "$dir"/share/*.sh; do
	[ -f "$file" ] && . "$file"
done

# Run custom scripts
if [ -d "$dir"/custom ]; then
	for file in "$dir"/custom/*.sh; do
		[ -f "$file" ] && . "$file"
	done
fi

unset dir file
