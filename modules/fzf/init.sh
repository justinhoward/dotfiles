#!/usr/bin/env sh

dcheck fzf || dcheck sk || return

if dcheck fd; then
  export FZF_DEFAULT_COMMAND="fd --exclude .git --type f --no-ignore --hidden"
else
  # shellcheck disable=2209
  find_cmd=find
  dcheck gfind && find_cmd=gfind
  export FZF_DEFAULT_COMMAND="$find_cmd -path './.git' -prune -o -type f -printf '%P\n'"
fi
