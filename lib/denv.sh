#!/usr/bin/env bash

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

  local uname="$(uname)"
  if [ "$uname" = "Linux" ]; then
    dotfiles_platform=linux
  elif [ "$uname" = "Darwin" ]; then
    dotfiles_platform=osx
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

  [ -n "$ZDOTDIR" ] && dotfiles_zdir="$ZDOTDIR" || dotfiles_zdir="$HOME"
}
