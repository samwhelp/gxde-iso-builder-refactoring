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
## ## Plan / Path
##

REF_MAIN_SUBJECT_NAME="gxde"
REF_PLAN_DIR_PATH="${REF_BASE_DIR_PATH}"



REF_PLAN_ASSET_DIR_NAME="asset"
REF_PLAN_ASSET_DIR_PATH="${REF_PLAN_DIR_PATH}/${REF_PLAN_ASSET_DIR_NAME}"


REF_PLAN_FACTORY_DIR_NAME="factory"
REF_PLAN_FACTORY_DIR_PATH="${REF_PLAN_DIR_PATH}/${REF_PLAN_FACTORY_DIR_NAME}"


REF_PLAN_TMP_DIR_NAME="tmp"
REF_PLAN_TMP_DIR_PATH="${REF_PLAN_DIR_PATH}/${REF_PLAN_TMP_DIR_NAME}"

#REF_PLAN_TMP_DIR_PATH="${HOME}/${REF_PLAN_TMP_DIR_NAME}/${REF_MAIN_SUBJECT_NAME}"
REF_PLAN_TMP_DIR_PATH="/opt/${REF_PLAN_TMP_DIR_NAME}/${REF_MAIN_SUBJECT_NAME}"


REF_PLAN_WORK_DIR_NAME="work"
REF_PLAN_WORK_DIR_PATH="${REF_PLAN_TMP_DIR_PATH}/${REF_PLAN_WORK_DIR_NAME}"

REF_PLAN_OUT_DIR_NAME="out"
REF_PLAN_OUT_DIR_PATH="${REF_PLAN_TMP_DIR_PATH}/${REF_PLAN_OUT_DIR_NAME}"


##
## ## Main / Args
##

DEFAULT_IS_USE_APTSS="false"
REF_IS_USE_APTSS="${REF_IS_USE_APTSS:=$DEFAULT_IS_USE_APTSS}"


DEFAULT_BUILD_ARCH="amd64"
REF_BUILD_ARCH="${REF_BUILD_ARCH:=$DEFAULT_BUILD_ARCH}"


##
## ## Main / Util
##

util_error_echo () {
	echo "$@" 1>&2
}


##
## ## Target OS / Path
##

REF_TARGET_OS_ROOT_DIR_NAME="rootfs"
REF_TARGET_OS_ROOT_DIR_PATH="${REF_PLAN_WORK_DIR_PATH}/${REF_TARGET_OS_ROOT_DIR_NAME}"


REF_TARGET_OS_ARCHIVE_FILE_NAME="filesystem.squashfs"
REF_TARGET_OS_ARCHIVE_FILE_PATH="${REF_PLAN_WORK_DIR_PATH}/${REF_TARGET_OS_ARCHIVE_FILE_NAME}"


##
## ## Target OS / debootstrap args
##

#DEFAULT_BUILD_ARCH="amd64"
#REF_BUILD_ARCH="${REF_BUILD_ARCH:=$DEFAULT_BUILD_ARCH}"

DEFAULT_BUILD_SUITE="bookworm"
REF_BUILD_SUITE="${REF_BUILD_SUITE:=$DEFAULT_BUILD_SUITE}"

DEFAULT_PACKAGE_REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/debian/"
REF_PACKAGE_REPO_URL="${REF_PACKAGE_REPO_URL:=$DEFAULT_PACKAGE_REPO_URL}"

DEFAULT_BUILD_INCLUDE="debian-ports-archive-keyring,debian-archive-keyring,live-task-recommended,live-task-standard,live-config-systemd,live-boot"
REF_BUILD_INCLUDE="${REF_BUILD_INCLUDE:=$DEFAULT_BUILD_INCLUDE}"


## for --arch=loong64
DEFAULT_BUILD_KEYRING_FOR_LOONG64="/usr/share/keyrings/debian-ports-archive-keyring.gpg"
REF_BUILD_KEYRING_FOR_LOONG64="${REF_BUILD_KEYRING_FOR_LOONG64:=$DEFAULT_BUILD_KEYRING_FOR_LOONG64}"

DEFAULT_PACKAGE_REPO_URL_FOR_LOONG64="https://mirror.sjtu.edu.cn/debian-ports/"
REF_PACKAGE_REPO_URL_FOR_LOONG64="${REF_PACKAGE_REPO_URL_FOR_LOONG64:=$DEFAULT_PACKAGE_REPO_URL_FOR_LOONG64}"


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

function gxde_target_os_mount_for_chroot () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## Mount For Chroot"
	util_error_echo "##"
	util_error_echo

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_target_os_mount_for_chroot "${rootfs}"

}

