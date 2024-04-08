BUILD_DIR := ../../build
EFITOOLS_DIR := $(BUILD_DIR)/tools/efitools
HDA_ENROLL_DIR := $(BUILD_DIR)/hda-enroll/EFI/BOOT
LOCKDOWN_EFI := $(EFITOOLS_DIR)/LockDown.efi
BOOTX64_EFI := $(HDA_ENROLL_DIR)/BOOTX64.EFI

.PHONY: install-lockdown

all: lockdown

$(BOOTX64_EFI): $(LOCKDOWN_EFI)
	mkdir -p $(HDA_ENROLL_DIR)
	cp $(LOCKDOWN_EFI) $(BOOTX64_EFI) || { echo "Failed to copy LockDown to EFI/BOOT"; exit 1; }

lockdown: $(BOOTX64_EFI)
	cd ../../ && \
  ./bin/enroll-keys.sh
