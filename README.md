# shellenv

zsh / oh-my-zsh, tmux (Oh my tmux!) and vim configuration.

## Install

```sh
git clone --recurse-submodules <url> ~/.shellenv
~/.shellenv/install.sh
```

`install.sh` only creates these links in `$HOME`; everything else is loaded
straight from the repo. Anything already at one of these paths is renamed to
`<name>.orig.<timestamp>`, never deleted. zsh, vim and tmux find the repo by
resolving these links, so nothing depends on the clone being at `~/.shellenv`.

| `$HOME`             | repo                                     |
| ------------------- | ---------------------------------------- |
| `~/.zshrc`          | `zsh/zshrc`                              |
| `~/.vimrc`          | `.vimrc`                                 |
| `~/.vim`            | `.vim`                                   |
| `~/.tmux.conf`      | `.tmux.conf` (links to `.tmux/.tmux.conf`) |
| `~/.tmux.conf.local`| `.tmux.conf.local`                       |

tmux also loads `~/.config/tmux/tmux.conf` when it exists, on top of
`~/.tmux.conf`, so `install.sh` moves that file aside the same way.

### Moving an existing install

To move a checkout from `~/shellenv` to `~/.shellenv`:

```sh
mv ~/shellenv ~/.shellenv
~/.shellenv/install.sh
```

Links that point into the old location (or that the move left dangling) are
replaced without a backup. Restart running tmux servers and vim sessions.

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
  then applies only the local settings, so new upstream options arrive with updates
- `.vimrc` – Vundle plugins are only registered when their directory exists

## Archive

`./archive.sh` writes `shellenv.tar.gz` (git-ignored) to the repo root: the
entire repo, including submodules, hidden files and `.git`, under a single
top-level directory named after the checkout (`.shellenv/`). To install from it:

```sh
tar -xzf shellenv.tar.gz -C ~
~/.shellenv/install.sh
```

## Updating

```sh
git submodule update --remote     # move every submodule to its latest upstream
git diff --submodule              # review
git commit -am "Update submodules"
```

On other machines: `git pull && git submodule update --init --recursive`.
