if [[ -z $DOTFILES_PATH ]]; then
    DOTFILES_PATH="$HOME/.dotfiles"
fi

for runner in "$DOTFILES_PATH"/run/*.sh; do
    [[ -f "$runner" ]] && source "$runner"
done
unset runner

dmodload environment

if [[ -n $dotfiles_xorg ]]; then
    dmodload xorg
else
    if [[ -n $dotfiles_interactive ]]; then
        dmodload interactive
    fi

    if [[ -n $dotfiles_login ]]; then
        dmodload login
    fi
fi

if [[ -n $dotfiles_xorg ]] && [[ -n $dotfiles_exec_wm ]]; then
    eval $dotfiles_exec_wm
fi
