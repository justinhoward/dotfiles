#!/usr/bin/env bash

dcheck gpg || return

GPG_TTY="$(tty)"
export GPG_TTY
