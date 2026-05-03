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
choco install chezmoi fzf ripgrep eza starship vim neovim
```

- `chezmoi` — dotfiles manager.
- `fzf` — fuzzy finder; also used by the `junegunn/fzf` Vim plugin.
- `ripgrep` — fast recursive grep (`rg`), used as the search backend in Vim.
- `eza` — modern `ls` replacement (used by the `ls` alias in `.bashrc`).
- `starship` — cross-shell prompt (loaded from `.bashrc`).
- `vim` — full Vim build with `+python3` (Git Bash ships only a minimal MSYS Vim). Installs to `C:\tools\vim\vim<version>\`. The `.bashrc` aliases `vim` to the highest-versioned install dir.
- `neovim` — Neovim. The `.bashrc` exports `XDG_CONFIG_HOME=~/.config` and `XDG_DATA_HOME=~/.local/share`, so nvim reads its config and plugins from the same paths as on Linux.

## 3. Python

Install Python via the [Python install manager](https://www.python.org/downloads/) from python.org (the page now ships the official Windows install manager). Needed by `puremourning/vimspector` and other dev tooling.

## 4. WezTerm

Install [WezTerm](https://wezterm.org/) (Windows build).

## 5. Post-apply steps

After `chezmoi apply`, run these once in Git Bash:

```bash
# vim-bujo expects ~/.cache to exist or it errors on startup
mkdir -p ~/.cache

# vim-plug for Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# vim-plug for Neovim (uses XDG_DATA_HOME from .bashrc, same path as Linux)
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then open vim and nvim and run `:PlugInstall` in each.
