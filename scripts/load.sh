for lib in "$DOTFILES_PATH"/lib/*.sh; do
  . "$lib"
done
unset lib

denv
dcolors
