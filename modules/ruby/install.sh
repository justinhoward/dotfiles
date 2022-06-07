#!/usr/bin/env bash

if dcheck bundler; then
  if ! grep '^BUNDLE_PATH' < ~/.bundle/config >/dev/null; then
    bundle config set path vendor/bundle
  fi
fi
