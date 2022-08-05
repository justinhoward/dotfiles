#!/usr/bin/env bash
# Allow unused variables
# shellcheck disable=2034

function denv() {
  if test -n "$ZSH_VERSION"; then
    dotfiles_shell=zsh
  elif test -n "$BASH_VERSION"; then
    dotfiles_shell=bash
  elif test -n "$KSH_VERSION"; then
    dotfiles_shell=ksh
  elif test -n "$FCEDIT"; then
    dotfiles_shell=ksh
  elif test -n "$PS3"; then
    dotfiles_shell=
  else
    dotfiles_shell='sh'
  fi

  local uname
  uname="$(uname)"
  if [ "$uname" = "Linux" ]; then
    dotfiles_platform=linux
    dotfiles_opener=xdg-open
  elif [ "$uname" = "Darwin" ]; then
    dotfiles_platform=osx
    dotfiles_opener=open
  elif [ "$uname" = "FreeBSD" ]; then
    dotfiles_platform=freebsd
  fi

  case $- in *i*) dotfiles_interactive=1; esac

  case "$dotfiles_shell" in
    bash) case :$BASHOPTS: in (*:login_shell:*) dotfiles_login=1; esac ;;
    *) case $- in (*l*) dotfiles_login=1; esac ;;
  esac

  case "$(tty)" in
    /dev/tty[0-9]*) ;;
    *) dotfiles_virtual=1 ;;
  esac

  if [ "$dotfiles_platform" = linux ]; then
    opener=xdg-open
  elif [ "$dotfiles_platform" = osx ]; then
    opener=open
  fi

  [ -n "$ZDOTDIR" ] && dotfiles_zdir="$ZDOTDIR" || dotfiles_zdir="$HOME"
}
