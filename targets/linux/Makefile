BUILD_DIR := ../../build
DOWNLOAD_DIR := $(BUILD_DIR)/kernel
SOURCE_URL := https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.4.tar.xz
SIGNATURE_URL := https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.4.tar.sign
KERNEL_SOURCE_PATH := $(DOWNLOAD_DIR)/linux-6.8.4
VERITY_TXT_PATH := $(BUILD_DIR)/verity.txt
SIGNING_KEY_PATH := $(BUILD_DIR)/tools/efitools/DB.key
SIGNING_CERT_PATH := $(BUILD_DIR)/tools/efitools/DB.crt
KERNEL_TGZ := "$(DOWNLOAD_DIR)/kernel.tar.xz"
KERNEL_SIGN := "$(DOWNLOAD_DIR)/kernel.tar.sign"
KERNEL_PATH := $(BUILD_DIR)/kernel/linux-6.8.4/arch/x86_64/boot/bzImage.signed
EFI_DEST_PATH := $(BUILD_DIR)/hda-boot/EFI/BOOT/

.PHONY: install_kernel


.PHONY: all download_kernel verify_kernel prepare_kernel build_kernel sign_kernel

all: download_kernel verify_kernel prepare_kernel build_kernel sign_kernel install_kernel $(EFI_DEST_PATH)/BOOTX64.EFI
$(KERNEL_TGZ):
	mkdir -p "$(DOWNLOAD_DIR)"
	curl -L "$(SOURCE_URL)" -o "$(DOWNLOAD_DIR)/kernel.tar.xz"

$(KERNEL_SIGN): $(KERNEL_TGZ)
	mkdir -p "$(DOWNLOAD_DIR)"
	curl -L "$(SIGNATURE_URL)" -o "$(DOWNLOAD_DIR)/kernel.tar.sign"

$(KERNEL_SOURCE_PATH): $(KERNEL_TGZ) $(KERNEL_SIGN)
	gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org
	gpg2 --tofu-policy good 38DBBDC86092693E
	unxz -f "$(DOWNLOAD_DIR)/kernel.tar.xz"
	gpg2 --trust-model tofu --verify "$(DOWNLOAD_DIR)/kernel.tar.sign"
	tar -xf "$(DOWNLOAD_DIR)/kernel.tar" -C "$(DOWNLOAD_DIR)"

prepare_kernel: $(KERNEL_SOURCE_PATH)
	$(eval ROOT_HASH=$(shell grep 'Root hash:' $(VERITY_TXT_PATH) | awk '{print $$3}'))
	cd "$(KERNEL_SOURCE_PATH)" && \
	make defconfig && \
	scripts/config --disable DRM && \
	scripts/config --disable AGP && \
	scripts/config --disable NET && \
	scripts/config --set-str CONFIG_CMDLINE "console=ttyS0 quiet loglevel=3 root_hash=$(ROOT_HASH)" && \
	scripts/config --enable CONFIG_CMDLINE_BOOL && \
	scripts/config --disable CONFIG_CMDLINE_OVERRIDE && \
	scripts/config --disable CONFIG_MODULES && \
	scripts/config --enable CONFIG_DM_VERITY && \
	scripts/config --disable DM_DEBUG_BLOCK_MANAGER_LOCKING && \
	scripts/config --disable DM_VERITY_VERIFY_ROOTHASH_SIG && \
	scripts/config --disable DM_VERITY_FEC && \
	scripts/config --set-str CONFIG_INITRAMFS_SOURCE "../../initramfs.cpio" && \
	scripts/config --set-val INITRAMFS_ROOT_UID 0 && \
	scripts/config --set-val INITRAMFS_ROOT_GID 0 && \
	scripts/config --enable INITRAMFS_COMPRESSION_GZIP && \
	scripts/config --disable INITRAMFS_COMPRESSION_BZIP2 && \
  scripts/config --disable INITRAMFS_COMPRESSION_LZMA && \
  scripts/config --disable INITRAMFS_COMPRESSION_XZ && \
  scripts/config --disable INITRAMFS_COMPRESSION_LZO && \
  scripts/config --disable INITRAMFS_COMPRESSION_LZ4 && \
  scripts/config --disable INITRAMFS_COMPRESSION_ZSTD && \
  scripts/config --disable INITRAMFS_COMPRESSION_NONE

$(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage: prepare_kernel
	cd "$(KERNEL_SOURCE_PATH)" && \
	make "-j$(shell nproc)" bzImage

$(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage.signed:  $(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage
	sbsign --key "$(SIGNING_KEY_PATH)" --cert "$(SIGNING_CERT_PATH)" \
		--output "$(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage.signed" "$(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage"

$(EFI_DEST_PATH)/BOOTX64.EFI: $(KERNEL_SOURCE_PATH)/arch/x86_64/boot/bzImage.signed
	mkdir -p $(EFI_DEST_PATH)
	cp "$(KERNEL_PATH)" "$(EFI_DEST_PATH)/BOOTX64.EFI" || { echo "Failed to install kernel"; exit 1; }

