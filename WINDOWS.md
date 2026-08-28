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
choco install chezmoi fzf ripgrep eza starship neovim delta jq mpv nerd-fonts-firacode nodejs-lts mingw lazygit zoxide
```

- `chezmoi` — dotfiles manager.
- `fzf` — fuzzy finder. The `.bashrc` sources its `key-bindings.bash` (downloaded in step 7) for `Ctrl-R` history search and `Ctrl-T` file picker.
- `ripgrep` — fast recursive grep (`rg`).
- `eza` — modern `ls` replacement; aliased as `ls` in `.bashrc`.
- `starship` — cross-shell prompt (loaded from `.bashrc`).
- `neovim` — Neovim. The `.bashrc` aliases `vim` to `nvim` and exports `XDG_CONFIG_HOME=~/.config` / `XDG_DATA_HOME=~/.local/share`, so nvim reads its config and plugins from the same paths as on Linux.
- `git-delta` — git pager / diff viewer referenced by `.gitconfig` (provides the `delta` binary). Without it, `git diff` / `git log` fail. See [installation docs](https://dandavison.github.io/delta/installation.html).
- `jq` — JSON processor. `~/.claude/statusline.sh` pipes Claude Code's JSON through it to build the status line; without it the status line renders empty.
- `mpv` — media player; the `.config/mpv` config (scripts, keybindings) only applies once installed. See [installation docs](https://mpv.io/installation/).
- `nerd-fonts-firacode` — FiraCode Nerd Font, set as the font in `.wezterm.lua`. Required for WezTerm to render correctly; without it the terminal falls back to a default font and icons/glyphs show as boxes.
- `nodejs-lts` — Neovim needs `node` on `PATH` for Mason to install Intelephense (the PHP language server, a Node package). Without it Mason reports `intelephense: failed to install`. It also provides the `npm` used in step 7.
- `mingw` — provides `gcc`. nvim-treesitter's `main` branch generates C and compiles it locally, so without a C compiler no parsers build and syntax highlighting silently never works. Note the npm `tree-sitter` CLI is built for the `windows-msvc` target and invokes `cl.exe`, failing with `Error: program not found` even once gcc is installed; `init.lua` sets `CC=gcc` on Windows to redirect it.
- `lazygit` — terminal UI for git. A standalone convenience tool: nothing in this repo configures it or depends on it.
- `zoxide` — frecency-based `cd`. The `.bashrc` initialises it last (its hook appends to `PROMPT_COMMAND`, which starship also sets), giving you `z <partial-name>` to jump and `zi` to pick interactively through fzf. The hook detects Git Bash and runs paths through `cygpath -w`, so the database stores Windows-style paths; it lives at `%LOCALAPPDATA%\zoxide\db.zo`, not under `~/.local/share`, and is machine-local, never synced.

The `.bashrc` `update` alias chains the upgrades together: `choco upgrade all -y && uv tool upgrade ha-mcp && claude update`. `choco upgrade` needs an elevated shell, so run Git Bash as Administrator when you use it.

## 3. GPG signing key

`.gitconfig` signs every commit and tag, so commits fail until your key is imported.
The procedure is the same on every platform and lives in
[README.md](README.md#gpg-signing-key). Two Windows specifics:

- GnuPG is already bundled with Git for Windows at
  `C:\Program Files\Git\usr\bin\gpg.exe`, with `pinentry-w32` for passphrase prompts.
  Nothing extra needs installing.
- `gpg` is only on `PATH` inside Git Bash, so `dot_gitconfig.tmpl` sets `gpg.program`
  explicitly on Windows. That is what makes signing work from PowerShell, editors,
  and GUI clients as well. It is handled by the template; nothing to do by hand.

Do the import now, because step 4 asks for the key's fingerprint.

## 4. Initialise this repo

Only once step 1 is done and the 1Password SSH agent is active — the clone goes over
SSH and will fail without it.

```bash
chezmoi init git@github.com:isama92/dotfiles.git
chezmoi diff      # preview
chezmoi apply
```

`chezmoi init` prompts for the **git author email** and the **GPG signing key**
(the fingerprint from step 3). Those two values are per machine and are stored in
`~/.config/chezmoi/chezmoi.toml`, outside this repo — see "Machine-specific
configuration" in [README.md](README.md).

## 5. Python

Install Python via the [Python install manager](https://www.python.org/downloads/) from python.org (the page now ships the official Windows install manager).

[uv](https://docs.astral.sh/uv/) manages the Python CLI tools installed into `~/.local/bin`, which `exports.sh` puts on `PATH`. The `update` alias calls `uv tool upgrade ha-mcp`, so without `uv` that alias stops at its second step.

## 6. WezTerm

Install [WezTerm](https://wezterm.org/) (Windows build).

## 7. Post-apply steps

After `chezmoi apply`, run these once in Git Bash:

```bash
# fzf shell integration (Ctrl-R history, Ctrl-T file picker, Alt-C dir jump)
# choco's fzf package ships only the binary; the keybindings script is sourced
# from this path by .bashrc.
curl -fLo ~/.local/share/fzf/key-bindings.bash --create-dirs \
    https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash

# Treesitter parser builder. The main branch of nvim-treesitter generates C and
# compiles it with the tree-sitter CLI plus gcc (mingw, step 2). Without both,
# no parsers build and syntax highlighting never works.
npm install -g tree-sitter-cli
```

### Then open Neovim

**There is no `:PlugInstall` here.** This config is
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) on
[lazy.nvim](https://github.com/folke/lazy.nvim), which bootstraps itself: the
first `nvim` launch clones lazy.nvim, installs every plugin, and lets Mason
fetch the language servers. Running `:PlugInstall` gives
`E492: Not an editor command`, because vim-plug is not used at all.

Quit and reopen once it settles, then verify with `:Lazy`, `:Mason`, and
`:checkhealth`.

Note: Windows nvim uses an `nvim-data` suffix for its data dir (not `nvim`),
even with `XDG_DATA_HOME` set. Check inside nvim with `:echo stdpath('data')`.

See [VIM.md](VIM.md) for the keymaps and the full requirement list.
