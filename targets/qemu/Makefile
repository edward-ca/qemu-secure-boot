BUILD_DIR := ../../build/tools
QEMU_VERSION := 8.1.5
QEMU_TAR := qemu-$(QEMU_VERSION).tar.xz
QEMU_SIG := $(QEMU_TAR).sig
QEMU_URL := https://download.qemu.org/$(QEMU_TAR)
QEMU_SIG_URL := $(QEMU_URL).sig
QEMU_KEY_URL := https://keys.openpgp.org/vks/v1/by-fingerprint/CEACC9E15534EBABB82D3FA03353C9CEF108B584
QEMU_SIGNING_KEY := $(BUILD_DIR)/qemu-signing-key
QEMU_SRC_DIR := $(BUILD_DIR)/qemu-$(QEMU_VERSION)
TARGET_LIST := $(shell uname -m)-softmmu

.PHONY: all download verify-key download-key extract configure build install clean

all: install

download: $(BUILD_DIR)/$(QEMU_TAR) $(BUILD_DIR)/$(QEMU_SIG)

$(BUILD_DIR)/$(QEMU_TAR):
	mkdir -p $(BUILD_DIR)
	wget -O $@ $(QEMU_URL)

$(BUILD_DIR)/$(QEMU_SIG):
	mkdir -p $(BUILD_DIR)
	wget -O $@ $(QEMU_SIG_URL)

download-key: $(QEMU_SIGNING_KEY)

$(QEMU_SIGNING_KEY):
	wget $(QEMU_KEY_URL) -O $@

verify-key: download-key $(BUILD_DIR)/$(QEMU_SIG) $(BUILD_DIR)/$(QEMU_TAR)
	gpg --import $(QEMU_SIGNING_KEY)
	gpg --verify $(BUILD_DIR)/$(QEMU_SIG) $(BUILD_DIR)/$(QEMU_TAR)

extract: verify-key $(BUILD_DIR)/qemu-$(QEMU_VERSION)
$(BUILD_DIR)/qemu-$(QEMU_VERSION):
	tar -xf $(BUILD_DIR)/$(QEMU_TAR) -C $(BUILD_DIR)

configure: $(QEMU_SRC_DIR)/config-host.mak
$(QEMU_SRC_DIR)/config-host.mak: extract
	cd $(QEMU_SRC_DIR) && ./configure --target-list=$(TARGET_LIST)

build: $(QEMU_SRC_DIR)/qemu-system-$(shell uname -m)
$(QEMU_SRC_DIR)/qemu-system-$(shell uname -m): configure
	$(MAKE) -C $(QEMU_SRC_DIR) -j

install: build
	sudo $(MAKE) -C $(QEMU_SRC_DIR) install

clean:
	rm -rf $(BUILD_DIR)/$(QEMU_TAR) $(BUILD_DIR)/$(QEMU_SIG) $(QEMU_SIGNING_KEY) $(BUILD_DIR)/qemu-$(QEMU_VERSION)

