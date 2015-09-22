for lib in "$DOTFILES_PATH"/lib/*.sh; do
    [[ -f "$lib" ]] && source "$lib"
done
unset lib
