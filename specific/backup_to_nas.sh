#!/bin/bash

../helper/rsync/rsync_helper.sh -v -d -s ~/Music robert@192.168.1.200:/mnt/main/media

../helper/rsync/rsync_helper.sh -v -d -s ~/Documents robert@192.168.1.200:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d -s ~/Projects robert@192.168.1.200:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d -s ~/Games robert@192.168.1.200:/mnt/main/personal/robert
