# shellcheck shell=sh
# Homebrew aliases — ported from prezto's homebrew module. Loads only where
# brew is present (macOS or Linuxbrew).
command -v brew >/dev/null 2>&1 || return

if [ "${HOMEBREW_PREFIX-}" = /opt/homebrew ]; then
  # Wrap the brew command to set a basic PATH
  # This ensures that it runs in a clean build environment without things like
  # gnu coreutils.
  brew() {
    PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
      command "$HOMEBREW_PREFIX/bin/brew" "$@"
  }
fi

alias brewc='brew cleanup'
alias brewi='brew install'
alias brewL='brew leaves'
alias brewl='brew list'
alias brewo='brew outdated'
alias brews='brew search'
alias brewu='brew upgrade'
alias brewx='brew uninstall'

alias caski='brew install --cask'
alias caskl='brew list --cask'
alias casko='brew outdated --cask'
alias casks='brew search --cask'
alias casku='brew upgrade --cask'
alias caskx='brew uninstall --cask'
