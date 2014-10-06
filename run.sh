if [[ -z $DOTFILES_PATH ]]; then
    DOTFILES_PATH="$HOME/.dotfiles"
fi

for runner in "$DOTFILES_PATH"/run/*.sh; do
    [[ -f "$runner" ]] && source "$runner"
done
unset runner

dconfig modules

devent load

if [[ -n $dotfiles_xorg ]]; then
    devent xorg
else
    if [[ -n $dotfiles_interactive ]]; then
        devent interactive
    fi

    if [[ -n $dotfiles_login ]]; then
        devent login
    fi
fi

if [[ -n $dotfiles_xorg ]]; then
	devent xorg_exec
fi