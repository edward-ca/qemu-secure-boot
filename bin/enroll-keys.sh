#!/bin/bash -e
die()
{
  set +x
  echo "$(basename "$0"): $1"
  exit 1
}

# Temporary file to hold QEMU serial output
if ! OUTPUT_FILE=$(mktemp /tmp/qemu_serial_output.XXXXXX ); then
  die "mktemp failed"
fi

echo "Starting qemu..."
./bin/run-qemu.sh \
	-drive file=fat:rw:hda-enroll,format=raw,if=ide,index=0,media=disk &
