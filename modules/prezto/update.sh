if [[ -d "$dotfiles_zdir/.zprezto" ]]; then
  echo 'Updating Prezto...'
  (
    cd "$dotfiles_zdir/.zprezto"
    git pull > /dev/null
    git submodule update --init --recursive > /dev/null
  )
fi
