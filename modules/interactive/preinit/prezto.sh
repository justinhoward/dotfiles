if [[ "$DOTFILES_SHELL" != "zsh" ]]; then
    return
fi

dmodload prezto_setup

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi