# Linux setup

Setup notes for managing this dotfiles repo on Linux (Ubuntu/Debian).

## 1. Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

## 2. Initialize and apply

```bash
chezmoi init git@github.com:isama92/dotfiles.git
chezmoi diff      # preview
chezmoi apply
```

## 3. Zsh + oh-my-zsh

```bash
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Follow the prompt to set zsh as the default shell.

### Powerlevel10k theme

1. Install the [4 recommended fonts](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k).
2. Set `MesloLGS NF Regular` as the terminal font.
3. Install the theme:

   ```bash
   sudo apt install fonts-powerline
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
       ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

4. Restart the terminal and follow the configuration wizard.

### Plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/supercrabtree/k \
    $ZSH_CUSTOM/plugins/k

sudo apt install fzf chroma

# zsh-navigation-tools — provides znt-history-widget and n-kill
sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"
```

The plugin list is already declared in `.zshrc` — no manual edit needed.

## 4. Neovim

```bash
sudo apt install neovim python3-pip
pip3 install --user neovim   # Python provider, optional
```

Install vim-plug:

```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Open nvim and run `:PlugInstall`.

## 5. Terminal (Ghostty)

Install via the [mkasberg/ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) script — also automated by the `update` alias in `.zshrc`.

## 6. CLI tools

- [eza](https://eza.rocks/) — replaces `ls`.
- [nvm](https://github.com/nvm-sh/nvm) — installed at `~/.nvm`.
- [Claude Code](https://claude.com/claude-code) — used by the `update` alias.

## 7. Dev stack

- **PHP** — `/bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)"` (change install path to `~/.local/share/php`).
- **Docker** — required by the `dep` / `dep_build` functions.
- **Jupyter** — venv at `~/Dev/jupyter-notebook/venv`, used by the `jp` alias.
- **Laravel Sail** — project-local, no global install needed.

## 8. System / packaging

`apt`, `snap`, and `flatpak` are all invoked by the `update` alias.

## 9. Apps

- [Feishin](https://github.com/jeffvli/feishin) AppImage at `/opt/Feishin/Feishin-linux-x86_64.AppImage`.
- [Flameshot](https://flameshot.org/) — the reason for `QT_QPA_PLATFORM=wayland` in `.zshrc`.

## 10. Expected directories

- `~/.local/bin`
- `~/.local/share/php/bin`
- `~/Dev/jupyter-notebook`
