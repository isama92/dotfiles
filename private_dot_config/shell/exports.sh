# shellcheck shell=bash

# path #
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}
path_prepend "$HOME/.local/share/php/bin"
path_prepend "$HOME/.local/bin"
export PATH

# editor #
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# nvm #
export NVM_DIR="$HOME/.local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# others #
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export PHP_INI_SCAN_DIR="$HOME/.local/share/php/bin:$PHP_INI_SCAN_DIR"
export QT_QPA_PLATFORM="wayland;xcb"

# less: preview archives/binaries via lesspipe (no-op where absent, e.g. git bash) #
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

