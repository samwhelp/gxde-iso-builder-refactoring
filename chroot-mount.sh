#!/usr/bin/env bash




##
## # Chroot Mount
##

sudo mount --bind /dev ./debian-rootfs/dev
sudo mount --bind /run  ./debian-rootfs/run
#sudo mount --bind /media  ./debian-rootfs/media
sudo mount -t devpts devpts ./debian-rootfs/dev/pts
sudo mount -t sysfs sysfs ./debian-rootfs/sys
sudo mount -t proc proc ./debian-rootfs/proc
sudo mount -t tmpfs tmpfs  ./debian-rootfs/dev/shm
sudo mount --bind /tmp ./debian-rootfs/tmp
