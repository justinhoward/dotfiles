#!/usr/bin/env sh

[ "$dotfiles_platform" = linux ] || return

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
