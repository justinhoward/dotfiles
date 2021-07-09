#!/usr/bin/env bash

function drequire() {
	if ! dcheck "$1"; then
		>&2 echo -e "Requires installing ${dred}${1}${ddefault}"
		exit 1
	fi
}
