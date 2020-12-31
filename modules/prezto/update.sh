if [[ -d "$dotfiles_zdir/.zprezto" ]]; then
  echo 'Updating prezto...'
  (
    cd "$dotfiles_zdir/.zprezto"
    git fetch > /dev/null
    git merge > /dev/null
    git submodule update --init --recursive > /dev/null
  )
fi
