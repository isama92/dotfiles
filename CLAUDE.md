# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The **chezmoi source directory** for personal dotfiles, shared between Ubuntu/Debian (zsh) and Windows (Git Bash). There is no build, no test suite, and no application code. The "product" is a set of config files that chezmoi renders into `$HOME` on each machine.

Files here are *sources*, not the live configs. `dot_zshrc` in this repo becomes `~/.zshrc` on the machine. Edit the source, then apply.

## Commands

Run these from Git Bash on Windows (chezmoi is installed via Chocolatey at `/c/ProgramData/chocolatey/bin/chezmoi`).

```bash
chezmoi diff              # preview what apply would change in $HOME — do this before apply
chezmoi apply             # render sources into $HOME
chezmoi status            # short status of files that differ
chezmoi add ~/.config/x   # pull an existing $HOME file into this repo (picks the right dot_/private_ prefix)
chezmoi edit ~/.zshrc     # open the *source* of a target file
chezmoi update            # git pull + apply, used on other machines
chezmoi execute-template < dot_bashrc.tmpl   # debug a .tmpl without applying
```

There is no linter wired up, but shell files carry `# shellcheck shell=bash` headers — `shellcheck` is the intended checker for `private_dot_config/shell/*.sh`. Lua in `private_dot_config/nvim` is formatted by `stylua` using `private_dot_config/nvim/dot_stylua.toml` (2-space indent, 160 columns, single quotes, no call parens); conform.nvim runs it on save inside Neovim.

## Naming conventions (chezmoi attributes)

The filename encodes the target path and its permissions. Get these wrong and the file lands in the wrong place or with the wrong mode:

| Source | Target |
|--------|--------|
| `dot_zshrc` | `~/.zshrc` |
| `private_dot_config/mpv/mpv.conf` | `~/.config/mpv/mpv.conf`, dir mode 0700 |
| `dot_claude/executable_statusline.sh` | `~/.claude/statusline.sh`, mode +x |
| `dot_bashrc.tmpl` | `~/.bashrc`, rendered as a Go template |
| `Dev/scripts/executable_migrate_tinkerwell.sh` | `~/Dev/scripts/migrate_tinkerwell.sh` |
| `private_dot_config/nvim/create_lazy-lock.json` | `~/.config/nvim/lazy-lock.json`, written only if absent, never overwritten |

Prefer `chezmoi add` over hand-naming a new file — it derives the prefixes for you.

Note: `dot_bashrc.tmpl` uses template directives to gate the Windows-only parts (which shared files it sources, and the Windows alias block). Keep the `.tmpl` extension, and render it for the current machine with `chezmoi execute-template < dot_bashrc.tmpl` before applying.

## Machine-local data (never committed)

`.chezmoi.toml.tmpl` is the config template: `chezmoi init` renders it into the machine-local `~/.config/chezmoi/chezmoi.toml`, which is outside this repo. It uses `promptStringOnce` to ask for the git author email and GPG signing key, exposed to templates as `.git.email` / `.git.signingkey` and consumed by `dot_gitconfig.tmpl` — the work identity on one machine and the personal one on another never enter git history.

Consequences to keep in mind:

- Adding a new `promptStringOnce` means every existing machine must re-run `chezmoi init`; until then `chezmoi apply` fails with `map has no entry for key ...` (chezmoi templates use `missingkey=error`).
- `chezmoi execute-template '{{ .git.email }}'` shows what a machine resolves to without applying.
- `~/.config/shell/local.sh` is the equivalent escape hatch for shell config: untracked, sourced if present.

## Cross-platform gating

`.chezmoiignore` is itself templated and decides which files reach a given machine:

- `*.md` and `README.md` are ignored everywhere — the documentation stays in the repo and is never deployed to `$HOME`.
- Non-Linux machines skip `.zshrc`, `.p10k.zsh`, `.config/ghostty`.
- Non-Windows machines skip `.bash_profile`, `.wezterm.lua`, `.config/starship.toml`.
- SSH key material (`.ssh/id_*`, `known_hosts`, `authorized_keys`) is ignored as a safety net; only `.ssh/config` is tracked.

**Any new OS-specific file must be added to `.chezmoiignore`**, otherwise it deploys to both platforms. The patterns there are *target* paths (`.zshrc`), not source names (`dot_zshrc`).

## Shell configuration architecture

Both shells converge on one shared layer, but they do not both take all of it. `dot_zshrc` (Linux) ends with:

```bash
for f in ~/.config/shell/{exports,aliases,functions,local}.sh; do [ -r "$f" ] && . "$f"; done
```

`dot_bashrc.tmpl` runs that same loop on Linux, but on Windows a template guard narrows it to `{exports,local}.sh`.

So `private_dot_config/shell/` is where cross-shell changes belong:

