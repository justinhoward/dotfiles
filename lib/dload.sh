function dload() {
    local load_path=$1 load_dir

    if [[ ! -f "$load_path".sh ]] && [[ ! -d "$load_path" ]]; then
        return 1
    fi

    if [[ ! -f "$load_path".sh ]]; then
        load_dir=1
    elif source "$load_path".sh; then
        load_dir=1
    fi

    if [[ -n $load_dir ]] && [[ -d "$load_path" ]]; then
        for file in "$load_path"/*; do
            [[ -f "$file" ]] && source "$file"
        done
    fi
}
