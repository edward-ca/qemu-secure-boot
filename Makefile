SHELL := /bin/bash

TARGETS := qemu ovmf efitools lockdown busybox rootfs initramfs linux

.PHONY: all $(TARGETS) clean

all: $(TARGETS)

./build:
	mkdir -p ./build/tools

$(TARGETS): ./build
	$(MAKE) -C targets/$@ all

clean:
	for dir in $(TARGETS); do \
		$(MAKE) -C targets/$$dir clean; \
	done
