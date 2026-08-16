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
- **Git** config with [delta](https://github.com/dandavison/delta) as pager / diff viewer (cross-platform)
- **mpv** player config — scripts and keybindings (cross-platform)

OS-specific files are gated by `.chezmoiignore` so each machine only gets the relevant ones.

## Required external tools

Some configs reference tools that chezmoi does **not** install for you. They must be present on the machine or the config will break:

- **[delta](https://dandavison.github.io/delta/installation.html)** — set as git's `pager` and `diffFilter` in `.gitconfig`. Without it, `git diff`, `git log`, and `git add -p` fail.
- **[mpv](https://mpv.io/installation/)** — the `.config/mpv` config (scripts, keybindings) only takes effect once mpv itself is installed.
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** (Linux/zsh) — smarter `cd`; `.zshrc` initialises it on every shell start, so a missing binary errors on each new shell.
- **[fabric](https://github.com/danielmiessler/fabric)** + **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** (Linux/zsh) — used by the `ytsummarise` function in `shell/functions.sh`; only that function breaks without them.
- **[gnupg](https://gnupg.org/)** provides the commit and tag signing that `.gitconfig` enables. Until your key is imported, every `git commit` fails. See [GPG signing key](#gpg-signing-key).

Install commands live in the platform bootstrap files ([LINUX.md](LINUX.md), [WINDOWS.md](WINDOWS.md)).

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

### Values that must never be committed

Git identity differs per machine (work email + work signing key on one, personal on
another), so those two values live **outside** this repo. `chezmoi init` prompts for
them once and writes them to the machine-local `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.git]
    email = "..."
    signingkey = "..."
```

`dot_gitconfig.tmpl` then reads them as `{{ .git.email }}` and `{{ .git.signingkey }}`.
The prompts are defined in `.chezmoi.toml.tmpl`.

To change them later, edit `~/.config/chezmoi/chezmoi.toml` directly — `chezmoi init`
alone will not re-ask, because `promptStringOnce` only prompts when the value is
missing. To be asked again, delete the file first and re-run `chezmoi init`.

Check what a machine currently resolves to:

```bash
chezmoi execute-template '{{ .git.email }} {{ .git.signingkey }}'
```

> **On an existing machine, run `chezmoi init` once after pulling this change.**
> Until `[data.git]` exists, `chezmoi apply` fails with `map has no entry for key "git"`.

Anything else that must stay local follows the same pattern as
`~/.config/shell/local.sh`: untracked, sourced if present.

### Templates

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

## GPG signing key

`.gitconfig` sets `commit.gpgsign = true` and `tag.gpgsign = true`, so **every commit
and tag fails until the key is present on the machine**. chezmoi does not carry the
key: it is secret material and never enters this repo. Its fingerprint is one of the
two values `chezmoi init` prompts for (see "Machine-specific configuration" above).

### Getting gpg

| Platform | gpg | passphrase prompt |
|----------|-----|-------------------|
| Windows | bundled with Git for Windows at `C:\Program Files\Git\usr\bin\gpg.exe` | `pinentry-w32`, also bundled |
| Ubuntu/Debian | `sudo apt install gnupg` (usually already present) | `sudo apt install pinentry-curses` or `pinentry-gtk2` |
| macOS | `brew install gnupg` | `brew install pinentry-mac`, then set `pinentry-program` in `~/.gnupg/gpg-agent.conf` |

### Importing the key

Get the armoured secret key and the ownertrust file out of 1Password. Never email,
Slack, or cloud-drive them: anyone holding the secret key plus the passphrase can
sign as you.

```bash
gpg --import gpg-private.asc
gpg --import-ownertrust gpg-ownertrust.txt   # keeps the key ultimately trusted
gpg --list-secret-keys --keyid-format=long   # should now list the key

# check signing works; pinentry asks for the passphrase
echo test | gpg --clearsign
```

Delete both files once the import is confirmed:

```bash
shred -u gpg-private.asc gpg-ownertrust.txt 2>/dev/null || rm -f gpg-private.asc gpg-ownertrust.txt
```

Keep the fingerprint to hand: `chezmoi init` asks for it.

### Optional: stop pinentry asking on every commit

Caches the passphrase for 1 h, 8 h maximum:

```bash
printf 'default-cache-ttl 3600\nmax-cache-ttl 28800\n' >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

### Verifying

```bash
git log -1 --format='%G? %GS %GK'    # G = good signature, plus signer and key id
```
