export PATH=$HOME/bin:/usr/local/bin:$HOME/.composer/vendor/bin:$PATH

typeset -gU cdpath fpath mailpath path

if [ $DOTFILES_SHELL = "zsh" ]; then
    # Ensure path arrays do not contain duplicates.
    typeset -gU cdpath fpath mailpath path

    # Set the the list of directories that cd searches.
    # cdpath=(
    #   $cdpath
    # )

    # Set the list of directories that Zsh searches for programs.
    path=(
      /usr/local/{bin,sbin}
      $path
    )

fi