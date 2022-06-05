#!/usr/bin/env bash

drecommend() {
  if ! dcheck "$1"; then
    # Allow referencing colors
    # shellcheck disable=2154
    echo -e "Recommends installing ${dcyan}${1}${ddefault}"
  fi
}
