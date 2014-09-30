PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# PHP Composer
if command -v composer 2>&1 /dev/null; then
    if [[ -d "$COMPOSER_HOME" ]]; then
        PATH="$COMPOSER_HOME/vendor/bin:$PATH"
    elif [[ -d "$HOME/.composer/vendor/bin" ]]; then
        PATH="$HOME/.composer/vendor/bin:$PATH"
    fi
fi

# Ruby gems
if command -v ruby 2>&1 /dev/null && command -v gem 2>&1 /dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

if [[ -d "$HOME/bin" ]]; then
    PATH="$HOME/bin:$PATH"
fi

export PATH

if [[ $DOTFILES_SHELL = "zsh" ]]; then
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