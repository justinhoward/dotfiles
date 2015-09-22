function drecommend() {
  if ! dcheck "$1"; then
    echo -e "Recommends installing ${dcyan}${1}${ddefault}"
  fi
}