- `exports.sh` — `PATH` (via the idempotent `path_prepend` helper), `EDITOR`, nvm, and the `XDG_CONFIG_HOME` / `XDG_DATA_HOME` exports that let Windows nvim read the same config paths as Linux.
- `aliases.sh` — `ls`→eza, `vim`→nvim, Laravel `a` (php artisan) and `pint`, the big `update` chain.
- `functions.sh` — `dep`/`dep_build` (dockerised Deployer), `wgup`, `ghmerge`, `ytsummarise`.
- `local.sh` — **not tracked**; the machine-local escape hatch for anything that must not be committed.

Gotcha: `aliases.sh` and `functions.sh` are Linux-only in practice (`update` drives apt/snap/flatpak, plus `feishin`, `mic`, `wgdown`, `wgup`, `dep`), so Git Bash does not source them at all. `dot_bashrc.tmpl` instead redefines the portable ones (`ls`, `l`, `vim`, and a choco/uv-based `update`) alongside the git aliases zsh gets from the oh-my-zsh `git` plugin and bash does not. `exports.sh` *is* still sourced on Windows, because `XDG_CONFIG_HOME` / `XDG_DATA_HOME` and `~/.local/bin` on `PATH` are needed there; its Linux-only entries are self-gating (`path_prepend` tests `[ -d ]`, `QT_QPA_PLATFORM` sits behind an `$OSTYPE` case). Anything genuinely platform-specific either goes in the platform rc file or needs a template guard.

Prompt differs by platform on purpose: Powerlevel10k (`dot_p10k.zsh`, 91 KB of generated config — regenerate with `p10k configure`, do not hand-edit) on Linux, starship on Windows.

## Neovim

Config is a single ~1000-line `private_dot_config/nvim/init.lua` based on kickstart.nvim, deliberately pinned to kickstart's last lazy.nvim commit (`cd7adee`) rather than upstream HEAD, which migrated to `vim.pack`. Requires Neovim 0.12+, version-managed by `bob`, with `~/.local/share/bob/nvim-bin` prepended in `exports.sh`.

- LSP servers and Mason tool list live in the `servers` table around `init.lua:616` (intelephense, lua_ls, stylua). PHP/Laravel is the target workload.
- Optional kickstart modules live in `lua/kickstart/plugins/`; they only take effect when `require`d at the bottom of `init.lua` (~line 980). `debug`, `lint`, `indent_line` are present but commented out.
- Personal plugins go in `lua/custom/plugins/init.lua` (currently Harpoon) — keep them out of `lua/kickstart/` so upstream diffs stay clean.
- `lazy-lock.json` is tracked as `create_lazy-lock.json`: chezmoi writes it only when it does not already exist, so a new machine bootstraps on the pinned commits and thereafter lazy.nvim owns the file. It never appears in `chezmoi diff` and `apply` never reverts it. Refresh the committed pin deliberately with `chezmoi add --create --force ~/.config/nvim/lazy-lock.json`; dropping `--create` reintroduces the overwrite-on-apply fight between chezmoi and lazy.nvim.

`VIM.md` documents the keymaps and the external tool requirements (node, tree-sitter CLI + C compiler, ripgrep, fd); update it alongside keymap or plugin changes.

## mpv

`private_dot_config/mpv/scripts/modernz.lua` is **vendored upstream** (ModernZ, ~4.5k lines). Do not hand-edit it — configure it through `script-opts/modernz.conf`, and update it by replacing the file wholesale.

`skip_button.lua` (contextual Skip Intro/Outro for chaptered files, coexists with the ModernZ OSC by only grabbing clicks over its own rect) and `open_url.lua` are local scripts.

These three files are coupled: `mpv.conf` sets `osc=no` and `title-bar=no` *because* ModernZ draws its own OSC and title bar; `input.conf` binds `b` to `script-message osc-visibility cycle`, which only behaves as a clean two-state toggle because `modernz.conf` sets `visibility_modes=auto_always`. Changing one usually means touching the others.

## External tool contract

Several configs hard-depend on binaries chezmoi does not install — a missing one breaks the shell or git, not just one feature: `delta` (git `pager` and `diffFilter`), `eza` (`ls` aliases), `zoxide` (evaluated on every zsh start), `fzf`, `starship`, `jq` (the Claude statusline parses its JSON with it). When a change introduces a new hard dependency, document it in `README.md` **and** the relevant platform file (`LINUX.md` / `WINDOWS.md`), which carry the install commands.

## Known rough edges

- `private_dot_ssh/private_config` contains internal VCSW host aliases and IPs plus `IdentityAgent ~/.1password/agent.sock`. Treat it as sensitive; never widen what is committed there.
- `dot_claude/settings.json` is the user-level Claude Code config (model, effort, enabled plugins, statusline). Changing it changes behaviour on every machine after the next `chezmoi apply`.

## Commit style

Short, lowercase, no prefix conventions. Scope comes first when relevant, sections separated by `;`:

```
zoxide, fabric, ytsummarise
claude: added rust analyser; mpv: added op/end labels to skipper
nvim managed via bob; treesitter fix
```

Commits and tags are GPG-signed (`commit.gpgsign = true`), so do not pass `--no-gpg-sign`.
