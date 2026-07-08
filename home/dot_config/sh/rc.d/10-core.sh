# Core interactive aliases — shell-agnostic (zsh + bash).

# eza (ls replacement)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza --group-directories-first -lF --git --icons --group'
  alias l='eza --group-directories-first -lF --git --icons --no-user --no-permissions --no-filesize --no-time'
  alias lt='l -TL2'
  alias la='ll -a'
fi

# neovim
if command -v nvim >/dev/null 2>&1; then
  alias vi='nvim'
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi

# python: alias to python3 only when there's no `python`. Python 2 is EOL, so an
# existing `python` is assumed to be 3 — avoids forking `python --version`.
if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  alias python='python3'
fi

# zoxide interactive jump (zoxide init is done per-shell in rc files)
command -v zoxide >/dev/null 2>&1 && alias j='zi'

# neomutt
command -v neomutt >/dev/null 2>&1 && alias mutt='neomutt'
