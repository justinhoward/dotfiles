#!/usr/bin/env bash

[ -z "$DOTFILES_PATH" ] && DOTFILES_PATH="$HOME/.dotfiles"

(
  echo "Updating dotfiles core"
  cd "$DOTFILES_PATH" || exit 1
  git fetch
  git merge
)

. "$DOTFILES_PATH"/scripts/load.sh

for module in "$DOTFILES_PATH"/modules/*; do
  [ ! -d "$module" ] && return
  dload "$module/update"
done

echo -e "${dgreen}Dotfiles updated${ddefault}"
