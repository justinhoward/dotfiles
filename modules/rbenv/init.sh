#!/usr/bin/env sh

dcheck rbenv || return

eval "$(rbenv init -)"
rehash
