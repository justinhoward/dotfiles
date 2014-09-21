if [ $(command -v xautolock 2>&1 /dev/null) ] && [ $(command -v slock 2>&1 /dev/null) ]; then
    xautolock -time 5 -locker slock &
fi