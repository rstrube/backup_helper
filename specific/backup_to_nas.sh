#!/bin/bash

../helper/rsync/rsync_helper.sh -v -d ~/Music robert@192.168.1.200:/mnt/main/media

../helper/rsync/rsync_helper.sh -v -d ~/Documents robert@192.168.1.200:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d ~/Projects robert@192.168.1.200:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d ~/Games robert@192.168.1.200:/mnt/main/personal/robert
