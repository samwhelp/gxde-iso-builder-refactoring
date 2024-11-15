
default: help
.PHONY: default

help:
	@echo 'Usage:'
	@echo '	$$ make [action]'
	@echo
	@echo 'Ex:'
	@echo '	$$ make'
	@echo '	$$ make help'
	@echo
	@echo '	$$ make build'
	@echo
.PHONY: help




build:
	@./build.sh
.PHONY: build




clean:
	sudo rm -rf /opt/tmp/gxde
.PHONY: clean




chroot-mount:
	@./chroot-mount.sh
.PHONY: chroot-mount




chroot-unmount:
	@./chroot-unmount.sh
.PHONY: chroot-unmount
