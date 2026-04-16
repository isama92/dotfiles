# Dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

## What's included

- Ghostty terminal configuration
- Vim configuration
- Zsh configuration

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
