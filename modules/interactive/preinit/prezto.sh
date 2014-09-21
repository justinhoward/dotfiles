if [ "$DOTFILES_SHELL" != "zsh" ]; then
    return
fi

init_dotfiles_module prezto_setup

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi