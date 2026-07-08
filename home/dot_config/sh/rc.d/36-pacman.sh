# pacman aliases — ported from prezto's pacman module (Arch Linux). Loads only
# where pacman exists (so this is inert on macOS).
command -v pacman >/dev/null 2>&1 || return

alias pac='pacman'
alias paci='sudo pacman --sync'                         # install from repos
alias pacI='sudo pacman --upgrade'                      # install a local package
alias pacx='sudo pacman --remove'                       # remove package
alias pacX='sudo pacman --remove --nosave --recursive'  # remove + deps + configs
alias pacq='pacman --sync --info'                       # info (remote)
alias pacQ='pacman --query --info'                      # info (installed)
alias pacs='pacman --sync --search'                     # search (remote)
alias pacS='pacman --query --search'                    # search (installed)
alias pacu='sudo pacman --sync --refresh'               # refresh package db
alias pacU='sudo pacman --sync --refresh --sysupgrade'  # upgrade the system
alias paco='pacman --query --deps --unrequired'         # list orphaned packages
alias pacO='sudo pacman --remove --recursive $(pacman --quiet --query --deps --unrequired)'  # remove orphans
