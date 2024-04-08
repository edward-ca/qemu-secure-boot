# Summary

This project demonstrates the implementation of Secure Boot on QEMU using OVMF (Open Virtual Machine Firmware).

# Components

- **QEMU**: Emulates a virtual machine environment.
- **EDK2/OVMF**: Provides UEFI BIOS support for virtual machines.
- **EFITools**: Contains EFI binaries utilized to enroll security keys.
- **Initramfs**: Initial RAM filesystem, used during the boot process.
- **Linux**: The operating system kernel.
- **DM Verity**: Ensures the integrity of device-mapped volumes.

# Key Generation

For simplicity, this demonstration utilizes keys generated during the `efitools` build process. While these keys are unique, generating keys in this manner is not recommended for production environments.

The generated keys include:

- **PK (Platform Key)**: Serves as the root of trust, controlling the key hierarchy. It permits changes to the KEK and Secure Boot configuration. Access to the PK should be restricted to the owner or manufacturer to maintain security.

- **KEK (Key Exchange Key)**: Authorizes changes to the DB and DBX, signing these databases to ensure only trusted updates are applied. The PK controls the KEK.

- **DB (Signature Database)**: Lists signatures of allowed software, including operating systems and loaders. Software with a signature in the DB is authorized to run.

Together, these keys and databases play critical roles in the UEFI Secure Boot process, ensuring only authenticated and trusted code executes during system boot, thereby safeguarding against bootkit and rootkit infections.

For this demo, we will focus on using the DB key to sign the Linux kernel.

# Key Enrollment

QEMU is initiated with the OVMF BIOS, which searches for the `build/hda-boot/EFI/BOOT/BOOTX64.EFI` file on the FAT partition.

During key enrollment, we employ the `LockDown.efi` binary as our `BOOTX64.EFI`, enrolling the previously generated keys as part of the EFI boot process.

Below is the output from the key enrollment process:
```
+ exec qemu-system-x86_64 -m 2048 -global ICH9-LPC.disable_s3=1 -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,readonly=on,file=./flash/OVMF_CODE.fd -drive if=pflash,format=raw,unit=1,readonly=off,file=./flash/OVMF_VARS.fd -machine q35,smm=on,accel=tcg -net none -nographic -drive file=fat:rw:hda-enroll,format=raw,if=ide,index=0,media=disk
BdsDxe: failed to load Boot0000 "UEFI QEMU DVD-ROM QM00005 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x2,0xFFFF,0x0): Not Found
BdsDxe: loading Boot0001 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x0,0xFFFF,0x0)
BdsDxe: starting Boot0001 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x0,0xFFFF,0x0)
Platform is in Setup Mode
Created KEK Cert
Created db Cert
Created PK Cert
Platform is in User Mode
Platform is set to boot securely
```

Completion of this step results in the keys being stored within `OVMF.vars`, simulating the NVRAM of a physical system.

# DM-Verity Rootfs

The `veritysetup` tool from the `cryptsetup` package is utilized to generate verity metadata, affirming the integrity of the root filesystem (rootfs).

A `root_hash` is produced and passed to the initramfs via the kernel command line.

Given that this hash verifies the rootfs's integrity, it's crucial to sign both the initramfs and command line as part of the kernel.

# Unified Kernel

Maintaining the boot process's integrity necessitates the execution of only signed code.

This is achieved by amalgamating the Linux kernel, initramfs, and kernel command line into a single bootable image, subsequently signed.

The `sbsign` tool facilitates the signing process using `DB.key`.

# Usage

Executing the `make` command within the project root directory compiles all necessary tools and files for the Secure Boot demonstration. Note that `sudo` access is required to install `qemu-system-x86_64` and for `losetup` operations (used in DM-Verity setup).

Once the build is complete, the `bin/run-secure-boot.sh` script launches the Secure Boot virtual machine (VM).

Below is the output of a successful secure boot.
```
$ ./bin/run-secure-boot.sh
+ ROOTFS_SRC_IMG=rootfs.src.img
+ ROOTFS_VERITY_IMG=rootfs.verity.img
+ echo 'Starting qemu...'
Starting qemu...
+ ./bin/run-qemu.sh -drive file=fat:rw:hda-boot,format=raw,if=ide,index=0,media=disk -drive file=rootfs.src.img,format=raw,index=0,media=disk,if=virtio -drive file=rootfs.verity.img,format=raw,index=1,media=disk,if=virtio
+ cd build/
+ exec qemu-system-x86_64 -m 2048 -global ICH9-LPC.disable_s3=1 -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,readonly=on,file=./flash/OVMF_CODE.fd -drive if=pflash,format=raw,unit=1,readonly=off,file=./flash/OVMF_VARS.fd -machine q35,smm=on,accel=tcg -net none -nographic -drive file=fat:rw:hda-boot,format=raw,if=ide,index=0,media=disk -drive file=rootfs.src.img,format=raw,index=0,media=disk,if=virtio -drive file=rootfs.verity.img,format=raw,index=1,media=disk,if=virtio
BdsDxe: failed to load Boot0000 "UEFI QEMU DVD-ROM QM00005 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x2,0xFFFF,0x0): Not Found
BdsDxe: loading Boot0001 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x0,0xFFFF,0x0)
BdsDxe: starting Boot0001 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1F,0x2)/Sata(0x0,0xFFFF,0x0)
>>> Running Initramfs /init
[    0.000000] Linux version 6.8.4 (azureuser@SecureBoot) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #1 SMP PREEMPT_DYNAMIC Mon Apr  8 15:18:55 UTC 2024
[    0.053543] Secure boot enabled
>>> Secure Boot is enabled.
[    2.623209] device-mapper: verity: sha256 using implementation "sha256-generic"
[    2.652308] veritysetup (66) used greatest stack depth: 13288 bytes left
>>> Mounted  verity backed parition
Running verity partition /sbin/init
Press any key to enter an interactive shell. Continuing in 5 seconds otherwise...

Continuing with the script...Powering off...
[    7.884701] sysrq: Power Off
[    7.896049] reboot: Power down
```

# Files

- `Makefile`: The project's top-level Makefile.
- `bin/enroll-keys.sh`: Enrolls keys in `OVMF_VAR.fd`.
- `bin/run-secure-boot.sh`: Boots the signed Linux kernel with a DM-Verity rootfs.
- `bin/run-qemu.sh`: Auxiliary script for the aforementioned commands.
- `patches/disable_OVMF_ui.patch`: Disables the UEFI UI to prevent BIOS-level manipulation.
- `targets/initramfs/init`: Init script for Initramfs, verifying Secure Boot and mounting the verity rootfs.
- `targets/rootfs/init`: Rootfs init script, awaits user interaction before shutting down the VM.
- `targets/*/Makefile`: Makefiles for various tools and targets.
