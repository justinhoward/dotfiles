#!/usr/bin/env sh

dcheck git || return

alias wdiff="git --no-pager diff --color=auto --no-ext-diff --no-index --color-words '--word-diff-regex=[a-zA-Z0-9\-_]+'"
