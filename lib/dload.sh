#!/usr/bin/env bash

dload() {
  local load_path="$1" load_dir

  if [ -f "$load_path.sh" ]; then
    # If a file is found, then only load the directory if it returns a
    # successful exit code
    . "$load_path.sh" && [ -d "$load_path" ] && load_dir=1
  elif [ -d "$load_path" ]; then
    # Otherwise, always try the directory
    load_dir=1
  else
    # If no module file or directory is found, return error code
    return 1
  fi

  if [ -n "$load_dir" ]; then
    for file in "$load_path"/*.sh; do
      . "$file"
    done
  fi
}
