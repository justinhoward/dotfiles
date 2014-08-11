# Run shared environment scripts
for file in `pwd`"/share/*"; do
	[ -f "$file" ] && . "$file"
done
unset file