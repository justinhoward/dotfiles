#!/usr/bin/env bash

drecommend pinentry-mac

if [ "$dotfiles_platform" = osx ]; then
  gpg_conf="${HOME}/.gnupg/gpg-agent.conf"
  mkdir -p "$(dirname "$gpg_confg")"
  if ! grep pinentry-program "$gpg_conf" >/dev/null 2>&1; then
    echo "pinentry-program ${HOMEBREW_PREFIX}/bin/pinentry-mac" > "$gpg_conf"
  fi
fi
