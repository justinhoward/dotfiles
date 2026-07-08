# npm aliases — ported from prezto's node module. Loads only where npm exists.
command -v npm >/dev/null 2>&1 || return

alias npmi='npm install'
alias npmci='npm ci'
alias npml='npm list'
alias npmo='npm outdated'
alias npmp='npm publish'
alias npmP='npm prune'
alias npmr='npm run'
alias npms='npm search'
alias npmt='npm test'
alias npmu='npm update'
alias npmx='npm uninstall'
alias npmit='npm install && npm test'
alias npmcit='npm ci && npm test'
