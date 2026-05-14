#!/bin/bash

../helper/rsync/rsync_helper.sh -v -d ~/Music robert@truenas:/mnt/main/media

../helper/rsync/rsync_helper.sh -v -d ~/Documents ~/Projects ~/Games robert@truenas:/mnt/main/personal/robert
