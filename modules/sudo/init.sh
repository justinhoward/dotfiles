dcheck sudo || return

function _sudo_resolve_aliases() {
  local -a args
  while getopts ':Abc:C:Eeg:Hh:iKklnPp:SsU:u:Vv-' opt; do
    case "$opt" in
      -)
        break ;;
      \?|:)
        args+=("-$OPTARG")
        ;;
      *)
        args+=("-$opt")
        args+=("$OPTARG")
        ;;
    esac
    shift $((OPTIND-1))
  done

  result=`alias "$1" 2> /dev/null`
  [[ $? -eq 0 ]] && command=(`echo "$result" | head -n1 | sed "s/[^=]*='\(.*\)'/\1/"`) || command=("$1")
  shift

  case "${command[1]}" in
    nocorrect|noglob)
      command=("${command[@]:1}")
      ;;
  esac

  \sudo "${args[@]}" "${command[@]}" "$@"
}

alias sudo='_sudo_resolve_aliases'
