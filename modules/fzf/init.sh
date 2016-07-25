dcheck sudo || return

export FZF_DEFAULT_COMMAND="find -path './.git' -prune -o -type f -printf '%P\n'"
