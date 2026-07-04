# Neovim

PHP/Laravel-focused Neovim setup, used as a PhpStorm replacement. The config
lives in `private_dot_config/nvim` (deployed to `~/.config/nvim`) and is based on
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## Neovim version (managed by bob)

Neovim is installed and version-managed by [bob](https://github.com/MordechaiHadad/bob),
not by apt (Ubuntu's package lags). The active version is **0.12.3**. bob installs
into `~/.local/share/bob`; `~/.local/share/bob/nvim-bin` is prepended to `PATH` in
`shell/exports.sh` so its `nvim` wins over any system `/usr/bin/nvim`. Switch or add
versions with `bob use <version>` / `bob install <version>`, and see `LINUX.md` for
first-time install.

## Why this version of kickstart

This config is pinned to kickstart's last `lazy.nvim`-based commit (`cd7adee`) rather
than the current HEAD, which migrated to Neovim's built-in `vim.pack` manager. That is
a deliberate choice: [lazy.nvim](https://github.com/folke/lazy.nvim) is mature and is
what most tutorials use, and migrating to `vim.pack` would mean re-applying all the
customisations for little gain. nvim-treesitter uses its maintained `main` branch (the
old `master` branch is archived). Both `main`-branch treesitter and the `vim.pack`
kickstart require Neovim 0.12+, which is why the version is managed by bob.

## What's set up

| Area | Tool | Notes |
|------|------|-------|
| Plugin manager | lazy.nvim | bootstraps itself on first launch |
| Fuzzy find | Telescope (+ fzf-native, ui-select) | files by name and by content |
| PHP intelligence | Intelephense (via Mason) | completion, go-to-def, diagnostics |
| Completion popup | blink.cmp | |
| Syntax | nvim-treesitter | parsers auto-install per filetype |
| Quick file jump | Harpoon | ThePrimeagen-style pinned files |
| File tree | neo-tree | toggle with `\` |
| Git | gitsigns | hunk stage/reset/preview in the gutter |
| Hints | which-key | press a prefix and pause to see options |
| Theme | catppuccin-latte | light, matches the git `delta` palette |

Personal preferences baked in: 4-space indent (PSR-12) and an 80-column ruler.

## Requirements (external tools)

chezmoi does not install these. They must be present or parts of the config
degrade or break:

- **Node.js** - Intelephense is a Node package that Mason installs; needs `node` on PATH.
- **`tree-sitter` CLI + a C compiler** - the treesitter `main` branch builds parsers with the `tree-sitter` CLI (`npm install -g tree-sitter-cli`), which then compiles generated C with `cc`/`gcc`. This Neovim build ships no bundled parsers, so without both, syntax highlighting will not work.
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`) - powers Telescope live grep.
- **[fd](https://github.com/sharkdp/fd)** (optional) - faster file picker. On Ubuntu: `sudo apt install fd-find` (binary is `fdfind`, Telescope auto-detects it). Without it, Telescope falls back to ripgrep.
- **A Nerd Font** (optional) - for file-type icons. Install one in the terminal, then set `vim.g.have_nerd_font = true` near the top of `init.lua`. Icons are off by default.
- **Intelephense licence** (optional) - the free tier is wired up. To unlock rename, find-references, auto-import `use`, and generate-constructor, buy a key at https://intelephense.com. Two ways to apply it:
  - Set `licenceKey` in the `servers.intelephense.init_options` block of `init.lua`. Simple, but do not commit a real key to this repo if it is shared.
  - Repo-safe: leave `licenceKey = nil` and put the bare key in `~/intelephense/licence.txt` (Intelephense reads it on startup). This keeps the key out of the dotfiles entirely.

  Either way, restart Neovim or run `:LspRestart` in a PHP buffer to apply. To confirm premium is active, `grn` (rename) and `grr` (find references) start working.

## First-time setup on a new machine

```bash
chezmoi apply          # writes ~/.config/nvim
nvim                   # lazy.nvim installs all plugins, then quit and reopen
```

On the first launch lazy.nvim clones every plugin, and Mason installs the
language servers listed in `init.lua` (intelephense, lua_ls, stylua). Opening the
first `.php` file triggers a one-time Treesitter parser install and starts
Intelephense indexing the project.

Useful maintenance commands inside Neovim:

- `:Lazy` - manage plugins (`U` updates, `S` syncs to the lockfile)
- `:Mason` - manage language servers and tools
- `:checkhealth` - diagnose problems

## Updating plugins

Plugin versions are pinned in `lazy-lock.json`, which is tracked here for
reproducible installs across machines. After updating plugins, re-add the
lockfile so the new versions are committed:

```bash
nvim +"Lazy sync" +qa
chezmoi add ~/.config/nvim/lazy-lock.json
```

## Where things live

- `init.lua` - the whole config: options, keymaps, LSP servers, theme.
- `lua/custom/plugins/init.lua` - personal extra plugins (Harpoon lives here).
- `lua/kickstart/plugins/*` - optional kickstart modules. Enabled ones (`neo-tree`, `gitsigns`, `autopairs`) are `require`d near the bottom of `init.lua`; `debug`, `lint`, and `indent_line` are available but commented out.

## Shortcuts

Leader key is **Space**. Tip: press `<Space>` and pause to let which-key show
you every mapping, or run `<Space>sk` to search all keymaps.

### Fuzzy find

| Keys | Action |
|------|--------|
| `<Space>sf` | search files by name |
| `<Space>sg` | search by grep (live content search) |
| `<Space><Space>` | open buffers |
| `<Space>sw` | search word under cursor |
| `<Space>sd` | search diagnostics |
| `<Space>s.` | recent files |
| `<Space>sr` | resume last search |
| `<Space>sk` | search keymaps |
| `<Space>sn` | search Neovim config files |

### Code navigation (in a source file)

| Keys | Action |
|------|--------|
| `grd` | goto definition |
| `grr` | goto references |
| `gri` | goto implementation |
| `grt` | goto type definition |
| `grD` | goto declaration |
| `K` | hover documentation |
| `gO` | document symbols (file outline) |
| `gW` | workspace symbols |
| `[d` / `]d` | previous / next diagnostic |
| `<Space>q` | diagnostics quickfix list |
| `<Space>th` | toggle inlay hints |
| `grn` | rename symbol (Intelephense premium) |
| `gra` | code action, e.g. add `use` import (Intelephense premium) |

### Files and git

| Keys | Action |
|------|--------|
| `\` | toggle neo-tree file sidebar |
| `]c` / `[c` | next / previous git hunk |
| `<Space>hs` / `<Space>hr` | stage / reset hunk |
| `<Space>hp` | preview hunk |
| `<Space>hb` | blame line |

### Harpoon (quick file jumping)

| Keys | Action |
|------|--------|
| `<Space>a` | add current file to the list |
| `<C-e>` | toggle the quick menu |
| `<Space>1` .. `<Space>4` | jump to pinned file 1 to 4 |
| `<C-p>` / `<C-n>` | previous / next pinned file |

### Essentials

| Keys | Action |
|------|--------|
| `<Esc>` | clear search highlight |
| `<C-h/j/k/l>` | move between splits |
