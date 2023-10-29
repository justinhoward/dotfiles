#!/usr/bin/env sh

dconfig kitty

dsymlink modules/kitty/rc/kitty.conf ~/.config/kitty/kitty.conf
dsymlink modules/kitty/rc/themes ~/.config/kitty/themes
echo "font_size ${dotfiles_kitty_font_size}" > ~/.config/kitty/font_size.conf
