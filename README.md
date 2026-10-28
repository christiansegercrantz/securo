# local-config

Personal, per-device config for my securo fork. This is an orphan branch with
no shared history with upstream, so it can't be merged or PR'd into
`securo-finance/securo`.

## New device setup (once per device)

From inside the securo checkout:

```bash
git fetch fork local-config          # add the remote first if missing:
                                     # git remote add fork https://github.com/christiansegercrantz/securo.git
bash <(git show fork/local-config:setup-device.sh)
```

That creates the `../securo-local-config` worktree, symlinks
`securo/mise.local.toml` to the file in the worktree, adds it to
`.git/info/exclude` and runs `mise trust`.

After that, the same setup is also available as `mise run local-config:setup`.

## Day to day

- Edit `securo/mise.local.toml` as usual (it's a symlink).
- `mise run local-config:save` commits and pushes changes.
- `mise run local-config:pull` pulls changes made on other devices.
