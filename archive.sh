#!/bin/sh
# Archive the whole repo (submodules, hidden files and .git included) into
# shellenv.tar.gz at the repo root. The archive unpacks into a single
# top-level directory named after the repo.
set -eu

SHELLENV=$(cd "$(dirname "$0")" && pwd)
name=$(basename "$SHELLENV")
out=$SHELLENV/shellenv.tar.gz

# write to a temp file first so a failed run never leaves a truncated archive
tmp=$out.tmp
trap 'rm -f "$tmp"' EXIT

tar -czf "$tmp" \
    --exclude="$name/shellenv.tar.gz" \
    --exclude="$name/shellenv.tar.gz.tmp" \
    -C "$(dirname "$SHELLENV")" "$name"
mv -f "$tmp" "$out"

echo "created $out ($(du -h "$out" | cut -f1))"
