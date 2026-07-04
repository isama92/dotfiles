# Windows setup

Setup notes for managing this dotfiles repo on Windows.

## 1. Git for Windows (Git Bash)

Install [Git for Windows](https://git-scm.com/install/windows).

During the installer, pick these non-default options:

- **Choose SSH executable**: select **"Use external OpenSSH"** (lets 1Password's SSH agent handle keys).
- **Choose HTTPS transport backend**: select **"Use the native Windows Secure Channel library"**.

### Hand SSH agent duty to 1Password

1. Open `services.msc` and **disable** the **"OpenSSH Authentication Agent"** service (set Startup type to *Disabled* and stop it). Otherwise it competes with 1Password for the agent socket.
2. In 1Password, go to **Settings → Developer** and enable **"Use the SSH agent"**.

## 2. Chocolatey + chezmoi

Install [Chocolatey](https://chocolatey.org/install) following the official instructions.

Then, in a terminal **running as Administrator**:

```powershell
choco install chezmoi fzf ripgrep eza starship neovim git-delta mpv
```

- `chezmoi` — dotfiles manager.
- `fzf` — fuzzy finder. The `.bashrc` sources its `key-bindings.bash` (downloaded in step 5) for `Ctrl-R` history search and `Ctrl-T` file picker.
- `ripgrep` — fast recursive grep (`rg`).
- `eza` — modern `ls` replacement; aliased as `ls` in `.bashrc`.
- `starship` — cross-shell prompt (loaded from `.bashrc`).
- `neovim` — Neovim. The `.bashrc` aliases `vim` to `nvim` and exports `XDG_CONFIG_HOME=~/.config` / `XDG_DATA_HOME=~/.local/share`, so nvim reads its config and plugins from the same paths as on Linux.
- `git-delta` — git pager / diff viewer referenced by `.gitconfig` (provides the `delta` binary). Without it, `git diff` / `git log` fail. See [installation docs](https://dandavison.github.io/delta/installation.html).
- `mpv` — media player; the `.config/mpv` config (scripts, keybindings) only applies once installed. See [installation docs](https://mpv.io/installation/).

## 3. Python

Install Python via the [Python install manager](https://www.python.org/downloads/) from python.org (the page now ships the official Windows install manager).

## 4. WezTerm

Install [WezTerm](https://wezterm.org/) (Windows build).

## 5. Post-apply steps

After `chezmoi apply`, run these once in Git Bash:

```bash
# vim-plug for Neovim
# Note: Windows nvim uses an 'nvim-data' suffix for the data dir (not 'nvim'),
# even with XDG_DATA_HOME set. Verify inside nvim with :echo stdpath('data').
curl -fLo ~/.local/share/nvim-data/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# fzf shell integration (Ctrl-R history, Ctrl-T file picker, Alt-C dir jump)
# choco's fzf package ships only the binary; the keybindings script is sourced
# from this path by .bashrc.
curl -fLo ~/.local/share/fzf/key-bindings.bash --create-dirs \
    https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash
```

Then open nvim and run `:PlugInstall`.
