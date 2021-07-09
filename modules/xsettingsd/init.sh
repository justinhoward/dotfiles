#!/usr/bin/env sh

[ "$dotfiles_platform" != linux ] && return

if dcheck xsettingsd; then
  xsettingsd &
fi
