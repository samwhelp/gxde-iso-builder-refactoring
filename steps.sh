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
## ## Overlay / Path
##

REF_OVERLAY_DIR_NAME="overlay"
REF_OVERLAY_DIR_PATH="${REF_PLAN_ASSET_DIR_PATH}/${REF_OVERLAY_DIR_NAME}"

REF_FACTORY_OVERLAY_DIR_NAME="${REF_OVERLAY_DIR_NAME}"
REF_FACTORY_OVERLAY_DIR_PATH="${REF_PLAN_FACTORY_DIR_PATH}/${REF_FACTORY_OVERLAY_DIR_NAME}"


##
## ## ISO Template / Path
##

REF_ISO_TEMPLATE_SOURCE_DIR_NAME="iso-template"
REF_ISO_TEMPLATE_SOURCE_DIR_PATH="${REF_PLAN_FACTORY_DIR_PATH}/${REF_ISO_TEMPLATE_SOURCE_DIR_NAME}"


REF_ISO_TEMPLATE_TARGET_DIR_NAME="${REF_ISO_TEMPLATE_SOURCE_DIR_NAME}"
REF_ISO_TEMPLATE_TARGET_DIR_PATH="${REF_PLAN_WORK_DIR_PATH}/${REF_ISO_TEMPLATE_TARGET_DIR_NAME}"


##
## ## Live Deb / Path
##

REF_LIVE_DEB_MIDDLE_DIR_NAME="live-deb"
REF_LIVE_DEB_MIDDLE_DIR_PATH="${REF_PLAN_WORK_DIR_PATH}/${REF_LIVE_DEB_MIDDLE_DIR_NAME}"


REF_LIVE_DEB_SOURCE_DIR_NAME="archives"
REF_LIVE_DEB_SOURCE_DIR_PATH="${REF_MASTER_OS_ROOT_DIR_PATH}/var/cache/apt/${REF_LIVE_DEB_SOURCE_DIR_NAME}"


##
## ## Target OS / Util
##

function util_chroot_package_control () {

	local is_use_aptss="${REF_IS_USE_APTSS}"

	if [[ "${is_use_aptss}" == "true" ]]; then
		util_chroot_run aptss "$@"
	else
		util_chroot_run apt "$@"
	fi

}

function util_chroot_run () {

	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	local i=1

	for i in {1..5}; do

		sudo env DEBIAN_FRONTEND=noninteractive chroot "${rootfs}" "${@}"

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
	#gxde_target_os_mount_for_chroot


	gxde_build_os_factory_overlay


	gxde_build_os_overlay


	#gxde_build_os_clean
	#sleep 5
	#gxde_target_os_unmount_for_chroot
	#sleep 5


	#gxde_build_os_archive
	#gxde_build_iso_create
	#gxde_build_iso_create_skel
	#gxde_build_iso_create_test


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


	gxde_build_os_factory_overlay


	gxde_build_os_overlay


	gxde_build_os_clean
	sleep 5
	gxde_target_os_unmount_for_chroot
	sleep 5


	gxde_build_os_archive
	gxde_build_iso_create


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
## ## GXDE / Build Target OS / Overlay
##

gxde_build_os_factory_overlay () {

	local overlay_dir_path="${REF_FACTORY_OVERLAY_DIR_PATH}"
	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Factory Overlay"
	util_error_echo "##"
	util_error_echo

	util_error_echo
	util_error_echo cp -rf "${overlay_dir_path}/." "${rootfs}"
	cp -rf "${overlay_dir_path}/." "${rootfs}"

	return 0
}

gxde_build_os_overlay () {

	local overlay_dir_path="${REF_OVERLAY_DIR_PATH}"
	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Overlay"
	util_error_echo "##"
	util_error_echo

	util_error_echo
	util_error_echo cp -rf "${overlay_dir_path}/." "${rootfs}"
	cp -rf "${overlay_dir_path}/." "${rootfs}"

	return 0
}


##
## ## GXDE / Build Target OS / Locale
##

gxde_build_os_factory_locale () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Factory Locale"
	util_error_echo "##"
	util_error_echo

	util_error_echo
	util_error_echo util_chroot_package_control install locales -y
	util_error_echo
	util_chroot_package_control install locales -y

	util_error_echo
	util_error_echo util_chroot_run locale-gen
	util_error_echo
	util_chroot_run locale-gen

	return 0

}

gxde_build_os_locale () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build Target OS / Locale"
	util_error_echo "##"
	util_error_echo

	#util_error_echo
	#util_error_echo util_chroot_package_control install locales -y
	#util_error_echo
	#util_chroot_package_control install locales -y

	util_error_echo
	util_error_echo util_chroot_run locale-gen
	util_error_echo
	util_chroot_run locale-gen

	return 0

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
## ## GXDE / ISO Template / Prepare
##

