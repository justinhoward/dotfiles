for keymap in 'emacs' 'viins' 'vicmd'; do
  # [Ctrl-RightArrow] - move forward one word
  bindkey -M $keymap '^[[1;5C' forward-word
  # [Ctrl-LeftArrow] - move backward one word
  bindkey -M $keymap '^[[1;5D' backward-word
done

if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey -M viins "$key_info[Control]R" \
    history-incremental-pattern-search-backward
  bindkey -M viins "$key_info[Control]S" \
    history-incremental-pattern-search-forward
fi

unset keymap
