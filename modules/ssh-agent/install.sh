#!/usr/bin/env sh

[ "$dotfiles_platform" = linux ] || return

dsymlink modules/ssh-agent/ssh-agent.service ~/.config/systemd/user/ssh-agent.service
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
