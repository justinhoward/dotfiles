#!/usr/bin/env sh
# Translate a screen-local slot into an AeroSpace workspace name.
set -eu

if [ "$#" -ne 2 ]; then
    echo 'Usage: workspace.sh focus|send 1..8' >&2
    exit 2
fi

action=$1
slot=$2
case "$action" in
    focus) command=workspace ;;
    send) command=move-node-to-workspace ;;
    *) echo "Unknown action: $action" >&2; exit 2 ;;
esac
case "$slot" in
    [1-8]) ;;
    *) echo 'Workspace slot must be 1..8' >&2; exit 2 ;;
esac

monitor=$(aerospace list-monitors --focused --format '%{monitor-id}')
case "$monitor" in
    [1-3]) ;;
    *) echo "Unexpected focused monitor: $monitor" >&2; exit 1 ;;
esac

# Sending does not follow focus, just like the current Alt+Shift+number keys.
exec aerospace "$command" "$monitor-$slot"
