if command -v xautolock > /dev/null 2>&1 && command -v slock > /dev/null 2>&1; then
    xautolock -time 5 -locker slock &
fi