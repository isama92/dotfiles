# shellcheck shell=bash

# path #
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}
path_prepend "$HOME/.local/share/lerd/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/share/bob/nvim-bin"
path_prepend "$HOME/.opencode/bin"
export PATH

# editor #
if [ -x "$HOME/.local/share/bob/nvim-bin/nvim" ]; then
  export EDITOR="$HOME/.local/share/bob/nvim-bin/nvim"
else
  export EDITOR='nvim'
fi
export VISUAL="$EDITOR"

# nvm #
export NVM_DIR="$HOME/.local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# others #
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
# Qt platform hint: Wayland with an X11 fallback, meaningless off Linux
case "$OSTYPE" in
  linux*) export QT_QPA_PLATFORM="wayland;xcb" ;;
esac

# less: preview archives/binaries via lesspipe (no-op where absent, e.g. git bash) #
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

