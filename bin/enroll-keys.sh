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
  -serial "file:$OUTPUT_FILE" \
	-drive file=fat:rw:hda-enroll,format=raw,if=ide,index=0,media=disk &

  #> /dev/null 2>&1 &
QEMU_PID=$!

# Monitor the output file for the expected output
(
  timeout=180
  while [ -e "$OUTPUT_FILE" ] && [ $timeout -gt 0 ]; do
    EXPECTED_OUTPUT="Platform is set to boot securely"
    if grep -q "$EXPECTED_OUTPUT" "$OUTPUT_FILE"; then
      echo
      echo "Secure boot enabled"
      echo ">> $EXPECTED_OUTPUT"
      kill "$QEMU_PID"
      exit 0
    fi

    EXPECTED_OUTPUT="Platform is not in Setup Mode, cannot install Keys"
    if grep -q "$EXPECTED_OUTPUT" "$OUTPUT_FILE"; then
      echo
      echo "Secure boot *already* enabled, LockDown.efi refusing to run"
      echo ">> $EXPECTED_OUTPUT"
      kill "$QEMU_PID"
      exit 0
    fi

    EXPECTED_OUTPUT="Access Denied"
    if grep -q "$EXPECTED_OUTPUT" "$OUTPUT_FILE"; then
      echo
      echo ">> $EXPECTED_OUTPUT"
      echo "Secure boot enabled, but BOOTX64.efi not signed/valid"
      kill "$QEMU_PID"
      exit 0
    fi
    timeout=$((timeout-1))
    sleep 1
  done
  cat "$OUTPUT_FILE"
  die "Timeout"
)

# Setup cleanup to run on script exit
echo ""
echo "-------"
cat "$OUTPUT_FILE"
echo "Cleaning up..."
rm -f "$OUTPUT_FILE"
wait "$QEMU_PID"
