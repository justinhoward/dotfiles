#!/usr/bin/env bash

if dcheck python; then
  if [[ "$(python --version)" =~ 3.* ]]; then
    true
  elif dcheck python3; then
    alias python=python3
  fi
elif dcheck python3; then
  alias python=python3
fi
