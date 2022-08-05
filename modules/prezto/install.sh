#!/usr/bin/env sh

drequire git

if [ ! -e "$dotfiles_zdir/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${dotfiles_zdir}/.zprezto"
fi
