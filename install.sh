#!/bin/sh
# Link the shellenv dotfiles into $HOME.
#
# Only these entry points are linked; everything else is loaded from the repo:
#   ~/.zshrc            -> zsh/zshrc
#   ~/.vimrc            -> .vimrc
#   ~/.vim              -> .vim
#   ~/.tmux.conf        -> .tmux.conf (-> .tmux/.tmux.conf)
#   ~/.tmux.conf.local  -> .tmux.conf.local
#
# Anything already at one of those paths (that isn't already our link) is
# renamed to <name>.orig.<timestamp>, never deleted. Links left by a previous
# checkout of this repo (e.g. ~/shellenv before moving to ~/.shellenv) are
# simply replaced.
set -eu

SHELLENV=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d_%H%M%S)

backup() {
    mv -v "$1" "$1.orig.$STAMP"
}

echo "==> updating submodules"
git -C "$SHELLENV" submodule update --init --recursive

echo "==> linking dotfiles into $HOME"
for pair in \
    zsh/zshrc:.zshrc \
    .vimrc:.vimrc \
    .vim:.vim \
    .tmux.conf:.tmux.conf \
    .tmux.conf.local:.tmux.conf.local
do
    rel=${pair%%:*}
    src=$SHELLENV/$rel
    target=$HOME/${pair#*:}
    old=$(readlink "$target" 2>/dev/null) || old=
    if [ "$old" = "$src" ]; then
        echo "already linked: $target -> $src"
        continue
    fi
    if [ -L "$target" ] && { [ ! -e "$target" ] || [ -f "${old%/"$rel"}/zsh/zshrc" ]; }; then
        # dangling, or a link into another shellenv checkout
        rm -v "$target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        backup "$target"
    fi
    ln -sv "$src" "$target"
done

# tmux loads every user config it finds, so one in ~/.config/tmux would be
# applied on top of ~/.tmux.conf
for conf in "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"; do
    if [ -e "$conf" ] || [ -L "$conf" ]; then
        echo "==> moving aside $conf (tmux would load it after ~/.tmux.conf)"
        backup "$conf"
    fi
done

echo "==> done; start a new shell (or run: exec zsh)"