function util_target_os_mount_for_chroot () {

	local rootfs="${1}"

	mount --bind /dev "${rootfs}/dev"
	mount --bind /run  "${rootfs}/run"
	#mount --bind /media  "${rootfs}/media"
	mount -t devpts devpts "${rootfs}/dev/pts"
	mount -t sysfs sysfs "${rootfs}/sys"
	mount -t proc proc "${rootfs}/proc"
	mount -t tmpfs tmpfs  "${rootfs}/dev/shm"
	mount --bind /tmp "${rootfs}/tmp"

	return 0
}

function gxde_target_os_unmount_for_chroot () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## Unmount For Chroot"
	util_error_echo "##"
	util_error_echo

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_target_os_unmount_for_chroot "${rootfs}"

}

function util_target_os_unmount_for_chroot () {

	local rootfs="${1}"

	#umount "${rootfs}/sys/firmware/efi/efivars"
	umount "${rootfs}/sys"
	umount "${rootfs}/dev/pts"
	umount "${rootfs}/dev/shm"
	umount "${rootfs}/dev"

	umount "${rootfs}/run"
	#umount "${rootfs}/media"
	umount "${rootfs}/proc"
	umount "${rootfs}/tmp"

	return 0
}


##
## ## GXDE / Build ISO / Package Required For Build
##

gxde_build_iso_package_required () {

	#return 0

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## Check Package Required"
	util_error_echo "##"
	util_error_echo


	util_error_echo
	util_error_echo "apt-get install debootstrap debian-archive-keyring debian-ports-archive-keyring qemu-user-static genisoimage squashfs-tools -y"
	util_error_echo
	apt-get install debootstrap debian-archive-keyring debian-ports-archive-keyring qemu-user-static genisoimage squashfs-tools -y

	util_error_echo



}


##
## ## GXDE / Build ISO / Steps
##

gxde_build_iso_develop_test () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## gxde_build_iso_develop_test"
	util_error_echo "##"
	util_error_echo


	#gxde_build_iso_package_required


	#gxde_build_os_dir_prepare
	#gxde_build_os_bootstrap
	gxde_target_os_mount_for_chroot


	gxde_build_os_clean
	sleep 5
	gxde_target_os_unmount_for_chroot
	sleep 5


	gxde_build_os_archive


	return 0
}

gxde_build_iso_steps () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## gxde_build_iso_steps"
	util_error_echo "##"
	util_error_echo


	gxde_build_iso_package_required


	gxde_build_os_dir_prepare
	gxde_build_os_bootstrap
	gxde_target_os_mount_for_chroot


	gxde_build_os_clean
	sleep 5
	gxde_target_os_unmount_for_chroot
	sleep 5


	gxde_build_os_archive


	return 0
}


##
## ## GXDE / Build Target OS / Prepare
##

gxde_build_os_dir_prepare () {

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	if [[ -d "${rootfs}" ]]; then

		gxde_target_os_unmount "${rootfs}"

		util_error_echo
		util_error_echo rm -rf "${rootfs}"
		rm -rf "${rootfs}"

	fi

	mkdir -p "${rootfs}"

}


##
## ## GXDE / Build Target OS / Bootstrap
##

gxde_build_os_bootstrap () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Bootstrap"
	util_error_echo "##"
	util_error_echo

	local build_arch="${REF_BUILD_ARCH}"
	local build_suite="${REF_BUILD_SUITE}"
	local build_include="${REF_BUILD_INCLUDE}"
	local package_repo_url="${REF_PACKAGE_REPO_URL}"

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	local build_keyring_for_loong64="${REF_BUILD_KEYRING_FOR_LOONG64}"
	local package_repo_url_for_loong64="${REF_PACKAGE_REPO_URL_FOR_LOONG64}"


	if [[ "${build_arch}" == "loong64" ]]; then

		build_suite="unstable"

		util_error_echo
		util_error_echo debootstrap --no-check-gpg --keyring="${build_keyring_for_loong64}" --include="${build_include}" --arch="${build_arch}" "${build_suite}" "${rootfs}" "${package_repo_url_for_loong64}"
		util_error_echo
		debootstrap --no-check-gpg --keyring="${build_keyring_for_loong64}" --include="${build_include}" --arch="${build_arch}" "${build_suite}" "${rootfs}" "${package_repo_url_for_loong64}"

	else

		util_error_echo
		util_error_echo debootstrap --arch="${build_arch}" "${build_suite}" "${rootfs}" "${package_repo_url}"
		util_error_echo
		debootstrap --arch="${build_arch}" "${build_suite}" "${rootfs}" "${package_repo_url}"

	fi

}


