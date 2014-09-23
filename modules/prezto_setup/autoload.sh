fpath=("$DOTFILES_PATH"/modules/prezto_setup/autoload $fpath)

for func in "$DOTFILES_PATH"/modules/prezto_setup/autoload/*; do
    autoload $func
done

unset func