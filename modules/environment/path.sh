PATH=/usr/local/bin:/usr/local/sbin:$PATH

# PHP Composer
if which composer >/dev/null; then
    if [[ -d "$COMPOSER_HOME" ]]; then
        PATH="$COMPOSER_HOME/vendor/bin:$PATH"
    else if [[ -d "$HOME/.composer/vendor/bin" ]]
        PATH="$HOME/.composer/vendor/bin:$PATH"
    fi
fi

# Ruby gems
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

if [[ -d "$HOME/bin" ]]; then
    PATH="$HOME/bin:$PATH"
fi

export PATH

if [ $DOTFILES_SHELL = "zsh" ]; then
    # Ensure path arrays do not contain duplicates.
    typeset -gU cdpath fpath mailpath path

    # Set the the list of directories that cd searches.
    cdpath=(
      $cdpath
    )

    # Set the list of directories that Zsh searches for programs.
    path=(
      $path
    )

fi