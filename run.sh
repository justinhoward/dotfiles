# Run shared environment scripts
for file in `pwd`/share/*.sh; do
	echo $file
	[ -f "$file" ] && . "$file"
done

# Run custom scripts
if [ -d `pwd`/custom ]; then
	for file in `pwd`/custom/*.sh; do
		echo $file
		[ -f "$file" ] && . "$file"
	done
fi

unset file