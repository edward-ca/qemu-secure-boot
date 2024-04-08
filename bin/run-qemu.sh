#!/bin/bash -x

cd build/ || exit 1
# Command to run QEMU
exec qemu-system-x86_64 \
	-m 2048 \
	-global ICH9-LPC.disable_s3=1 \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,readonly=on,file=./flash/OVMF_CODE.fd \
	-drive if=pflash,format=raw,unit=1,readonly=off,file=./flash/OVMF_VARS.fd \
	-machine q35,smm=on,accel=tcg \
	-net none \
	-nographic \
	"$@"
