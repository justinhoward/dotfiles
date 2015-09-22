function drequire() {
  local red='\033[0;31m'
  local default='\033[0m'
  
	if ! dcheck "$1"; then
		>&2 echo -e "Requires installing ${red}${1}${default}"
		exit 1
	fi
}
