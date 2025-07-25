#!/usr/bin/env sh

dsymlink modules/core/zshrc.zsh ~/.zshrc
dsymlink modules/core/zprofile.zsh ~/.zprofile
dsymlink modules/core/bashrc.sh ~/.bashrc
dsymlink modules/core/bash_profile.sh ~/.bash_profile
dsymlink modules/core/dotfilesrc.sh ~/.dotfilesrc

dremove ~/.profile
dremove ~/.zlogin
dremove ~/.zshenv
