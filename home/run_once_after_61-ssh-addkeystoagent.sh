#!/bin/sh
# Ensure `AddKeysToAgent yes` is present in ~/.ssh/config. Idempotent and
# append-only: it never rewrites the existing config, only adds the line if
# missing (no-op when it's already there).
cfg="$HOME/.ssh/config"
if [ ! -f "$cfg" ]; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  : > "$cfg" && chmod 600 "$cfg"
fi
if ! grep -q '^AddKeysToAgent' "$cfg" 2>/dev/null; then
  printf '\nAddKeysToAgent yes\n' >> "$cfg"
fi
