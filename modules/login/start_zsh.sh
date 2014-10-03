if [[ "$dotfiles_shell" = "zsh" ]]; then
    return
fi

if [[ -z "$dotfiles_interactive" ]]; then
    return
fi

# Start zsh if available
if zsh_path=`command -v zsh`; then
    export SHELL="$zsh_path"
    exec $SHELL -l
fi

unset zsh_path