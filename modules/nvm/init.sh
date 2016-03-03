export NVM_DIR="$HOME/.nvm"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  source "$HOME/.nvm/nvm.sh"
else
  if dcheck pacman; then
    start_script=`pacman -Ql nvm 2> /dev/null|cut -d' ' -f2|grep /nvm.sh|head -1`
    if [[ -n "$start_script" ]]; then
      prefix=`dirname "$start_script"`
    fi
  elif dcheck brew; then
    prefix=`brew --prefix nvm`
  fi
fi

if [[ -n "$prefix" ]]; then
  [[ -s "$prefix/nvm.sh" ]] && source "$prefix/nvm.sh"
  [[ -s "$prefix/bash_completion" ]] && source "$prefix/bash_completion"
  unset prefix
fi
