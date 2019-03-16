if dcheck xautolock && dcheck slock; then
    xautolock -time 5 -locker slock -corners 0-00 &
fi
