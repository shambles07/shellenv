#!/usr/bin/env bash
# Smoke test: install into a throwaway $HOME, then start zsh, vim and tmux
# against it and check that each loads the config cleanly. Tools that aren't
# installed are skipped. Run from anywhere: tests/smoke.sh
# shellcheck disable=SC2088  # "~/..." in check descriptions is display text
set -u

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
T=$(mktemp -d)
T=$(cd "$T" && pwd -P)
H=$T/home
SOCK=shellenv-smoke-$$
FAILED=0

pass() { echo "  ok: $*"; }
fail() { echo "  FAIL: $*"; FAILED=$((FAILED + 1)); }
check() {  # check <description> <command...>
    local desc=$1; shift
    if "$@"; then pass "$desc"; else fail "$desc"; fi
}
section() { echo; echo "== $*"; }

cleanup() {
    env HOME="$H" tmux -L "$SOCK" kill-server 2>/dev/null
    # shells in the killed tmux server may still be writing to $H on exit
    for _ in 1 2 3 4 5; do
        rm -rf "${T:?}" 2>/dev/null && return
        sleep 0.5
    done
    rm -rf "${T:?}"
}
trap cleanup EXIT

# keep everything inside the throwaway home
mkdir -p "$H"
export HOME=$H XDG_CONFIG_HOME=$H/.config XDG_CACHE_HOME=$H/.cache XDG_STATE_HOME=$H/.local/state
export TERM=xterm-256color LANG=${LANG:-C.UTF-8}
unset TMUX TMUX_PANE ZDOTDIR

count_backups() { find "$H" -name '*.orig.*' | wc -l | tr -d ' '; }

section "install"
# existing user files must be backed up; links from an old checkout and
# dangling links must be replaced without a backup
echo '" user vimrc' > "$H/.vimrc"
mkdir -p "$H/.config/tmux" "$T/old/zsh"
echo 'set -g @user_xdg_conf 1' > "$H/.config/tmux/tmux.conf"
touch "$T/old/zsh/zshrc"
ln -s "$T/old/zsh/zshrc" "$H/.zshrc"
ln -s "$T/gone/.vim" "$H/.vim"

if sh "$REPO/install.sh" > "$T/install.log" 2>&1; then
    pass "install.sh exits 0"
else
    fail "install.sh exits 0"; cat "$T/install.log"
