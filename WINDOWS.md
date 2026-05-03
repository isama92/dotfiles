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
choco install chezmoi fzf ripgrep eza starship
```

- `chezmoi` — dotfiles manager.
- `fzf` — fuzzy finder; also used by the `junegunn/fzf` Vim plugin.
- `ripgrep` — fast recursive grep (`rg`), used as the search backend in Vim.
- `eza` — modern `ls` replacement (used by the `ls` alias in `.bashrc`).
- `starship` — cross-shell prompt (loaded from `.bashrc`).

## 3. Python

Install Python via the [Python install manager](https://www.python.org/downloads/) from python.org (the page now ships the official Windows install manager). Needed by `puremourning/vimspector` and other dev tooling.

## 4. WezTerm

Install [WezTerm](https://wezterm.org/) (Windows build).
