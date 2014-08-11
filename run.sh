cd "$(dirname "$0")"

# Run shared environment scripts
local file
for file in "share/*"; do
	[ -f "$file" ] && . "$file"
done