#!/usr/bin/env bash

function drequire() {
  if ! dcheck "$1"; then
    # Allow referencing colors
    # shellcheck disable=2154
    >&2 echo -e "Requires installing ${dred}${1}${ddefault}"
    exit 1
  fi
}
