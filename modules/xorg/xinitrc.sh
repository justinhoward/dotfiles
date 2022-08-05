#!/usr/bin/env sh
# shellcheck disable=2034
# ~/.xinitrc

dotfiles_xorg=1

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

. ~/.dotfilesrc
