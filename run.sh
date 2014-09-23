if [ -z $DOTFILES_PATH ]; then
    export DOTFILES_PATH="$HOME/.dotfiles"
fi

for runner in "$DOTFILES_PATH"/run/*.sh; do
    [ -f "$runner" ] && source "$runner"
done

detect_environment

dmodload environment

if [ $DOTFILES_INTERACTIVE ]; then
    dmodload interactive
fi

if [ $DOTFILES_LOGIN ]; then
    dmodload login
fi

if [ $DOTFILES_XORG ]; then
    dmodload xorg
    $DOTFILES_EXEC_WM
fi

unset runner
unset -f dmodload detect_environment

if [ $DOTFILES_XORG ]; then
    $DOTFILES_EXEC_WM
fi