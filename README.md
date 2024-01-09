kernel source and uboot configuration for linux 6.1.31 for the orange pi zero 3.

## disclaimers

* the nix expressions are probably pretty bad. they work, but i have no doubt they aren't idiomatic.
* this requires [ifd](https://nixos.org/manual/nix/unstable/language/import-from-derivation).

## layout

```
└───packages
    └───aarch64-linux
        ├───firmwareOrangePiZero3: package 'uwe5622-firmware-6.1.31-sun50iw9'
        ├───linuxOrangePiZero3: package 'linux-6.1.31-sun50iw9'
        └───ubootOrangePiZero3: package 'uboot-orangepi_zero3_defconfig-2021.07-sunxi'
```

## sources

* kernel tree: https://github.com/orangepi-xunlong/linux-orangepi/commit/3495b5ee0594566c9fed930b96b1cae90600412e
* uboot tree: https://github.com/orangepi-xunlong/u-boot-orangepi/commit/6fe17fac388aad17490cf386578b7532975e567f

## usage

**for your own orange pi zero 3:**
here's a snapshot of my own configuration, which should be a good starting point. some of the options are probably redundant, but i'd rather be safe than sorry.

```nix
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # dodge "module <x> not found" error for socs.
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
  boot.kernelPackages = pkgs.orangePiZero3; # however you get the package here is up to you - overlay or directly from the flake.

  # opi needs the uboot image written to a specific part of the firmware.
  sdImage.postBuildCommands = ''dd if=${inputs.opiz3-nix.packages.aarch64-linux.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=8 seek=1024 conv=notrunc'';

  # this gets burned straight onto an sd. no point in zstd.
  sdImage.compressImage = false;
}
```

then you can build the sd image with `nix build .#<configuration name>.config.system.build.sdImage`.

**for the defconfig**
use [`pkgs/linux/sun50iw9_defconfig`](./pkgs/linux/sun50iw9_defconfig). the vendor-provided one is short a bunch of things.

## contributing

if you have a forgejo instance, or access to one, you can fork and submit patches. i personally recommend [codeberg](https://codeberg.org) if you aren't hosting your own.

## license

everything outside of `src/` is agpl licensed except the defconfig.

`pkgs/linux/sun50iw9_defconfig` is the same license as the linux kernel.

directories in `src/` contain their own licenses, as they are verbatim copies of the upstream sources.
