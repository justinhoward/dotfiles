_dconfigs=()

function dconfig()
{
	case "${_dconfigs[@]}" in *"$1"*) return ;; esac
    _dconfigs+="$1"

    dload "$DOTFILES_PATH/config/$1"
}
