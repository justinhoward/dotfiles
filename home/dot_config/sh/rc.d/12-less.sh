# Colorized `less` / `man` output (bold, underline, standout). Interactive-only,
# so it lives here (bash + zsh) rather than in env.sh — the ANSI-C $'...' quoting
# below isn't POSIX. When bat is the MANPAGER (see env.sh) man renders through
# bat instead; these still apply to plain `less` and to man without bat.
export LESS_TERMCAP_mb=$'\e[01;31m'     # begin blink       → bold red
export LESS_TERMCAP_md=$'\e[01;31m'     # begin bold        → bold red
export LESS_TERMCAP_me=$'\e[0m'         # end mode
export LESS_TERMCAP_se=$'\e[0m'         # end standout
export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin standout    → yellow on blue
export LESS_TERMCAP_ue=$'\e[0m'         # end underline
export LESS_TERMCAP_us=$'\e[01;32m'     # begin underline   → green
