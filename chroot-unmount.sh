#!/usr/bin/env bash




##
## # Chroot Unmount
##

sudo umount ./debian-rootfs/sys/firmware/efi/efivars
sudo umount ./debian-rootfs/sys
sudo umount ./debian-rootfs/dev/pts
sudo umount ./debian-rootfs/dev/shm
sudo umount ./debian-rootfs/dev

sudo umount ./debian-rootfs/sys/firmware/efi/efivars
sudo umount ./debian-rootfs/sys
sudo umount ./debian-rootfs/dev/pts
sudo umount ./debian-rootfs/dev/shm
sudo umount ./debian-rootfs/dev

sudo umount ./debian-rootfs/run
sudo umount ./debian-rootfs/media
sudo umount ./debian-rootfs/proc
sudo umount ./debian-rootfs/tmp
