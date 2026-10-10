# shellenv

zsh / oh-my-zsh, tmux (Oh my tmux!) and vim configuration.

## Install

```sh
git clone --recurse-submodules <url> ~/shellenv
~/shellenv/install.sh     # symlinks the dotfiles into $HOME
```

## Layout

Third-party code is pulled in as git submodules and never edited in place;
all local customizations live in tracked files outside them:

| Upstream (submodule)            | Customize in                                          |
| ------------------------------- | ----------------------------------------------------- |
| `.oh-my-zsh`                    | `.zshrc`, `zsh-custom/` (`$ZSH_CUSTOM`)               |
| `.tmux` (gpakosz/.tmux)         | `.tmux.conf.local` (`.tmux.conf` links into the submodule) |
| `zsh-custom/plugins/*` (3rd party) | `zsh-custom/overrides.zsh`                         |
| `.vim/bundle/*`                 | `.vimrc`                                              |

- `zsh-custom/overrides.zsh` – tweaks to oh-my-zsh plugins (sourced after plugins load)
- `zsh-custom/themes/` – theme wrappers that source the upstream theme, then adjust it
- `zsh-custom/plugins/{nginx,tmux-theme}` – local plugins

## Updating

```sh
git submodule update --remote     # move every submodule to its latest upstream
git diff --submodule              # review
git commit -am "Update submodules"
```

On other machines: `git pull && git submodule update --init --recursive`.

After an Oh my tmux! update, compare `.tmux/.tmux.conf.local` against
`.tmux.conf.local` for newly added options (`git diff --no-index`).
