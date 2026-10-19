# shellenv

zsh / oh-my-zsh, tmux (Oh my tmux!) and vim configuration.

## Install

```sh
git clone --recurse-submodules <url> ~/shellenv
~/shellenv/install.sh
```

`install.sh` only creates these links in `$HOME`; everything else is loaded
straight from the repo. Anything already at one of these paths is renamed to
`<name>.orig.<timestamp>`, never deleted.

| `$HOME`             | repo                                     |
| ------------------- | ---------------------------------------- |
| `~/.zshrc`          | `zsh/zshrc`                              |
| `~/.vimrc`          | `.vimrc`                                 |
| `~/.vim`            | `.vim`                                   |
| `~/.tmux.conf`      | `.tmux.conf` (links to `.tmux/.tmux.conf`) |
| `~/.tmux.conf.local`| `.tmux.conf.local`                       |
| `~/.inputrc`        | `.inputrc`                               |

## Layout

Third-party code is pulled in as git submodules and never edited in place;
all local customizations live in tracked files outside them:

| Upstream (submodule)               | Customize in                                |
| ---------------------------------- | ------------------------------------------- |
| `.oh-my-zsh`                       | `zsh/zshrc`, `zsh-custom/` (`$ZSH_CUSTOM`)  |
| `zsh-custom/plugins/*` (3rd party) | `zsh-custom/overrides.zsh`                  |
| `.tmux` (gpakosz/.tmux)            | `.tmux.conf.local`                          |
| `.vim/bundle/*`                    | `.vimrc`                                    |

- `zsh/` – `zshrc`, `zsh_aliases`, `zsh_functions`
- `zsh-custom/overrides.zsh` – tweaks to oh-my-zsh plugins (sourced after plugins load)
- `zsh-custom/completions/` – completions, e.g. `fast-theme <Tab>` lists fast-syntax-highlighting themes
- `zsh-custom/themes/` – theme wrappers that source the upstream theme, then adjust it
- `zsh-custom/plugins/{nginx,tmux-theme}` – local plugins
- `.tmux.conf.local` – loads the upstream template from `.tmux/.tmux.conf.local`,
  then applies only the local settings, so new upstream options arrive with updates.
  tpm plugins (installed on tmux start by Oh my tmux!; `<prefix> I` / `u`):
  - [tmux-autoreload](https://github.com/b0o/tmux-autoreload) – reloads the config on save; needs `entr`
  - [tmux-gentrify](https://github.com/kristopolous/tmux-gentrify) – `<prefix> M-x` cuts a pane, `M-v` pastes it
  - [tmux-notify](https://github.com/rickstaa/tmux-notify) – `<prefix> m` notifies when a pane's command finishes
    (replaces Oh my tmux!'s `<prefix> m` mouse toggle)
- `tmux/tmux-colors` (alias `tmuxtheme`) – picks the Oh my tmux! theme colours from
  a palette with a live preview of the status bar (fzf if installed, otherwise a
  numbered menu), saves them to `tmux/theme.conf` and reloads tmux
- `.vimrc` – Vundle plugins are only registered when their directory exists

## Archive

`./archive.sh` writes `shellenv_YYYYmmdd_HHMMSS.tar.gz` (git-ignored) to the
repo root: the entire repo, including submodules, hidden files and `.git`,
under a single top-level `shellenv/` directory.

If a local `upload.sh` exists (git-ignored, not included in the archive),
`archive.sh` runs it with the new archive's path as its only argument, e.g.:

```sh
#!/bin/sh
set -eu
scp "$1" user@host:/path/
```

## Updating

```sh
git submodule update --remote     # move every submodule to its latest upstream
git diff --submodule              # review
git commit -am "Update submodules"
```

On other machines: `git pull && git submodule update --init --recursive`.
