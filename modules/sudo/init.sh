dcheck sudo || return

function _sudo_resolve_aliases() {
  local -a args

  while getopts ':c:C:g:h:p:U:u:-' opt; do
    case "$opt" in
      # Catch -- argument and stop parsing
      # getopts also automatically stops parsing if it encounters a non-option
      # argument
      -)
        break
        ;;
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
  result=$(alias "$1" 2> /dev/null)
  [[ $? -eq 0 ]] && command=($(echo "$result" | head -n1 | sed -e "s/[^=]*=\(.*\)/\1/" -e "s/^'//" -e "s/'$//" )) || command=("$1")
  shift

  # Remove nocorrect and noglob since those don't work with sudo
  case "${command[1]}" in
    nocorrect|noglob)
      command=("${command[@]:1}")
      ;;
  esac

  /usr/bin/env sudo "${args[@]}" "${command[@]}" "$@"
}

alias sudo='_sudo_resolve_aliases'
