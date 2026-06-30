# shellcheck shell=bash

# Dep

dep_build() {
  echo 'FROM php:8.4-cli
  RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*
  WORKDIR /app' | docker build --no-cache -t dep -
}

dep() {
  docker run --rm -it \
    -v $(pwd):/app \
    -v ~/.ssh:/tmp/.host-ssh:ro \
    -v ${SSH_AUTH_SOCK}:/ssh-agent \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -w /app \
    --entrypoint sh \
    dep \
    -c "cp -r /tmp/.host-ssh /root/.ssh && chmod 700 /root/.ssh && chmod 600 /root/.ssh/* && php vendor/bin/dep $*"
}

