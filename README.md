# Dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

> On Windows? See [WINDOWS.md](WINDOWS.md) for the platform-specific bootstrap (Git for Windows, Chocolatey, chezmoi, WezTerm).

## What's included

- Ghostty terminal configuration
- Vim configuration
- Zsh configuration

## Requirements

The `.zshrc` in this repo references the following tools and paths. Install/create what you need before running `chezmoi apply`, otherwise aliases and functions will fail silently.

### Shell

- [zsh](https://www.zsh.org/)
- [oh-my-zsh](https://ohmyz.sh/) (or equivalent framework loading the `zstyle` / `zle` config)
- [zsh-navigation-tools](https://github.com/psprint/zsh-navigation-tools) — provides `znt-history-widget` and `n-kill` completions

### CLI tools

- [eza](https://eza.rocks/) — replaces `ls`
- [neovim](https://neovim.io/) — backs the `vim` alias
- [vim-plug](https://github.com/junegunn/vim-plug) — plugin manager used by `init.vim` (install to `$XDG_DATA_HOME/nvim/site/autoload/plug.vim`)
- [nvm](https://github.com/nvm-sh/nvm) — installed at `~/.nvm`
- [Claude Code](https://claude.com/claude-code) — used by the `update` alias
- [Ghostty](https://ghostty.org/) — installed via the piped `mkasberg/ghostty-ubuntu` script in the `update` alias

### Dev stack

- PHP, with a local bin directory at `~/.local/share/php/bin` (`/bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)"` and change installation path)
- Docker — required by the `dep` / `dep_build` functions
- Jupyter with a venv at `~/Dev/jupyter-notebook/venv` — for the `jp` alias
- Laravel Sail — project-local, no global install needed

### System / packaging

- `apt`, `snap`, `flatpak` — all invoked by the `update` alias

### Apps

- [Feishin](https://github.com/jeffvli/feishin) AppImage at `/opt/Feishin/Feishin-linux-x86_64.AppImage`
- [Flameshot](https://flameshot.org/) — the reason for `QT_QPA_PLATFORM=wayland`

### Expected directories

- `~/.local/bin`, `~/.local/share/php/bin`
- `~/Dev/jupyter-notebook` — for the `jp` alias

## Setup on a new machine

### 1. Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. Initialize with this repo

```bash
chezmoi init git@github.com:isama92/dotfiles.git
```

### 3. Preview and apply

```bash
chezmoi diff    # review what will change
chezmoi apply   # apply the dotfiles
```

## Day-to-day workflow

### Editing a config file

Always edit through chezmoi so changes are tracked in the source directory:

```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

### Adding a new file

```bash
chezmoi add ~/.config/some/config
```

### Pushing changes

```bash
chezmoi cd
git add -A && git commit -m "describe the change"
git push
```

### Pulling changes on another machine

```bash
chezmoi update
```

## Machine-specific configuration

Files with a `.tmpl` extension use Go templates for per-machine differences:

```
{{ if eq .chezmoi.hostname "work-pc" }}
# work-specific config
{{ else }}
# home-specific config
{{ end }}
```

To convert an existing file to a template:

```bash
chezmoi cd
mv dot_zshrc dot_zshrc.tmpl
```
