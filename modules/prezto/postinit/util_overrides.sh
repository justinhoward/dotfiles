if is-callable 'dircolors'; then
    if ! ls --group-directories-first /dev/null >/dev/null 2>&1; then
        unalias ls
    fi
fi