# shellcheck shell=bash

# eza powers the ls aliases below; warn (do not disable) if it is ever missing
command -v eza >/dev/null 2>&1 || printf '%s\n' "warning: eza not found, ls aliases will break. Install it: https://github.com/eza-community/eza#installation" >&2

alias ls="eza"
alias l="ls --icons=always --colour=always --colour-scale=size --classify=always --show-symlinks --group --header --time-style=long-iso"
alias vim="nvim"
alias update="sudo apt update -qq && sudo apt dist-upgrade && sudo apt autoremove -y && sudo apt autoclean && sudo snap refresh && flatpak update && claude update && omz update && curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh | sudo bash"
alias jp="cd ~/Dev/jupyter-notebook;source ./venv/bin/activate;jupyter lab"
alias sail="[ -f sail ] && sh sail || sh vendor/bin/sail"
alias a="[ -f sail ] && sh sail || sh vendor/bin/sail php artisan"
alias feishin="/opt/Feishin/Feishin-linux-x86_64.AppImage --no-sandbox > /opt/Feishin/log 2> /opt/Feishin/error_log & disown; exit"
alias mic="pw-loopback --latency=128/48000"
alias wgup="sudo wg-quick up wg0"
alias wgdown="sudo wg-quick down wg0"

