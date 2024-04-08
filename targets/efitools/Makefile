BUILD_DIR := ../../build/tools
EFITOOLS_DIR := $(BUILD_DIR)/efitools
TAG := v1.9.2
REPO_URL := https://github.com/vathpela/efitools.git

# Phony targets
.PHONY: all clone build clean

all: build

clone: $(EFITOOLS_DIR)/.git

$(EFITOOLS_DIR)/.git:
	mkdir -p $(BUILD_DIR)
	git clone --branch "$(TAG)" --depth 1 $(REPO_URL) $(EFITOOLS_DIR)

build: clone
	$(MAKE) -C $(EFITOOLS_DIR) -j

clean:
	rm -rf $(EFITOOLS_DIR)
