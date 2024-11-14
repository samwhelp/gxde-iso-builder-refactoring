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

echo $REF_PLAN_WORK_DIR_PATH

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

	#gxde_build_iso_package_required

	sleep 5

	return 0
}

gxde_build_iso_steps () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## gxde_build_iso_steps"
	util_error_echo "##"

	gxde_build_iso_package_required



	return 0
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
