#!/usr/bin/env sh

if ! grep '^AddKeysToAgent' < ~/.ssh/config >/dev/null; then
  printf '\nAddKeysToAgent yes' >> ~/.ssh/config
  chmod 644 ~/.ssh/config
fi

if [ "$dotfiles_platform" = linux ]; then
  dsymlink modules/ssh-agent/ssh-agent.service ~/.config/systemd/user/ssh-agent.service
  systemctl --user enable ssh-agent
  systemctl --user start ssh-agent
fi
