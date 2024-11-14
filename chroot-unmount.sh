#!/usr/bin/env bash




##
## # Chroot Unmount
##


DEFAULT_TARGET_OS_ROOT_DIR_PATH="/opt/tmp/gxde/work/rootfs"
REF_TARGET_OS_ROOT_DIR_PATH="${1}"

if [[ -z "${REF_TARGET_OS_ROOT_DIR_PATH}" ]]; then
	REF_TARGET_OS_ROOT_DIR_PATH="${DEFAULT_TARGET_OS_ROOT_DIR_PATH}"
fi


sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/sys/firmware/efi/efivars"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/sys"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/dev/pts"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/dev/shm"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/dev"

sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/run"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/media"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/proc"
sudo umount "${REF_TARGET_OS_ROOT_DIR_PATH}/tmp"
