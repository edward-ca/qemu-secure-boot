BUILD_DIR := ../../build
TOOLS_DIR := $(BUILD_DIR)/tools
EDK2_DIR := $(TOOLS_DIR)/qemu-8.1.5/roms/edk2
FLASH_DIR := $(BUILD_DIR)/flash
OVMF_PATCH_FILE := ..//patches/disable_OVMF_ui.patch
OVMF_CODE := $(FLASH_DIR)/OVMF_CODE.fd
OVMF_VARS := $(FLASH_DIR)/OVMF_VARS.fd
PATCH_APPLIED := $(EDK2_DIR)/.ovmf_patch_applied

TARGET_FILES := $(OVMF_CODE) $(OVMF_VARS)

.PHONY: all clean patch build

all: $(TARGET_FILES)

$(PATCH_APPLIED): ../$(OVMF_PATCH_FILE)
	cd $(BUILD_DIR) && \
	patch -p0 --forward --silent --reject-file=/dev/null < $(OVMF_PATCH_FILE) || \
	(patch -p0 --reverse --dry-run --silent < $(OVMF_PATCH_FILE) >/dev/null 2>&1 || \
	{ echo "Patch could not be applied." ; exit 1; })
	touch $(PATCH_APPLIED)

$(EDK2_DIR)/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd $(EDK2_DIR)/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_VARS.fd: $(PATCH_APPLIED)
	cd $(EDK2_DIR) && \
	OvmfPkg/build.sh -D SECURE_BOOT_ENABLE=TRUE -D SMM_REQUIRE=TRUE -D BUILD_SHELL=FALSE -b RELEASE -a X64 && \
	cd - && \
  touch $@

$(OVMF_CODE): $(EDK2_DIR)/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd
	mkdir -p $(FLASH_DIR)
	cp $< $@

$(OVMF_VARS): $(EDK2_DIR)/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_VARS.fd
	mkdir -p $(FLASH_DIR)
	cp $< $@

clean:
	rm -f $(OVMF_CODE) $(OVMF_VARS) $(PATCH_APPLIED)
