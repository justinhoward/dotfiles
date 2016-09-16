dcheck fzf || return

find_cmd=find
dcheck gfind && find_cmd=gfind
export FZF_DEFAULT_COMMAND="$find_cmd -path './.git' -prune -o -type f -printf '%P\n'"
