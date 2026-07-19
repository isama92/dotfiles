# shellcheck shell=bash

# Dep
dep_build() {
  echo 'FROM php:8.4-cli
  RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*
  WORKDIR /app' | docker build --no-cache -t dep -
}
dep() {
  docker run --rm -it \
    -v "$(pwd)":/app \
    -v "$HOME/.ssh":/tmp/.host-ssh:ro \
    -v "${SSH_AUTH_SOCK}":/ssh-agent \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -w /app \
    --entrypoint sh \
    dep \
    -c 'cp -r /tmp/.host-ssh /root/.ssh && chmod 700 /root/.ssh && chmod 600 /root/.ssh/* && php vendor/bin/dep "$@"' sh "$@"
}

# WireGuard
wgup() {
  local host="comfycave.ddns.me" ip
  ip=$(curl -s --max-time 5 "https://1.1.1.1/dns-query?name=${host}&type=A" \
    -H 'accept: application/dns-json' | grep -oP '"data":"\K[0-9.]+' | head -n1)
  if [ -n "$ip" ]; then
    sudo sed -i "/[[:space:]]${host}\$/d" /etc/hosts
    echo "$ip $host" | sudo tee -a /etc/hosts >/dev/null
    echo "wgup: pinned $host -> $ip"
  else
    echo "wgup: DoH lookup failed; using existing /etc/hosts entry" >&2
  fi
  sudo wg-quick up wg0
}

ghmerge() {
  local pr="$1"
  if [ -z "$pr" ]; then
    echo "usage: ghmerge <pr-number|url|branch>" >&2
    return 1
  fi
  gh pr checks "$pr" --watch && gh pr merge "$pr" --squash --delete-branch
}