fi
for pair in zsh/zshrc:.zshrc .vimrc:.vimrc .vim:.vim .tmux.conf:.tmux.conf .tmux.conf.local:.tmux.conf.local; do
    check "~/${pair#*:} -> ${pair%%:*}" test "$(readlink "$H/${pair#*:}")" = "$REPO/${pair%%:*}"
done
check "existing ~/.vimrc backed up" grep -q 'user vimrc' "$H"/.vimrc.orig.*
check "~/.config/tmux/tmux.conf moved aside" test ! -e "$H/.config/tmux/tmux.conf"
check "old-checkout and dangling links replaced without backup" test "$(count_backups)" -eq 2

sh "$REPO/install.sh" > "$T/install2.log" 2>&1
check "re-running install.sh changes nothing" test "$(grep -c 'already linked' "$T/install2.log")" -eq 5 -a "$(count_backups)" -eq 2

section "version checks"
mkdir -p "$T/oldbin"
printf '#!/bin/sh\necho "tmux 1.8"\n' > "$T/oldbin/tmux"
printf '#!/bin/sh\necho 5.0.2\n' > "$T/oldbin/zsh"
printf '#!/bin/sh\nexit 1\n' > "$T/oldbin/vim"
chmod +x "$T/oldbin"/*
PATH=$T/oldbin:$PATH sh "$REPO/install.sh" > "$T/install-old.log" 2>&1
check "warns about old zsh" grep -q 'zsh 5.0.2 is older' "$T/install-old.log"
check "warns about old tmux" grep -q 'tmux 1.8 is older' "$T/install-old.log"
check "warns about old vim" grep -q 'vim is older' "$T/install-old.log"

section "zsh"
if command -v zsh >/dev/null 2>&1; then
    # the first start may generate completions; later starts must be silent
    zsh -i -c exit > "$T/zsh1.out" 2>&1 || { fail "first zsh start"; cat "$T/zsh1.out"; }
    zsh -i -c 'print -r -- "$SHELLENV"; print -r -- $+functions[omz] $+functions[mycnf] $+aliases[valias]' \
        > "$T/zsh.out" 2> "$T/zsh.err"
    check "zsh starts" test $? -eq 0
    check "zsh finds the repo (SHELLENV)" test "$(sed -n 1p "$T/zsh.out")" = "$REPO"
    check "oh-my-zsh and shellenv functions load" test "$(sed -n 2p "$T/zsh.out")" = "1 1 1"
    check "zsh starts without errors" test ! -s "$T/zsh.err"
    [ -s "$T/zsh.err" ] && sed 's/^/    /' "$T/zsh.err"
else
    echo "  skipped: zsh not installed"
fi

section "vim"
if command -v vim >/dev/null 2>&1 && vim -N -es -u NONE -i NONE -c 'if has("eval") | qa! | endif' -c cq </dev/null >/dev/null 2>&1; then
    cat > "$T/check.vim" <<'EOF'
let s:out = []
call add(s:out, 'errmsg=' . v:errmsg)
call add(s:out, 'colors=' . get(g:, 'colors_name', ''))
call add(s:out, 'enter=' . maparg('<CR>', 'n'))
call add(s:out, 'leader_n=' . maparg('<leader>n', 'n'))
call add(s:out, 'fugitive=' . (exists(':Git') == 2))
call add(s:out, 'vimgo=' . (&rtp =~# 'bundle/vim-go'))
call add(s:out, 'vimgo_supported=' . has('patch-8.2.5072'))
call add(s:out, 'undodir=' . &undodir)
call writefile(s:out, $SMOKE_OUT)
qa!
EOF
    SMOKE_OUT=$T/vim.out vim -N -i NONE -u "$H/.vimrc" -es -S "$T/check.vim" </dev/null >/dev/null 2>&1
    v() { sed -n "s/^$1=//p" "$T/vim.out"; }
    check "vim starts without errors" test -f "$T/vim.out" -a -z "$(v errmsg)"
    [ -n "$(v errmsg)" ] && echo "    $(v errmsg)"
    check "colorscheme loads" test "$(v colors)" = medic_chalk
    check "fugitive loads" test "$(v fugitive)" = 1
    check "vim-go loaded only where supported" test "$(v vimgo)" = "$(v vimgo_supported)"
    check "Enter isn't remapped" test -z "$(v enter)"
    check "<leader>n toggles line numbers" test "$(v leader_n)" = ':set nu!<CR>'
    check "undo files go to XDG state" test "$(v undodir)" = "$XDG_STATE_HOME/vim/undo" -a -d "$XDG_STATE_HOME/vim/undo"
else
    echo "  skipped: vim not installed or without +eval"
fi

section "tmux"
# start_tmux <label> [PATH]: start a server and wait for both config passes
start_tmux() {
    env HOME="$H" tmux -L "$SOCK" kill-server 2>/dev/null
    # start outside the repo, so relative paths can't resolve by accident
    (cd "$H" && env HOME="$H" PATH="${2:-$PATH}" tmux -L "$SOCK" new-session -d -s smoke) || { fail "$1: tmux starts"; return 1; }
    for _ in $(seq 1 50); do
        # not `list-keys -T prefix X`: tmux 3.7 prints nothing for a single key
        if tmux -L "$SOCK" list-keys -T prefix 2>/dev/null | grep -Eq ' X +kill-pane$' &&
            [ -z "$(tmux -L "$SOCK" show -gqv @shellenv_pass2)" ]; then
            pass "$1: upstream template and local settings load"
            return 0
        fi
        sleep 0.2
    done
    fail "$1: upstream template and local settings load (@shellenv_pass2=$(tmux -L "$SOCK" show -gqv @shellenv_pass2))"
    return 1
}
tmux_v=$(tmux -V 2>/dev/null | sed -n 's/^[^0-9]*\([0-9][0-9.]*\).*/\1/p')
if [ -z "$tmux_v" ]; then
    echo "  skipped: tmux not installed"
elif ! awk -v v="$tmux_v" 'BEGIN { split(v, x, "."); exit !(x[1] > 2 || (x[1] == 2 && x[2] >= 6)) }'; then
    echo "  skipped: tmux $tmux_v is older than 2.6"
else
    if start_tmux "tmux $tmux_v"; then
        check "C-a prefix removed" test "$(tmux -L "$SOCK" show -gv prefix2)" = None
        check "~/.config/tmux/tmux.conf not loaded" test -z "$(tmux -L "$SOCK" show -gqv @user_xdg_conf)"
        if command -v zsh >/dev/null 2>&1; then
            check "default shell is zsh" test "$(basename "$(tmux -L "$SOCK" show -gv default-shell)")" = zsh
        fi
    fi
    # macOS before 12.3 has no `readlink -f`
    mkdir -p "$T/noreadlinkf"
    # shellcheck disable=SC2016  # $1 and $@ belong to the generated script
    printf '#!/bin/sh\n[ "$1" = -f ] && exit 1\nexec %s "$@"\n' "$(command -v readlink)" > "$T/noreadlinkf/readlink"
    chmod +x "$T/noreadlinkf/readlink"
    start_tmux "without readlink -f" "$T/noreadlinkf:$PATH"
fi

section "archive"
name=$(basename "$REPO")
if "$REPO/archive.sh" > /dev/null 2>&1 && [ -f "$REPO/shellenv.tar.gz" ]; then
    check "archive has a single top-level $name/" test "$(tar -tzf "$REPO/shellenv.tar.gz" | cut -d/ -f1 | sort -u)" = "$name"
    rm -f "$REPO/shellenv.tar.gz"
else
    fail "archive.sh creates shellenv.tar.gz"
fi

echo
if [ "$FAILED" -gt 0 ]; then
    echo "$FAILED check(s) failed"
    exit 1
fi
echo "all checks passed"
