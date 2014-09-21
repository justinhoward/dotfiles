function detect_environment()
{
    if test -n "$ZSH_VERSION"; then
        DOTFILES_SHELL=zsh
    elif test -n "$BASH_VERSION"; then
        DOTFILES_SHELL=bash
    elif test -n "$KSH_VERSION"; then
        DOTFILES_SHELL=ksh
    elif test -n "$FCEDIT"; then
        DOTFILES_SHELL=ksh
    elif test -n "$PS3"; then
        DOTFILES_SHELL=unknown
    else
        DOTFILES_SHELL=sh
    fi

    case $- in *i*) DOTFILES_INTERACTIVE=1; esac

    case $DOTFILES_SHELL in
        bash)
            case :$BASHOPTS: in (*:login_shell:*) DOTFILES_LOGIN=1; esac
            ;;
        *)
            case $- in (*l*) DOTFILES_LOGIN=1; esac
    esac

    export DOTFILES_SHELL DOTFILES_INTERACTIVE DOTFILES_LOGIN DOTFILES_XORG
}
