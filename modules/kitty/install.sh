#!/usr/bin/env sh

dconfig kitty

kitty_tmp="$(mktemp)"
kitty_conf="$HOME/.config/kitty/kitty.conf"
envsubst < modules/kitty/rc/kitty.conf > "$kitty_tmp"

if [ -f ~/.config/kitty/kitty.conf ]; then
  if [ "$(md5sum "$kitty_tmp" | cut -d' ' -f1)" != "$(md5sum "$kitty_conf" | cut -d' ' -f1)" ]; then
    dbackup "$kitty_conf"
    kitty_write=1
  fi
else
  kitty_write=1
fi

if [ -n "$kitty_write" ]; then
  echo "Writing $kitty_conf"
  mkdir -p "$(dirname "$kitty_conf")"
  cp -f "$kitty_tmp" "$kitty_conf"
fi

rm "$kitty_tmp"
unset kitty_tmp kitty_conf kitty_write
