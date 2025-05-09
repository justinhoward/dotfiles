#!/usr/bin/env sh

dcheck fzf || return

if dcheck fzf; then
  if [ "$dotfiles_shell" = zsh ]; then
    eval "$(fzf --zsh)"
  elif [ "$dotfiles_shell" = bash ]; then
    eval "$(fzf --bash)"
  fi
fi

if dcheck fd; then
  export FZF_DEFAULT_COMMAND="fd --exclude .git --type f --no-ignore --hidden"
else
  # shellcheck disable=2209
  find_cmd=find
  dcheck gfind && find_cmd=gfind
  export FZF_DEFAULT_COMMAND="$find_cmd -path './.git' -prune -o -type f -printf '%P\n'"
fi

export FZF_DEFAULT_OPTS="
  --multi
  --height='80%'
  --bind='alt-a:toggle-all'
  --bind='alt-s:toggle-sort'
  --bind='?:toggle-preview'
  --bind='alt-w:toggle-preview-wrap'
  --preview-window='right:60%'
  --preview='bat -p --color=always {-1}'
"
