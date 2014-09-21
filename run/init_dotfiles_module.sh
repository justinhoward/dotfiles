function init_dotfiles_module()
{
    local module_load_path="$DOTFILES_PATH/modules/$1"

    if [ ! -d "$module_load_path" ]; then
        >&2 echo "Could not load module $1"
    fi

    if [ -d "$module_load_path/preinit" ]; then
        for file in "$module_load_path"/preinit/*; do
            [ -f "$file" ] && source "$file"
        done
    fi

    if [ -f "$module_load_path"/init.sh ]; then
        source "$module_load_path"/init.sh
    else
        for file in "$module_load_path"/*; do
            [ -f "$file" ] && source "$file"
        done
    fi

    if [ -d "$module_load_path/postinit" ]; then
        for file in "$module_load_path"/postinit/*; do
            [ -f "$file" ] && source "$file"
        done
    fi
}
