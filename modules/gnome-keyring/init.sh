if dcheck /usr/bin/gnome-keyring-daemon; then
  eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh 2> /dev/null)
  export SSH_AUTH_SOCK
fi
