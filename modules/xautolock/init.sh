if dcheck xautolock && dcheck slock; then
    xautolock -time 5 -locker slock &
fi
