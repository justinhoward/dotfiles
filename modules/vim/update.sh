echo 'Updating vim plugins...'
# Don't show the vim buffer and silence the
# "not connected to a terminal" message
(
  dcheck nvim && vim=nvim || vim=vim
  nohup "$vim" -c 'PlugUpgrade' -c 'PlugInstall' -c 'PlugUpdate' -c 'qall' >/dev/null 2>&1
)
