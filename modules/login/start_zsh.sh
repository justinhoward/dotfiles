if [[ "$DOTFILES_SHELL" = "zsh" ]]; then
    return
fi

if [[ -z "$DOTFILES_INTERACTIVE" ]]; then
    return
fi

# Start zsh if available
if zsh_path=`command -v zsh`; then
    export SHELL="$zsh_path"
    exec $SHELL -l
fi

unset zsh_path