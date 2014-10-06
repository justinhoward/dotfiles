fpath=("$DOTFILES_PATH"/modules/prezto/autoload $fpath)

for func in "$DOTFILES_PATH"/modules/prezto/autoload/*; do
    autoload $func
done

unset func