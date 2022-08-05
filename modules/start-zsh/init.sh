#!/usr/bin/env sh

[ "$dotfiles_shell" = "zsh" ] && return
[ -z "$dotfiles_interactive" ] && return

# Start zsh if available
if zsh_path="$(command -v zsh)"; then
    export SHELL="$zsh_path"
    exec $SHELL -l
fi

unset zsh_path
