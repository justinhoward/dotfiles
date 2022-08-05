#!/usr/bin/env sh

drecommend docker
drecommend docker-compose

if dcheck docker && dcheck docker-compose; then
  mkdir -p ~/.docker/cli-plugins
  ln -sfn "$(which docker-compose)" ~/.docker/cli-plugins/docker-compose
fi