gxde_iso_template_prepare () {

	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"
	local iso_template_source_dir_path="${REF_ISO_TEMPLATE_SOURCE_DIR_PATH}"


	util_error_echo
	util_error_echo rm -rf "${iso_template_target_dir_path}"
	rm -rf "${iso_template_target_dir_path}"

	util_error_echo
	util_error_echo mkdir -p "${iso_template_target_dir_path}"
	mkdir -p "${iso_template_target_dir_path}"


	util_error_echo
	util_error_echo cp -rf "${iso_template_source_dir_path}/." "${iso_template_target_dir_path}"
	cp -rf "${iso_template_source_dir_path}/." "${iso_template_target_dir_path}"




	##
	## ## prepare extra dir
	##
	local build_arch="${REF_BUILD_ARCH}"
	local build_arch_dir_path="${iso_template_target_dir_path}/${build_arch}"


	util_error_echo
	util_error_echo mkdir -p "${build_arch_dir_path}/live"
	mkdir -p "${build_arch_dir_path}/live"


	util_error_echo
	util_error_echo mkdir -p "${build_arch_dir_path}/deb"
	mkdir -p "${build_arch_dir_path}/deb"


	return 0
}


##
## ## GXDE / ISO Template / Prepare / copy Kernel
##

gxde_iso_template_prepare_copy_kernel () {


	local rootfs="${REF_TARGET_OS_ROOT_DIR_PATH}"

	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_arch_dir_path="${iso_template_target_dir_path}/${build_arch}"


	##
	## ## prepare dir
	##
	util_error_echo
	util_error_echo mkdir -p "${build_arch_dir_path}/live"
	mkdir -p "${build_arch_dir_path}/live"




	local kernel_number=$(ls -1 ${rootfs}/boot/vmlinuz-* | wc -l)
	local vmlinuz_list=($(ls -1 ${rootfs}/boot/vmlinuz-* | sort -rV))
	local initrd_list=($(ls -1 ${rootfs}/boot/initrd.img-* | sort -rV))

	#util_error_echo "kernel_number=${kernel_number}"
	#util_error_echo "vmlinuz_list=${vmlinuz_list}"
	#util_error_echo "initrd_list=${initrd_list}"

	local i=0

	for i in $( seq 0 $(expr ${kernel_number} - 1) ); do

		if [[ ${i} == 0 ]]; then
			cp "${vmlinuz_list[i]}" "${build_arch_dir_path}/live/vmlinuz" -v
			cp "${initrd_list[i]}" "${build_arch_dir_path}/live/initrd.img" -v
		fi

		if [[ ${i} == 1 ]]; then
			cp "${vmlinuz_list[i]}" "${build_arch_dir_path}/live/vmlinuz-oldstable" -v
			cp "${initrd_list[i]}" "${build_arch_dir_path}/live/initrd.img-oldstable" -v
		fi

	done


	return 0
}

##
## ## GXDE / ISO Template / Prepare / copy os archive
##


gxde_iso_template_prepare_copy_os_archive () {


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_arch_dir_path="${iso_template_target_dir_path}/${build_arch}"

	local os_archive_file_path="${REF_TARGET_OS_ARCHIVE_FILE_PATH}"


	##
	## ## prepare dir
	##
	util_error_echo
	util_error_echo mkdir -p "${build_arch_dir_path}/live"
	mkdir -p "${build_arch_dir_path}/live"


	##
	## ## prepare os archive
	##

	#util_error_echo
	#util_error_echo mv "${os_archive_file_path}" "${build_arch_dir_path}/live/filesystem.squashfs" -v
	#util_error_echo
	#mv "${os_archive_file_path}" "${build_arch_dir_path}/live/filesystem.squashfs" -v

	util_error_echo
	util_error_echo cp "${os_archive_file_path}" "${build_arch_dir_path}/live/filesystem.squashfs" -v
	util_error_echo
	cp "${os_archive_file_path}" "${build_arch_dir_path}/live/filesystem.squashfs" -v


	util_error_echo

	return 0
}



##
## ## GXDE / ISO Template / Prepare / add debian package
##

