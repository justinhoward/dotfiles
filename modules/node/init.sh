#!/usr/bin/env sh

if dcheck fnm; then
  eval "$(fnm env --log-level=quiet --use-on-cd)"
fi
