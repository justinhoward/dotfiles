
#!/usr/bin/env sh

[ "$dotfiles_platform" = 'osx' ] || return

dsymlink modules/swiftbar/plugins ~/.config/swiftbar/plugins
