#!/usr/bin/env sh

if dcheck conky; then
    dconfig conky
    export dotfiles_conky_x
    export dotfiles_conky_y
    conky
fi
