PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# PHP Composer
if dcheck composer; then
  if [[ -d "$COMPOSER_HOME" ]]; then
    PATH="$COMPOSER_HOME/vendor/bin:$PATH"
  elif [[ -d "$HOME/.composer/vendor/bin" ]]; then
    PATH="$HOME/.composer/vendor/bin:$PATH"
  fi
fi

# Rust cargo bin
if [[ -d "$HOME/.cargo/bin" ]]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/bin" ]]; then
  PATH="$HOME/bin:$PATH"
fi

export PATH

if [[ "$dotfiles_shell" = "zsh" ]]; then
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
