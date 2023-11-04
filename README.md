kernel source and uboot configuration for linux 6.1.31 for the orange pi zero 3.

## disclaimers

* **wifi and bluetooth currently do not work** until someone smarter than me updates the defconfig and/or provides a firmware patch.
* the nix expressions are probably pretty bad. they work, but i have no doubt they aren't idiomatic.

## layout

```
├───devShell
│   ├───aarch64-linux: development environment 'nix-shell'
│   └───x86_64-linux: development environment 'nix-shell'
├───overlays
│   └───aarch64-linux: Nixpkgs overlay
└───packages
    └───aarch64-linux
        ├───linuxOrangePiZero3: package 'linux-6.1.31-sun50iw9'
        └───ubootOrangePiZero3: package 'uboot-orangepi_zero3_defconfig-2021.07'
```

## sources

kernel tree: https://github.com/orangepi-xunlong/linux-orangepi/commit/3495b5ee0594566c9fed930b96b1cae90600412e
uboot tree: https://github.com/orangepi-xunlong/u-boot-orangepi/commit/6fe17fac388aad17490cf386578b7532975e567f

## usage

**for your own orange pi zero 3:**
here's a snapshot of my own configuration, which should be a good starting point. some of the options are probably redundant, but i'd rather be safe than sorry.

```nix
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # dodge "module ahci not found" error for socs.
  hardware.enableRedistributableFirmware = false;
  nixpkgs.overlays = [
      (final: super: {
      makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
  ];

  # u-boot, no grub, no efi.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # slim supported filesystems.
  boot.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];
  boot.initrd.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];

  # your shiny custom kernel.
  boot.kernelPackages = pkgs.linuxKernels.orangePiZero3;

  # opi needs the uboot image written to a specific part of the firmware.
  sdImage.postBuildCommands = ''dd if=${inputs.opiz3-nix.packages.aarch64-linux.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=8 seek=1024 conv=notrunc'';

  # this gets burned straight onto an sd. no point in zstd.
  sdImage.compressImage = false;
}
```

then you can build the sd image with `nix build .#<configuration name>.config.system.build.sdImage`.

**for use in your own package set:**
an overlay is provided as `.overlays.default`. the packages are (obviously) only for aarch64-linux.

**to ~~fix the wifi driver~~modify the kernel tree:**
a development shell roughly matching what i used to hack on this in the first place is provided as `.devShell.<system>`.

**for the defconfig**
use [`pkgs/linux/linux_sunxi64_defconfig`](./pkgs/linux/linux_sunxi64_defconfig). the vendor-provided one is short a bunch of things.

## contributing

most of the work happened in the [nixos arm matrix channel](https://matrix.to/#/#nixos-on-arm:matrix.org), so you might want to start there.

if you have a forgejo instance, or access to one, you can fork and submit patches.

## license

everything outside of `src/` is mit licensed. directories in `src/` contain their own licenses. `pkgs/linux/linux_sunxi64_defconfig` is the same license as the linux kernel.
