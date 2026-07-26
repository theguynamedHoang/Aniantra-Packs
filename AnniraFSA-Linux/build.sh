#!/bin/bash
# ==========================================
# |       AnniraFSA Build Scripts          |
# ==========================================

set -e

# 1. Install tools
echo "[1/6] Cài đặt build tools..."
sudo apt update && sudo apt install -y debootstrap systemd-container xorriso grub-pc-bin squashfs-tools

# 2. Create a folder & Bootstrap Debian
echo "[2/6] Debootstrap Debian Bookworm..."
mkdir -p ~/annira
sudo debootstrap --arch=amd64 bookworm ~/annira http://deb.debian.org/debian/

# 3. Mount & Config Chroot
echo "[3/6] Cấu hình hệ thống bên trong Chroot..."
sudo mount --bind /dev ~/annira/dev
sudo mount --bind /dev/pts ~/annira/dev/pts
sudo mount --bind /proc ~/annira/proc
sudo mount --bind /sys ~/annira/sys

# Install PKGs (Nix, Flatpak, Kernel, v.v...)
# LƯU Ý: Bro thêm các lệnh cài Nix/Flatpak của bro vào đoạn này
sudo chroot ~/annira /bin/bash -c "
  apt update
  apt install -y linux-image-amd64 live-boot systemd-sysv flatpak
  # Cài đặt Nix Package Manager
  # ...
"

# 4. Umount
echo "[4/6] Dọn dẹp mount points..."
sudo umount -lf ~/annira/dev/pts || true
sudo umount -lf ~/annira/dev || true
sudo umount -lf ~/annira/proc || true
sudo umount -lf ~/annira/sys || true

# 5. Live Filesystem (SquashFS)
echo "[5/6] Đóng gói SquashFS..."
mkdir -p ~/annira-iso/live
sudo rm -f ~/annira-iso/live/filesystem.squashfs
sudo mksquashfs ~/annira ~/annira-iso/live/filesystem.squashfs -e boot

# Copy Kernel & Initrd ra cây thư mục ISO
cp ~/annira/boot/vmlinuz-* ~/annira-iso/live/vmlinuz
cp ~/annira/boot/initrd.img-* ~/annira-iso/live/initrd.img

# 6. Config GRUB Bootloader & Tạo ISO
echo "[6/6] Tạo GRUB config và Đóng gói ISO..."
mkdir -p ~/annira-iso/boot/grub
cat << 'EOF' > ~/annira-iso/boot/grub/grub.cfg
menuentry "Annira OS 12 (Live)" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd.img
}
EOF

grub-mkrescue -o annira-12-amd64.iso ~/annira-iso/
sha256sum annira-12-amd64.iso > SHA256SUMS

echo "Everything is done."
