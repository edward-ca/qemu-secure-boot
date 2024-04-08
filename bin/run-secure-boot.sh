#!/bin/bash -x

ROOTFS_SRC_IMG="rootfs.src.img"
ROOTFS_VERITY_IMG="rootfs.verity.img"

# Command to run QEMU
echo "Starting qemu..."
./bin/run-qemu.sh \
	-drive file=fat:rw:hda-boot,format=raw,if=ide,index=0,media=disk \
	-drive file=$ROOTFS_SRC_IMG,format=raw,index=0,media=disk,if=virtio \
	-drive file=$ROOTFS_VERITY_IMG,format=raw,index=1,media=disk,if=virtio