gxde_iso_template_prepare_add_debian_package () {


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_arch_dir_path="${iso_template_target_dir_path}/${build_arch}"

	local live_deb_middle_dir_path="${REF_LIVE_DEB_MIDDLE_DIR_PATH}/${build_arch}"


	##
	## ## add debian package / prepare dir
	##
	util_error_echo
	util_error_echo mkdir -p "${build_arch_dir_path}/deb"
	mkdir -p "${build_arch_dir_path}/deb"


	##
	## ## add debian package / head
	##
	util_error_echo
	util_error_echo cd "${build_arch_dir_path}/deb"
	cd "${build_arch_dir_path}/deb"


	##
	## ## add debian package / start
	##
	util_error_echo
	util_error_echo ./addmore.py "${live_deb_middle_dir_path}"/*.deb
	util_error_echo
	./addmore.py "${live_deb_middle_dir_path}"/*.deb


	##
	## ## add debian package / tail
	##
	util_error_echo
	util_error_echo cd "${OLDPWD}"
	cd "${OLDPWD}"


	return 0
}


##
## ## GXDE / Build ISO / Archive
##

gxde_build_iso_archive () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build ISO / Archive / Start"
	util_error_echo "##"
	util_error_echo


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"
	local iso_template_source_dir_path="${REF_ISO_TEMPLATE_SOURCE_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_agent_file_name="${build_arch}-build.sh"
	local build_agent="./${build_agent_file_name}"
	local build_agent_path="${iso_template_target_dir_path}/${build_agent_file_name}"


	##
	## ## iso build head
	##
	util_error_echo
	util_error_echo cd "${iso_template_target_dir_path}"
	cd "${iso_template_target_dir_path}"


	##
	## ## iso build start
	##
	util_error_echo
	util_error_echo bash "${build_agent}"
	util_error_echo
	bash "${build_agent}"


	##
	## ## iso build tail
	##
	util_error_echo
	util_error_echo "cd ${OLDPWD}"
	cd "${OLDPWD}"




	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build ISO / Archive / Done"
	util_error_echo "##"
	util_error_echo


	return 0
}


##
## ## GXDE / Build ISO / Create
##

gxde_build_iso_create () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build ISO / Create"
	util_error_echo "##"
	util_error_echo


	##
	## ## create iso template
	##
	gxde_iso_template_prepare


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"
	local iso_template_source_dir_path="${REF_ISO_TEMPLATE_SOURCE_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_agent_file_name="${build_arch}-build.sh"
	local build_agent="./${build_agent_file_name}"
	local build_agent_path="${iso_template_target_dir_path}/${build_agent_file_name}"


	if [[ ! -f "${build_agent_path}" ]]; then

		util_error_echo
		util_error_echo "##"
		util_error_echo "## ## Build iso script not exists: "
		util_error_echo "##"

		util_error_echo
		util_error_echo "> ${build_agent_path}"
		util_error_echo

		exit 1
	fi


	##
	## ## add debian package
	##
	gxde_iso_template_prepare_add_debian_package


	##
	## ## copy kernel
	##
	gxde_iso_template_prepare_copy_kernel


	##
	## ## copy os archive
	##
	gxde_iso_template_prepare_copy_os_archive


	##
	## ## create iso
	##
	gxde_build_iso_archive


	return 0
}

gxde_build_iso_create_skel () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build ISO / Create Skel"
	util_error_echo "##"
	util_error_echo


	##
	## ## create iso template
	##
	gxde_iso_template_prepare


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"
	local iso_template_source_dir_path="${REF_ISO_TEMPLATE_SOURCE_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_agent_file_name="${build_arch}-build.sh"
	local build_agent="./${build_agent_file_name}"
	local build_agent_path="${iso_template_target_dir_path}/${build_agent_file_name}"


	if [[ ! -f "${build_agent_path}" ]]; then

		util_error_echo
		util_error_echo "##"
		util_error_echo "## ## Build iso script not exists: "
		util_error_echo "##"

		util_error_echo
		util_error_echo "> ${build_agent_path}"
		util_error_echo

		exit 1
	fi


	##
	## ## create iso
	##
	gxde_build_iso_archive


	return 0
}

gxde_build_iso_create_test () {

	util_error_echo
	util_error_echo "##"
	util_error_echo "## ## GXDE / Build ISO / Create"
	util_error_echo "##"
	util_error_echo


	##
	## ## create iso template
	##
	gxde_iso_template_prepare


	local iso_template_target_dir_path="${REF_ISO_TEMPLATE_TARGET_DIR_PATH}"
	local iso_template_source_dir_path="${REF_ISO_TEMPLATE_SOURCE_DIR_PATH}"

	local build_arch="${REF_BUILD_ARCH}"
	local build_agent_file_name="${build_arch}-build.sh"
	local build_agent="./${build_agent_file_name}"
	local build_agent_path="${iso_template_target_dir_path}/${build_agent_file_name}"


	if [[ ! -f "${build_agent_path}" ]]; then

		util_error_echo
		util_error_echo "##"
		util_error_echo "## ## Build iso script not exists: "
		util_error_echo "##"

		util_error_echo
		util_error_echo "> ${build_agent_path}"
		util_error_echo

		exit 1
	fi


	##
	## ## add debian package
	##
	gxde_iso_template_prepare_add_debian_package


	##
	## ## copy kernel
	##
	#gxde_iso_template_prepare_copy_kernel


	##
	## ## copy os archive
	##
	#gxde_iso_template_prepare_copy_os_archive


	##
	## ## create iso
	##
	gxde_build_iso_archive


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
