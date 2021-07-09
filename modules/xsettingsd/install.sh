#!/usr/bin/env sh

[ "$dotfiles_platform" != linux ] && return

drecommend xsettingsd
dsymlink modules/xsettingsd/rc/xsettingsd.conf ~/.config/xsettingsd/xsettingsd.conf
