function drecommend() {
  if ! dcheck "$1"; then
    local cyan='\033[0;36m'
    local default='\033[0m'

    echo -e "Recommends installing ${cyan}${1}${default}"
  fi
}
