#!/usr/bin/env bash

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# PHP Composer
if dcheck composer; then
  if [ -d "$COMPOSER_HOME" ]; then
    PATH="$COMPOSER_HOME/vendor/bin:$PATH"
  elif [ -d "$HOME/.composer/vendor/bin" ]; then
    PATH="$HOME/.composer/vendor/bin:$PATH"
  fi
fi

# Rust cargo bin
if [ -d "$HOME/.cargo/bin" ]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

# Swift (swiftly) toolchain bin
if [ -d "$HOME/.swiftly/bin" ]; then
  PATH="$HOME/.swiftly/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# OS X GNU utils
if [ "$dotfiles_platform" = 'osx' ] && dcheck brew; then
  brew_prefix="$(brew --prefix)"
  gnu_packages=(
    coreutils
    findutils
    grep
    gnu-sed
    gnu-tar
    gnu-getopt
  )

  for gnu_pkg in "${gnu_packages[@]}"; do
    if [ -d "$brew_prefix/opt/$gnu_pkg/libexec/gnubin" ]; then
      export PATH="$brew_prefix/opt/$gnu_pkg/libexec/gnubin:$PATH"
      export MANPATH="$brew_prefix/opt/$gnu_pkg/libexec/gnuman:$MANPATH"
    elif [ -d "$brew_prefix/opt/$gnu_pkg/bin" ]; then
      export PATH="$brew_prefix/opt/$gnu_pkg/bin:$PATH"
      export MANPATH="$brew_prefix/opt/$gnu_pkg/share/man:$MANPATH"
    fi
  done

  unset brew_prefix gnu_packages gnu_pkg
fi

export PATH

if [ "$dotfiles_shell" = "zsh" ]; then
  # Ensure path arrays do not contain duplicates.
  # shellcheck disable=2034,3044
  typeset -gU cdpath fpath mailpath path

  # Set the the list of directories that cd searches.
  # shellcheck disable=3030,2206
  cdpath=(
    $cdpath
  )

  # Set the list of directories that Zsh searches for programs.
  # shellcheck disable=3030,2206
  path=(
    $path
  )
fi
