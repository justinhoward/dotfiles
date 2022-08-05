#!/usr/bin/env sh

dcheck picom || return 0

picom -b
