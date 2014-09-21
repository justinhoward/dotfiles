if [ -z $DOTFILES_PATH ]; then
    export DOTFILES_PATH="$HOME/.dotfiles"
fi

for runner in "$DOTFILES_PATH"/run/*.sh; do
    [ -f "$runner" ] && source "$runner"
done

detect_environment

init_dotfiles_module environment

if [ $DOTFILES_INTERACTIVE ]; then
    init_dotfiles_module interactive
fi

if [ $DOTFILES_LOGIN ]; then
    init_dotfiles_module login
fi

if [ $DOTFILES_XORG ]; then
    init_dotfiles_module xorg
    $DOTFILES_EXEC_WM
fi

unset runner
unset -f init_dotfiles_module detect_environment

if [ $DOTFILES_XORG ]; then
    $DOTFILES_EXEC_WM
fi