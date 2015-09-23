if [[ "$dotfiles_shell" != 'zsh' ]]; then
  export PS1="${dwhite}[${dblue}\u${dwhite}@\h${ddefault} ${dcyan}\W${dwhite}]\$${ddefault} "
fi
