#!/usr/bin/env bash

dcheck() {
  command -v "$1" > /dev/null 2>&1
  return $?
}
