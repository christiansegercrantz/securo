#!/usr/bin/env bash
# One-time setup per device: links mise.local.toml from the fork's
# local-config branch into the securo checkout. Safe to re-run.
#
# Run from anywhere inside the securo repo:
#   git fetch fork local-config
#   bash <(git show fork/local-config:setup-device.sh)
set -Eeuo pipefail

remote="${REMOTE:-fork}"
fork_url="https://github.com/christiansegercrantz/securo.git"
branch="local-config"

repo_root="$(git rev-parse --show-toplevel)"
worktree="$(dirname "$repo_root")/securo-local-config"
cd "$repo_root"

if ! git remote get-url "$remote" >/dev/null 2>&1; then
    echo "==> Adding remote $remote -> $fork_url"
    git remote add "$remote" "$fork_url"
fi

echo "==> Fetching $remote/$branch"
git fetch "$remote" "$branch"

if [[ -d "$worktree" ]]; then
    echo "==> Worktree already exists at $worktree"
elif git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$worktree" "$branch"
else
    git worktree add --track -b "$branch" "$worktree" "$remote/$branch"
fi

if [[ -e mise.local.toml && ! -L mise.local.toml ]]; then
    backup="mise.local.toml.bak.$(date +%Y%m%d%H%M%S)"
    echo "==> Existing mise.local.toml is a regular file, moving it to $backup"
    mv mise.local.toml "$backup"
fi
ln -sfn ../securo-local-config/mise.local.toml mise.local.toml
echo "==> Linked mise.local.toml -> ../securo-local-config/mise.local.toml"

exclude="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude")"
if ! grep -qxF "mise.local.toml" "$exclude" 2>/dev/null; then
    echo "mise.local.toml" >> "$exclude"
    echo "==> Added mise.local.toml to $exclude"
fi

if command -v mise >/dev/null 2>&1; then
    mise trust mise.local.toml
fi

echo "==> Done"
