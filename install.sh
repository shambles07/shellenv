#!/bin/sh
# Link the shellenv dotfiles into $HOME.
#
# Only these entry points are linked; everything else is loaded from the repo:
#   ~/.zshrc            -> zsh/zshrc
#   ~/.vimrc            -> .vimrc
#   ~/.vim              -> .vim
#   ~/.tmux.conf        -> .tmux.conf (-> .tmux/.tmux.conf)
#   ~/.tmux.conf.local  -> .tmux.conf.local
#   ~/.inputrc          -> .inputrc
#
# Anything already at one of those paths (that isn't already our link) is
# renamed to <name>.orig.<timestamp>, never deleted.
set -eu

SHELLENV=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d_%H%M%S)

echo "==> updating submodules"
git -C "$SHELLENV" submodule update --init --recursive

echo "==> linking dotfiles into $HOME"
for pair in \
    zsh/zshrc:.zshrc \
    .vimrc:.vimrc \
    .vim:.vim \
    .tmux.conf:.tmux.conf \
    .tmux.conf.local:.tmux.conf.local \
    .inputrc:.inputrc
do
    src=$SHELLENV/${pair%%:*}
    target=$HOME/${pair#*:}
    if [ "$(readlink "$target" 2>/dev/null)" = "$src" ]; then
        echo "already linked: $target -> $src"
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        mv -v "$target" "$target.orig.$STAMP"
    fi
    ln -sv "$src" "$target"
done

echo "==> done; start a new shell (or run: exec zsh)"
