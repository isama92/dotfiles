# Linux setup

Setup notes for managing this dotfiles repo on Linux (Ubuntu/Debian).

## 1. Install chezmoi and apply this repo

One-shot — install chezmoi, clone this repo, and apply immediately:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply isama92
```

Or two-step if you want to preview first:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)"
mv bin/chezmoi .local/bin/chezmoi
rmdir bin
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
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k

sudo apt install fzf chroma

# zsh-navigation-tools — provides znt-history-widget and n-kill
sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"
```

The plugin list is already declared in `.zshrc` — no manual edit needed.

## 4. Neovim

Neovim is version-managed by [bob](https://github.com/MordechaiHadad/bob), not apt
(Ubuntu's package lags well behind).

```bash
# install bob (no sudo; lives in ~/.local/bin)
curl -fsSL -o /tmp/bob.zip \
    https://github.com/MordechaiHadad/bob/releases/latest/download/bob-linux-x86_64.zip
unzip -o /tmp/bob.zip -d /tmp/bob
install -m 0755 /tmp/bob/bob-linux-x86_64/bob ~/.local/bin/bob

# install and activate Neovim
bob install 0.12.3
bob use 0.12.3
```

`shell/exports.sh` already prepends `~/.local/share/bob/nvim-bin` to `PATH`, so open a
new shell and `nvim` resolves to the bob build.

The editor config (based on kickstart.nvim) is deployed by chezmoi to `~/.config/nvim`
and bootstraps itself: the first `nvim` launch installs all plugins via lazy.nvim and
the language servers via Mason. Treesitter parsers need the `tree-sitter` CLI plus a C
compiler:

```bash
npm install -g tree-sitter-cli   # uses nvm-provided npm; no sudo
```

See `VIM.md` for the full setup and shortcuts.

## 5. Terminal (Ghostty)

Install via the [mkasberg/ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) script, also automated by the `update` alias in `.config/shell/aliases.sh`.

## 6. CLI tools

- [eza](https://eza.rocks/) — replaces `ls`.
- [nvm](https://github.com/nvm-sh/nvm) — installed at `~/.nvm`.
- [Claude Code](https://claude.com/claude-code) — used by the `update` alias.
- [delta](https://dandavison.github.io/delta/installation.html) — git pager / diff viewer referenced by `.gitconfig`. `sudo apt install git-delta` (or grab the `.deb` from [releases](https://github.com/dandavison/delta/releases) if the apt version is old). Without it, `git diff` / `git log` fail.
- [zoxide](https://github.com/ajeetdsouza/zoxide) — frecency-based `cd` (`z`, `zi`), initialised by `.zshrc` on every shell start.
- [fabric](https://github.com/danielmiessler/fabric) — LLM prompt-pattern CLI used by the `ytsummarise` function; needs a one-off `fabric --setup` for API keys and patterns.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — how fabric pulls YouTube transcripts for `ytsummarise`.
- [gnupg](https://gnupg.org/) provides the commit and tag signing enabled in `.gitconfig`; `git commit` fails until your key is imported. Usually already installed, but passphrase prompts need a pinentry (`sudo apt install pinentry-curses` or `pinentry-gtk2`). Procedure: [GPG signing key](README.md#gpg-signing-key).

## 7. Dev stack

- **PHP** — via Lerd, https://lerd.sh/.
- **Docker** — required by the `dep` / `dep_build` functions.
- **Jupyter** — venv at `~/Dev/jupyter-notebook/venv`, used by the `jp` alias.

## 8. System / packaging

`apt`, `snap`, and `flatpak` are all invoked by the `update` alias.

## 9. Apps

- [Feishin](https://github.com/jeffvli/feishin) AppImage at `/opt/Feishin/Feishin-linux-x86_64.AppImage`.
- [Flameshot](https://flameshot.org/) — the reason for `QT_QPA_PLATFORM=wayland` in `.zshrc`.
- [mpv](https://mpv.io/installation/) — media player; the `.config/mpv` config (scripts, keybindings) only applies once installed. `sudo apt install mpv`.

## 10. Zed (desktop editor)

GUI editor for Nautilus double-click and "Open With". The terminal stays on nvim, the two live in
separate registries (`$EDITOR` vs XDG MIME defaults).

Install from [zed.dev](https://zed.dev/download) **before** applying: `.zshrc` evals
`zed --completions zsh` on every shell start, and the MIME script below skips itself when the
binary is missing.

chezmoi carries both pieces:

- `.local/share/applications/dev.zed.Zed.desktop`: Zed's own entry, patched to add
  `inode/directory` (folders get an "Open With Zed" item) and `--new` (opens its own window
  instead of joining whatever project is already open).
- `.chezmoiscripts/run_onchange_after_zed-mime-defaults.sh`: claims the text and code MIME types
  for Zed, and pins `inode/directory` back to Nautilus so folders still browse rather than open
  in the editor.

```bash
# GNOME owns mimeapps.list, so back it up first
cp ~/.config/mimeapps.list ~/.config/mimeapps.list.bak-pre-zed

chezmoi apply
nautilus -q          # reload associations
```

Zed's self-update rewrites its desktop entry and drops the patch, so re-run `chezmoi apply` after
a Zed upgrade. Edit the type list in the script and the next apply re-runs it.

## 11. Expected directories

- `~/.local/bin/`
- `~/.local/share/lerd/`
- `~/Dev/jupyter-notebook/`
