#!/usr/bin/bash

# Disable the spring preloader for Rails
export DISABLE_SPRING=1

# Ruby version manager
if dcheck frum; then
  eval "$(frum init)"
fi
