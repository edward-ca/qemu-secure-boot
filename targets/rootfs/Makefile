BUILD_DIR := ../../build
TOOLS_DIR := $(BUILD_DIR)/tools
ROOTFS_DIR := $(BUILD_DIR)/rootfs
IMAGE_SRC_FILE := $(BUILD_DIR)/rootfs.src.img
IMAGE_VERITY_FILE := $(BUILD_DIR)/rootfs.verity.img
VERITY_FILE := $(BUILD_DIR)/verity.txt
IMAGE_SIZE := 20M
MNT_POINT := $(shell mktemp -d)

.PHONY: all clean create-rootfs create-image setup-verity

all: create-rootfs create-image setup-verity

create-rootfs:
	mkdir -p $(ROOTFS_DIR)/bin \
	  $(ROOTFS_DIR)/sbin \
    $(ROOTFS_DIR)/etc \
    $(ROOTFS_DIR)/proc \
    $(ROOTFS_DIR)/sys \
    $(ROOTFS_DIR)/dev \
    $(ROOTFS_DIR)/usr/bin \
    $(ROOTFS_DIR)/usr/sbin \
    $(ROOTFS_DIR)/lib \
    $(ROOTFS_DIR)/lib64 \
    $(ROOTFS_DIR)/tmp
	cp $(TOOLS_DIR)/busybox $(ROOTFS_DIR)/bin/
	cp init $(ROOTFS_DIR)/sbin
	sudo chroot $(ROOTFS_DIR) /bin/busybox --install -s bin

create-image: create-rootfs
	dd if=/dev/zero of=$(IMAGE_SRC_FILE) bs=$(IMAGE_SIZE) count=1
	mkfs.ext4 $(IMAGE_SRC_FILE)
	sudo mount -o loop $(IMAGE_SRC_FILE) $(MNT_POINT)
	sudo cp -a $(ROOTFS_DIR)/* $(MNT_POINT)/
	sudo umount $(MNT_POINT)

setup-verity: create-image
	LOOP_DEVICE=$$(sudo losetup -fP --show $(IMAGE_SRC_FILE)) && \
	VERITY_OUTPUT=$$(sudo veritysetup format "$$LOOP_DEVICE" $(IMAGE_VERITY_FILE) 2>&1) && \
	echo "$$VERITY_OUTPUT" > $(VERITY_FILE) && \
	ROOT_HASH=$$(echo "$$VERITY_OUTPUT" | grep 'Root hash:' | awk '{print $$3}') && \
	SALT=$$(echo "$$VERITY_OUTPUT" | grep 'Salt:' | awk '{print $$2}') && \
	echo "Root hash is: $$ROOT_HASH" && \
	echo "Salt is: $$SALT" && \
	sudo losetup -d "$$LOOP_DEVICE" && \
	sudo chown $$USER $(IMAGE_VERITY_FILE)

clean:
	sudo umount $(MNT_POINT) || true
	rm -f $(IMAGE_SRC_FILE) $(IMAGE_VERITY_FILE) $(VERITY_FILE)
	rm -rf $(ROOTFS_DIR)