##
## ## GXDE / Build Target OS / Clean
##

gxde_build_os_clean () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Clean"
	util_error_echo "##"
	util_error_echo

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_error_echo
	util_error_echo rm -rf "${rootfs}/var/log"/*
	rm -rf "${rootfs}/var/log"/*


	util_error_echo
	util_error_echo rm -rf "${rootfs}/root/.bash_history"
	util_error_echo
	rm -rf "${rootfs}/root/.bash_history"


	util_error_echo
	util_error_echo rm -rf "${rootfs}/initrd.img.old"
	util_error_echo
	rm -rf "${rootfs}/initrd.img.old"


	util_error_echo
	util_error_echo rm -rf "${rootfs}/vmlinuz.old"
	util_error_echo
	rm -rf "${rootfs}/vmlinuz.old"


	return 0
}


##
## ## GXDE / Build Target OS / Archive
##

gxde_build_os_archive () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Archive"
	util_error_echo "##"
	util_error_echo

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"
	local os_archive_file_path="${REF_TARGET_OS_ARCHIVE_FILE_PATH}"

	util_error_echo
	util_error_echo cd "${rootfs}"
	cd "${rootfs}"

	util_error_echo
	util_error_echo rm -rf "${os_archive_file_path}"
	rm -rf "${os_archive_file_path}"

	util_error_echo
	util_error_echo mksquashfs * "${os_archive_file_path}"
	mksquashfs * "${os_archive_file_path}"


	util_error_echo
	util_error_echo cd "${OLDPWD}"
	cd "${OLDPWD}"

}


##
## ## GXDE / Build ISO / Start
##

gxde_build_iso_start () {

	main_signal_bind


	limit_root_user_required

	#gxde_build_iso_steps

	gxde_build_iso_develop_test

	return 0
}


##
## ## Limit / Root User Required
##

limit_root_user_required () {

	if [[ "${EUID}" == 0 ]]; then

		return 0

	else

		util_error_echo
		util_error_echo "##"
		util_error_echo "## ## Root User Required"
		util_error_echo "##"

		util_error_echo
		util_error_echo "> Please Run As Root"
		util_error_echo
		util_error_echo "Example: sudo ./${REF_CMD_FILE_NAME} amd64"
		util_error_echo

		#sleep 2
		exit 0
	fi

}


##
## ## Main / Signal
##

exit_on_signal_interrupted () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## **Script Interrupted**"
	util_error_echo "##"
	util_error_echo

	## TODO:

	sleep 2

	exit 0

}

exit_on_signal_terminated () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## **Script Terminated**"
	util_error_echo "##"
	util_error_echo

	## TODO:

	sleep 2

	exit 0

}

main_signal_bind () {

	trap exit_on_signal_interrupted SIGINT
	trap exit_on_signal_terminated SIGTERM

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
		util_error_echo "SYNOPSIS : sudo ./${REF_CMD_FILE_NAME} [build_arch] [aptss]"
		util_error_echo
		util_error_echo "Example  : sudo ./${REF_CMD_FILE_NAME} amd64"
		util_error_echo
		util_error_echo "Example  : sudo ./${REF_CMD_FILE_NAME} amd64 aptss"
		util_error_echo
		util_error_echo "Example  : sudo ./${REF_CMD_FILE_NAME} unstable aptss"


		util_error_echo

		exit 1
	fi

}

_main_init_args_ () {

	##
	## Example: `sudo ./steps.sh amd64 aptss`
	##

	REF_BUILD_ARCH="${1}"

	if [[ -z "${REF_BUILD_ARCH}" ]]; then
		REF_BUILD_ARCH="${DEFAULT_BUILD_ARCH}"
	fi

	#util_error_echo ${REF_BUILD_ARCH}


	if [[ "${1}" == "aptss" ]] || [[ "${2}" == "aptss" ]]|| [[ "${3}" == "aptss" ]]; then
		REF_IS_USE_APTSS="true"
	fi

	if [[ -z "${REF_IS_USE_APTSS}" ]]; then
		REF_IS_USE_APTSS="${DEFAULT_IS_USE_APTSS}"
	fi

	#util_error_echo ${REF_IS_USE_APTSS}


	return 0
}




##
## ## Main / Start
##

__main__ () {

	gxde_build_iso_start "${@}"

}

_main_check_args_size_ "${#}"

_main_init_args_ "${@}"

__main__ "${@}"
