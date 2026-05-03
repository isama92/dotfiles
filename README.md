# Dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

Platform-specific bootstrap:

- [LINUX.md](LINUX.md) — Ubuntu/Debian (zsh, oh-my-zsh, neovim, Ghostty, dev stack).
- [WINDOWS.md](WINDOWS.md) — Windows (Git for Windows, Chocolatey, WezTerm, Neovim).

## What's included

- **Ghostty** terminal config (Linux only)
- **WezTerm** terminal config (Windows only)
- **Neovim** config (cross-platform)
- **Zsh** config (Linux only)
- **Bash** config (Windows only)

OS-specific files are gated by `.chezmoiignore` so each machine only gets the relevant ones.

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
