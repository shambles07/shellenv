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

# version_ge <have> <need>: dotted version comparison; trailing letters
# (tmux 3.3a) are ignored
version_ge() {
    awk -v a="$1" -v b="$2" 'BEGIN {
        n = split(a, x, "."); m = split(b, y, ".")
        for (i = 1; i <= (n > m ? n : m); i++) {
            if (x[i] + 0 > y[i] + 0) exit 0
            if (x[i] + 0 < y[i] + 0) exit 1
        }
        exit 0
    }'
}

WARNINGS=0
warn() {
    echo "warning: $*" >&2
    WARNINGS=$((WARNINGS + 1))
}

echo "==> updating submodules"
# not `git -C`: git before 1.8.5 (e.g. CentOS 7) doesn't have it
(cd "$SHELLENV" && git submodule update --init --recursive)

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

echo "==> checking versions"
# minimums: oh-my-zsh prefers zsh 5.0.8, Oh my tmux needs tmux 2.6, vim-go
# needs vim 8.2.5072 (.vimrc skips it on older vims)
if command -v zsh >/dev/null 2>&1; then
    v=$(zsh -c 'echo $ZSH_VERSION')
    version_ge "$v" 5.0.8 || warn "zsh $v is older than 5.0.8; some oh-my-zsh plugins may not work"
    case ${SHELL:-} in
        */zsh) ;;
        *) echo "note: your login shell is ${SHELL:-unknown}; to switch: chsh -s $(command -v zsh)" ;;
    esac
else
    warn "zsh is not installed; ~/.zshrc won't be used"
fi
if command -v tmux >/dev/null 2>&1; then
    # e.g. "tmux 3.4", "tmux 3.3a", "tmux next-3.5"; development builds ("tmux master") pass
    v=$(tmux -V | sed -n 's/^[^0-9]*\([0-9][0-9.]*\).*/\1/p')
    if [ -n "$v" ] && ! version_ge "$v" 2.6; then
        warn "tmux $v is older than 2.6, which Oh my tmux requires; ~/.tmux.conf will fail to load"
    fi
fi
if command -v vim >/dev/null 2>&1; then
    # vim-tiny (no +eval) skips the :if line and exits through :cq as well
    if ! vim -N -es -u NONE -i NONE -c 'if has("patch-8.2.5072") | qa! | endif' -c 'cq' </dev/null >/dev/null 2>&1; then
        warn "vim is older than 8.2.5072 or lacks +eval (e.g. vim-tiny); vim-go is disabled"
    fi
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo "==> done, with $WARNINGS warning(s) above; start a new shell (or run: exec zsh)"
else
    echo "==> done; start a new shell (or run: exec zsh)"
fi
