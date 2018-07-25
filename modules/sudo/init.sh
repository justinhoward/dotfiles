dcheck sudo || return

function _sudo_resolve_aliases() {
  args=()

  while getopts ':c:C:g:h:p:U:u:' opt; do
    case "$opt" in
      # Record all unmatched options and options missing arguments
      \?|:)
        args+=("-$OPTARG")
        ;;
      # Record all options with arguments
      *)
        args+=("-$opt")
        args+=("$OPTARG")
        ;;
    esac
  done

  # Shift off all unparsed options
  shift $((OPTIND-1))

  # Expand any aliases of the command (argument $1)
  while result="$(alias "$1" 2> /dev/null)"; do
    expanded=($(
      echo "$result" \
      | head -n1 \
      | sed -e 's/[^=]*=\(.*\)/\1/' -e "s/^'//" -e "s/'$//" \
    )) \
    || expanded=("$result")

    shift
    set -- "${expanded[@]}" "$@"
  done

  # Remove nocorrect and noglob since those don't work with sudo
  case "$1" in
    nocorrect|noglob) shift ;;
  esac

  /usr/bin/env sudo "${args[@]}" "$@"
}

alias sudo='_sudo_resolve_aliases'
