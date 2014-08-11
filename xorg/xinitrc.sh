# ~/.xinitrc

# Run shared environment
if [[ -f ~/.environment ]]; then
	. ~/.environment
fi

# Executed by startx (run your window manager from here)

# Run global xinit scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# XMonad doesn't know what the default cursor should be, set it to cursor
xsetroot -cursor_name left_ptr

if [ -f ~/.screenlayout/default.sh ]; then
	. ~/.screenlayout/default.sh &
fi

if [ $(command -v xautolock 2>&1 /dev/null) ] && [ $(command -v slock 2>&1 /dev/null) ]; then
	xautolock -time 5 -locker slock &
fi

#fix white screen for java apps in xmonad
export _JAVA_AWT_WM_NONREPARENTING=1

exec xmonad
