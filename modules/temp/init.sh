#!/usr/bin/env sh

if [ ! -d "$TMPDIR" ]; then
  export TMPDIR="/tmp/$USER"
  # -m only applies to deepest directory when used with -p
  # shellcheck disable=2174
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [ ! -d "$TMPPREFIX" ]; then
  mkdir -p "$TMPPREFIX"
fi
