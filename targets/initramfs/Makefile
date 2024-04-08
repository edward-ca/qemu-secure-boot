BUILD_DIR := ../../build
INITRAMFS_DIR := $(BUILD_DIR)/initramfs
TOOLS_DIR := $(BUILD_DIR)/tools
BUSYBOX_BIN := $(TOOLS_DIR)/busybox
CRYPTSETUP_BIN := /sbin/veritysetup
DMSETUP_BIN := /sbin/dmsetup
INITRAMFS_CPIO := $(BUILD_DIR)/initramfs.cpio
INIT_SCRIPT := init

.PHONY: all clean initramfs

all: initramfs

initramfs: $(INITRAMFS_CPIO)

$(INITRAMFS_CPIO): $(INITRAMFS_DIR) $(INIT_SCRIPT)
	cd $(INITRAMFS_DIR) && \
	find . | cpio -H newc -o > $(INITRAMFS_CPIO)

$(INITRAMFS_DIR): $(BUSYBOX_BIN) $(CRYPTSETUP_BIN) $(DMSETUP_BIN)
	if [ -d $(INITRAMFS_DIR) ]; then rm -r $(INITRAMFS_DIR); fi
	mkdir -p $(INITRAMFS_DIR)/bin \
	  $(INITRAMFS_DIR)/sbin \
    $(INITRAMFS_DIR)/etc \
    $(INITRAMFS_DIR)/proc \
    $(INITRAMFS_DIR)/sys \
    $(INITRAMFS_DIR)/dev \
    $(INITRAMFS_DIR)/usr/bin \
    $(INITRAMFS_DIR)/usr/sbin \
    $(INITRAMFS_DIR)/lib \
    $(INITRAMFS_DIR)/lib64 \
    $(INITRAMFS_DIR)/tmp
	cp $(BUSYBOX_BIN) $(INITRAMFS_DIR)/bin/
	sudo chroot $(INITRAMFS_DIR) /bin/busybox --install -s bin
	cp $(CRYPTSETUP_BIN) $(INITRAMFS_DIR)/sbin/
	cp $(DMSETUP_BIN) $(INITRAMFS_DIR)/sbin/
	ldd $(CRYPTSETUP_BIN) | tr -s '[:space:]' '\n' | grep '^/' | xargs -I {} cp --parents {} $(INITRAMFS_DIR) || true
	ldd $(DMSETUP_BIN) | tr -s '[:space:]' '\n' | grep '^/' | xargs -I {} cp --parents {} $(INITRAMFS_DIR) || true
	sudo mknod -m 622 $(INITRAMFS_DIR)/dev/console c 5 1
	sudo mknod -m 622 $(INITRAMFS_DIR)/dev/tty c 5 0
	sudo mknod -m 666 $(INITRAMFS_DIR)/dev/null c 1 3
	cp $(INIT_SCRIPT) $(INITRAMFS_DIR)/

clean:
	rm -rf $(INITRAMFS_DIR) $(INITRAMFS_CPIO)

