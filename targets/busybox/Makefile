# Variables
TOOLS_DIR := ../../build/tools
BUSYBOX := $(TOOLS_DIR)/busybox
BUSYBOX_URL := https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
BUSYBOX_SHA256 := 6e123e7f3202a8c1e9b1f94d8941580a25135382b99e8d3e34fb858bba311348

.PHONY: download-busybox

all: $(BUSYBOX)

$(BUSYBOX):
	mkdir -p $(TOOLS_DIR)
	if [ ! -e $@ ]; then \
		wget -O $@ $(BUSYBOX_URL); \
	fi
	echo "$(BUSYBOX_SHA256)  $@" | sha256sum -c -
	chmod +x $@

