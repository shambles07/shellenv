#!/bin/sh
# Link the shellenv dotfiles into $HOME.
# Existing files (not already pointing here) are moved aside to <name>.pre-shellenv.
set -eu

SHELLENV=$(cd "$(dirname "$0")" && pwd)

git -C "$SHELLENV" submodule update --init --recursive

for f in .zshrc .zsh_aliases .zsh_functions .vimrc .vim .tmux.conf .tmux.conf.local; do
    target=$HOME/$f
    if [ "$(readlink "$target" 2>/dev/null)" = "$SHELLENV/$f" ]; then
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        mv "$target" "$target.pre-shellenv"
        echo "moved $target -> $target.pre-shellenv"
    fi
    ln -s "$SHELLENV/$f" "$target"
    echo "linked $target -> $SHELLENV/$f"
done
