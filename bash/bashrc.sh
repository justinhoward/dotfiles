# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Run shared environment
[ -f ~/.environment ] && . ~/.environment