for keymap in 'emacs' 'viins' 'vicmd'; do
	# [Ctrl-RightArrow] - move forward one word
	bindkey -M $keymap '^[[1;5C' forward-word
	# [Ctrl-LeftArrow] - move backward one word
	bindkey -M $keymap '^[[1;5D' backward-word
done

unset keymap