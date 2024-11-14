#!/usr/bin/env bash




##
## # Chroot Unmount
##


DEFAULT_TARGET_OS_ROOT_DIR_PATH="/opt/tmp/gxde/work/rootfs"
REF_TARGET_OS_ROOT_DIR_PATH="${1}"

if [[ -z "${REF_TARGET_OS_ROOT_DIR_PATH}" ]]; then
	REF_TARGET_OS_ROOT_DIR_PATH="${DEFAULT_TARGET_OS_ROOT_DIR_PATH}"
fi


function gxde_target_os_unmount_for_chroot () {

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_target_os_unmount_for_chroot "${rootfs}"

}

function util_target_os_unmount_for_chroot () {

	local rootfs="${1}"

	#sudo umount "${rootfs}/sys/firmware/efi/efivars"
	sudo umount "${rootfs}/sys"
	sudo umount "${rootfs}/dev/pts"
	sudo umount "${rootfs}/dev/shm"
	sudo umount "${rootfs}/dev"

	sudo umount "${rootfs}/run"
	#sudo umount "${rootfs}/media"
	sudo umount "${rootfs}/proc"
	sudo umount "${rootfs}/tmp"

	return 0
}

gxde_target_os_unmount_for_chroot
