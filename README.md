# Justin Howard's Dotfiles

Cross-platform dotfiles for macOS and Linux, managed with
[chezmoi][chezmoi]. One repository drives every shell context — interactive,
login, and non-interactive — templated per-machine and per-OS so it installs
cleanly on a fresh system and adapts to wherever it lands.

The interactive shell is Zsh with a fast startup path: [Powerlevel10k][p10k] for
the prompt (async git via `gitstatusd`), [sheldon][sheldon] to manage plugins,
and [mise][mise] for runtime versions. Bash gets a lightweight, dependency-free
parallel setup. Shared environment and aliases are written once in POSIX `sh` and
sourced by both shells.

## Installing on a new machine

Install `git` and [chezmoi][chezmoi], then:

```bash
git clone https://github.com/justinhoward/dotfiles.git ~/.dotfiles
chezmoi init --source="$HOME/.dotfiles"   # prompts once for per-machine data
chezmoi diff                               # preview what will change
chezmoi apply                              # write it out
```

This repo sets `sourceDir = ~/.dotfiles` and `.chezmoiroot = home`, so the actual
chezmoi source lives in `~/.dotfiles/home`. `chezmoi init` prompts for per-machine
data (git name / email / commit signing key) and stores it in your local chezmoi
config, which is never committed. `run_` scripts then bootstrap the rest: they
recommend any missing CLI tools, install the nvim plugins, and enable the
ssh-agent user service on Linux.

## How it's organized

Everything chezmoi manages lives under `home/`:

- `dot_zshenv`, `dot_zprofile.tmpl`, `dot_zshrc.tmpl` — the three Zsh contexts
  (always-on env, login-only, interactive).
- `dot_bashrc`, `dot_bash_profile`, `dot_profile` — Bash / POSIX parallels.
- `dot_config/sh/env.sh` — shared POSIX environment for **all** shells (`PATH`,
  XDG dirs, editor/pager, plus OS-specific blocks).
- `dot_config/sh/rc.d/*.sh` — interactive aliases and helpers split by topic
  (core, git, homebrew, npm, …), sourced by both Zsh and Bash.
- `dot_config/sheldon/plugins.toml` — Zsh plugins (zsh-defer, Powerlevel10k,
  autosuggestions, history-substring-search, fast-syntax-highlighting).
- `dot_p10k.zsh` — the prompt configuration.
- `dot_config/…` — app configs (nvim, kitty, git, bat, ctags, …).
- `run_*` — one-shot and on-change setup scripts.

OS-specific files are guarded in `home/.chezmoiignore` — macOS-only (yabai, skhd,
swiftbar, finicky) and Linux-only (systemd user units, XDG user-dirs).

## Per-machine customization

- **Prompted data** (git identity, signing key) is captured by `chezmoi init` and
  stored outside the repo.
- **Write-once files** use chezmoi's `create_` prefix — e.g. kitty's
  `create_font_size.conf` is seeded with a default and then left alone, so each
  machine can set its own font size without the repo overwriting it.
- **OS branches** are handled with Go templates (`{{ if eq .chezmoi.os "darwin" }}`).

## Updating

```bash
chezmoi update      # git pull in ~/.dotfiles, then apply
```

Or review before applying:

```bash
git -C ~/.dotfiles pull && chezmoi diff && chezmoi apply
```

## Fonts

The prompt and terminal expect a [Nerd Font][nerdfonts]. See the runbooks:

- [runbooks/nerd-fonts.md](runbooks/nerd-fonts.md)
- [runbooks/arch-linux-fonts.md](runbooks/arch-linux-fonts.md)

## Linting

`shellcheck` runs in CI over the repo's shell scripts — see
`.github/workflows/ci.yml`.

[Licensed](LICENSE.txt) under the MIT License.

[chezmoi]: https://www.chezmoi.io
[p10k]: https://github.com/romkatv/powerlevel10k
[sheldon]: https://github.com/rossmacarthur/sheldon
[mise]: https://mise.jdx.dev
[nerdfonts]: https://www.nerdfonts.com
