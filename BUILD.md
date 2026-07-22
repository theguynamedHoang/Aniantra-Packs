# How to build Annira Linux 12 (v1.0 based)

This document contains step-by-step instructions used to build the Annira Linux 12 ISO.

## 1. Prerequisites
* Debian or Ubuntu host (or Debian/Ubuntu-based distro)
* Required tools: `debootstrap`, `squashfs-tools`, `xorriso`, `grub-pc-bin`, `grub-efi-amd64-bin`

## 2. Environment Setup
Create a directory and debootstrap Debian 12 Bookworm:

```bash
mkdir -p ~/annira/rootfs
sudo debootstrap --arch=amd64 bookworm ~/annira/rootfs http://deb.debian.org/debian/
```
## 3. Chroot & PKG setup

```bash
sudo mount --bind /dev ~/annira/rootfs/dev
sudo mount -t proc proc ~/annira/rootfs/proc
sudo mount -t sysfs sys ~/annira/rootfs/sys
sudo chroot ~/annira/rootfs
```
All you need to do is...
- Install Linux Kernel & GRUB
- Install Nix Package Manager & Flatpak
- Configure hostname and create /etc/skel/Installation_Guide.txt

## 4. Packing ISO
- Create SquashFS image from rootfs using mksquashfs
- Generate bootable ISO using xorriso with GRUB configuration
