#!/usr/bin/env sh

dcheck nvim && EDITOR=nvim || EDITOR=vim
export EDITOR
export VISUAL="$EDITOR"
export PAGER=less

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-g -i -M -R -S -w -z-4'

# Set the Less input preprocessor.
if dcheck lesspipe.sh; then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi
