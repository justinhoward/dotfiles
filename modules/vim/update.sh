echo 'Updating Vim...'
# Don't show the vim buffer and silence the
# "not connected to a terminal" message
nohup vim -c 'NeoBundleUpdate' -c 'qall' >/dev/null 2>&1
