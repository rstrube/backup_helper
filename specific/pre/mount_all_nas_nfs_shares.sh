#!/bin/bash

../helper/nas/mount_nfs_shares.sh 192.168.1.200 /mnt/main/media/Movies /mnt/main/media/Music /mnt/main/media/Shows ~/TrueNAS/media
../helper/nas/mount_nfs_shares.sh 192.168.1.200 /mnt/main/personal/robert/Pictures ~/TrueNAS/personal/robert

