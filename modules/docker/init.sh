dcheck docker || return

# Images
alias dia='docker images'
alias did='docker images --filter dangling=true'
alias diD='did --quiet | xargs -r docker rmi'

# Containers
alias dcr='docker ps'
alias dca='docker ps --all'
alias dce='docker ps --all --filter status=exited'
alias dcE='dce --quiet | xargs -r docker rm'

# Run
alias drs='docker run -it'
alias drx='drr --rm'

# Exec
alias des='docker exec -it'
