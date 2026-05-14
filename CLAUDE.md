# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A collection of Bash scripts for backing up local directories to various destinations: an external HDD (Iron Wolf), an external SSD, and a TrueNAS server (via SSH or NFSv4 mount). There are no build steps, tests, or package managers — scripts are run directly.

## Architecture

The repo has two layers:

**`helper/`** — Reusable building blocks:
- `helper/rsync/rsync_helper.sh` — Core wrapper around `rsync`. Takes one or more source paths and a destination root as positional args. Accepts flags (`-d` delete at dest, `-n` NFS mode, `-v` verbose, `-l` log to file, `-h` help). Supports both local destinations and remote destinations in `[user@]host:/path` format (SSH). When `-d` is set, it first does a dry-run showing files that would be deleted and prompts for confirmation before proceeding.
- `helper/nas/mount_nfs_shares.sh` — Mounts one or more NFSv4 shares from a NAS. Args: `{NAS IP} [{nfs path} ...] {local mount root}`. Auto-creates mount point directories.
- `helper/nas/umount_nfs_shares.sh` — Unmounts local mount points. Args: `[{mount point} ...]`.

**`specific/`** — Concrete backup jobs that call into `helper/` via relative paths (`../helper/...`). Must be run from within the `specific/` directory.
- `backup_to_iron_wolf.sh` — Backs up multiple home directories to `/run/media/robert/Iron_Wolf` (physical HDD).
- `backup_to_ssd_ext.sh` — Backs up multiple home directories to `/run/media/robert/SSD_Ext`.
- `backup_to_nas.sh` — Backs up Music, Documents, Projects, Games to TrueNAS via SSH (`robert@truenas`).
- `backup_retrodeck_from_steamdeck.sh` — Pulls `retrodeck` from a Steam Deck over SSH (`deck@steamdeck`) into local `~/Games`.
- `pre/mount_all_nas_nfs_shares.sh` — Mounts NAS NFS shares to `~/TrueNAS/media` (run before NFS-based backups).
- `post/unmount_all_nas_nfs_shares.sh` — Unmounts those shares (run after).

## Key behaviors in `rsync_helper.sh`

- Source paths are all positional args **except the last**, which is always the destination root.
- Each source `~/Foo` maps to destination `{dest_root}/Foo` (basename only). rsync creates subdirectories at the destination automatically — only the destination root must pre-exist.
- Remote paths (matching `[user@]host:/path`) are auto-detected and checked via SSH (`ssh host "[ -d path ]"`); local paths via `-d` test. No flag is needed to use SSH.
- NFS mode (`-n`) adds `--omit-dir-times` to avoid permission errors on NFSv4 mounts.
- Logging (`-l`) writes to `backup.log` at the destination root; the file is deleted and recreated on each run. Logging is automatically disabled (with a warning) when the destination is remote.
- If any rsync call fails, the error is reported immediately and the script exits 1 after all sources have been attempted.

## Running scripts

All `specific/` scripts must be executed from within the `specific/` directory (they use `../helper/` relative paths):

```bash
cd specific
bash backup_to_nas.sh
```

Helper scripts can be called directly with explicit args:

```bash
# rsync one or more sources to a destination
bash helper/rsync/rsync_helper.sh -d -v ~/Documents ~/Pictures /run/media/robert/Iron_Wolf

# mount NFS shares
bash helper/nas/mount_nfs_shares.sh 192.168.1.200 /mnt/main/media/Movies ~/TrueNAS/media

# unmount
bash helper/nas/umount_nfs_shares.sh ~/TrueNAS/media/Movies/
```
