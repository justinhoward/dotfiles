for lib in "$DOTFILES_PATH"/lib/*.sh; do
  [ -f "$lib" ] && . "$lib"
done
unset lib

denv
dcolors
