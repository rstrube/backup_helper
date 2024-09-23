#!/bin/bash

./pre/mount_all_nas_nfs_shares.sh

../helper/rsync/rsync_helper.sh ~/Music ~/TrueNAS/media
../helper/rsync/rsync_helper.sh ~/Pictures ~/Projects ~/TrueNAS/personal/robert

./post/umount_all_nfs_shares.sh