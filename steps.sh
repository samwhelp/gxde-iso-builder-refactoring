#!/usr/bin/env bash




##
## # Build GXDE ISO / Steps
##


##
## ## Main / Init
##

REF_BASE_DIR_PATH="$(cd -- "$(dirname -- "$0")" ; pwd)"
REF_CMD_FILE_NAME="$(basename "$0")"


##
## ## Main / Util
##

util_error_echo () {
	echo "$@" 1>&2
}


##
## ## Target OS / Util
##

function util_chroot_package_control () {
	if [[ $isUnAptss == 1 ]]; then
		util_chroot_run apt "$@"
	else
		util_chroot_run aptss "$@"
	fi
}

function util_chroot_run () {
	for i in {1..5};
	do
		sudo env DEBIAN_FRONTEND=noninteractive chroot $debianRootfsPath "$@"
		if [[ $? == 0 ]]; then
			break
		fi
		sleep 1
	done
}

function gxde_target_os_unmount () {
	sudo umount "$1/sys/firmware/efi/efivars"
	sudo umount "$1/sys"
	sudo umount "$1/dev/pts"
	sudo umount "$1/dev/shm"
	sudo umount "$1/dev"

	sudo umount "$1/sys/firmware/efi/efivars"
	sudo umount "$1/sys"
	sudo umount "$1/dev/pts"
	sudo umount "$1/dev/shm"
	sudo umount "$1/dev"

	sudo umount "$1/run"
	sudo umount "$1/media"
	sudo umount "$1/proc"
	sudo umount "$1/tmp"
}


##
## ## Main / Util
##

gxde_build_iso_steps () {

	echo "gxde_build_iso_steps"

	return 0
}


##
## ## Main / Args
##

_main_check_args_size_ () {

	local args_size="${1}"

	if [[ ${1} -le 0 ]]; then

		util_error_echo
		util_error_echo "##"
		util_error_echo "## ## Build Arch Required"
		util_error_echo "##"
		util_error_echo

		util_error_echo "> Build Arch Options: i386 amd64 arm64 mips64el loong64"
		util_error_echo
		util_error_echo "> Ex: sudo ${REF_CMD_FILE_NAME} amd64"

		util_error_echo

		exit 1
	fi

}

_main_init_args_ () {

	REF_BUILD_ARCH="${1}"

}




##
## ## Main / Start
##

__main__ () {

	gxde_build_iso_steps "${@}"

}

_main_check_args_size_ "${#}"

_main_init_args_ "${@}"

__main__ "${@}"
