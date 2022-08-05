#!/usr/bin/env sh

dcheck /usr/bin/gnome-keyring-daemon || return
eval "$(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh 2> /dev/null)"
export SSH_AUTH_SOCK
