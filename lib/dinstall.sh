function dinstall() {
  for module in "$DOTFILES_PATH"/modules/*; do
    dload "$module/install"
  done
}
