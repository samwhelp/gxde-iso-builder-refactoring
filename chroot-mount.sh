#!/usr/bin/env bash




##
## # Chroot Mount
##


DEFAULT_TARGET_OS_ROOT_DIR_PATH="/opt/tmp/gxde/work/rootfs"
REF_TARGET_OS_ROOT_DIR_PATH="${1}"

if [[ -z "${REF_TARGET_OS_ROOT_DIR_PATH}" ]]; then
	REF_TARGET_OS_ROOT_DIR_PATH="${DEFAULT_TARGET_OS_ROOT_DIR_PATH}"
fi


sudo mount --bind /dev "${REF_TARGET_OS_ROOT_DIR_PATH}/dev"
sudo mount --bind /run  "${REF_TARGET_OS_ROOT_DIR_PATH}/run"
#sudo mount --bind /media  "${REF_TARGET_OS_ROOT_DIR_PATH}/media"
sudo mount -t devpts devpts "${REF_TARGET_OS_ROOT_DIR_PATH}/dev/pts"
sudo mount -t sysfs sysfs "${REF_TARGET_OS_ROOT_DIR_PATH}/sys"
sudo mount -t proc proc "${REF_TARGET_OS_ROOT_DIR_PATH}/proc"
sudo mount -t tmpfs tmpfs  "${REF_TARGET_OS_ROOT_DIR_PATH}/dev/shm"
sudo mount --bind /tmp "${REF_TARGET_OS_ROOT_DIR_PATH}/tmp"
