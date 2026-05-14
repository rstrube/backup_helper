#!/bin/bash

../helper/rsync/rsync_helper.sh -v -d ~/Music robert@truenas:/mnt/main/media

../helper/rsync/rsync_helper.sh -v -d ~/Documents robert@truenas:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d ~/Projects robert@truenas:/mnt/main/personal/robert

../helper/rsync/rsync_helper.sh -v -d ~/Games robert@truenas:/mnt/main/personal/robert
