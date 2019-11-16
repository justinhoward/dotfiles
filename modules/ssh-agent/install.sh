if [ "$dotfiles_platform" = linux ]; then
  dsymlink modules/ssh-agent/ssh-agent.service ~/.config/systemd/user/ssh-agent.service
  systemctl --user enable ssh-agent
  systemctl --user start ssh-agent
fi
