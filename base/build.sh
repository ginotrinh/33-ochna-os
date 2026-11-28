#!/usr/bin/env bash
# OCHNA-B1: build the OchnaOS base disk image (UEFI, GPT, systemd-boot) without root.
# Usage: base/build.sh            KERNEL_DIR=out base/build.sh   (use local kernel debs)
# Needs: mmdebstrap (unshare mode), mkfs.ext4 >= 1.47.1, mkfs.vfat, mtools, sfdisk, qemu-img, curl
# Output: out/ochna-base.qcow2, out/ochna-base.txt (kernel, sizes, build time)
# Exit: 0 built | 1 build or check failure | 2 missing tool
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
OUT="$ROOT/out"
WORK="$ROOT/build/base"
REPO="ginotrinh/33-ochna-os"
SUITE=resolute
MIRROR=http://archive.ubuntu.com/ubuntu
COMPONENTS="main restricted universe multiverse"
ROOT_SIZE="${ROOT_SIZE:-6G}"
ESP_MIB=512
START="$(date +%s)"

die() { echo "base/build.sh: $1" >&2; exit "${2:-1}"; }
log() { echo "base/build.sh: $*"; }

for t in mmdebstrap mkfs.ext4 mkfs.vfat mmd mcopy sfdisk qemu-img curl sha256sum python3; do
    command -v "$t" >/dev/null || die "missing tool: $t" 2
done

rm -rf "$WORK"
mkdir -p "$WORK/kernel" "$OUT"

# OCHNA-B1: kernel packages from GitHub Releases, or KERNEL_DIR
if [ -n "${KERNEL_DIR:-}" ]; then
    cp "$KERNEL_DIR"/linux-image-*-ochna_*.deb "$KERNEL_DIR"/linux-headers-*-ochna_*.deb "$KERNEL_DIR"/SHA256SUMS "$WORK/kernel/"
else
    curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | python3 -c "
import json, sys
for a in json.load(sys.stdin)['assets']:
    print(a['browser_download_url'])" | while read -r url; do
        curl -fsSL -o "$WORK/kernel/${url##*/}" "$url"
    done
fi
(cd "$WORK/kernel" && sha256sum -c SHA256SUMS) || die "kernel checksum mismatch"
IMAGE_DEB="$(ls "$WORK"/kernel/linux-image-*-ochna_*.deb | head -n1)"
HEADERS_DEB="$(ls "$WORK"/kernel/linux-headers-*-ochna_*.deb | head -n1)"
KREL="$(basename "$IMAGE_DEB" | sed -n 's/^linux-image-\(.*-ochna\)_.*/\1/p')"
[ -n "$KREL" ] || die "cannot read kernel release from $IMAGE_DEB"
log "kernel $KREL"

# OCHNA-B1: root filesystem as a tar, built in a user namespace
PKGS="$(grep -vE '^\s*(#|$)' "$HERE/packages.txt" | paste -sd, -)"
mmdebstrap --mode=unshare --variant=apt --format=tar \
    --include="$PKGS" \
    --aptopt='APT::Install-Recommends "false"' \
    --setup-hook='mkdir -p "$1/etc/apt/preferences.d"' \
    --setup-hook="copy-in $HERE/rootfs/etc/apt/preferences.d/ochna-kernel /etc/apt/preferences.d" \
    --customize-hook="copy-in $IMAGE_DEB $HEADERS_DEB /tmp" \
    --customize-hook='chroot "$1" sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/linux-*.deb && rm -f /tmp/linux-*.deb"' \
    --customize-hook="sync-in $HERE/rootfs /" \
    --customize-hook='mkdir -p "$1/boot/efi"' \
    --customize-hook='chroot "$1" systemctl enable ochna-ssh-hostkeys.service NetworkManager.service' \
    --customize-hook='rm -f "$1"/etc/ssh/ssh_host_*' \
    --customize-hook="download /boot/vmlinuz-$KREL $WORK/vmlinuz" \
    --customize-hook="download /boot/initrd.img-$KREL $WORK/initrd.img" \
    --customize-hook="download /usr/lib/systemd/boot/efi/systemd-bootx64.efi $WORK/systemd-bootx64.efi" \
    "$SUITE" "$WORK/rootfs.tar" \
    "deb $MIRROR $SUITE $COMPONENTS" \
    "deb $MIRROR $SUITE-updates $COMPONENTS" \
    "deb http://security.ubuntu.com/ubuntu $SUITE-security $COMPONENTS"

# OCHNA-B1: no keys or passwords in the image
if tar -tf "$WORK/rootfs.tar" | grep -qE 'etc/ssh/ssh_host_'; then die "SSH host keys left in image"; fi
ROOT_PW="$(tar -xOf "$WORK/rootfs.tar" ./etc/shadow | awk -F: '$1=="root"{print $2}')"
case "$ROOT_PW" in '*'*|'!'*) ;; *) die "root has a password in the image" ;; esac
if tar -tf "$WORK/rootfs.tar" | grep -E '(^|/)\.ssh/authorized_keys$'; then die "authorized_keys left in image"; fi

# OCHNA-B1: EFI system partition with systemd-boot and the kernel
ESP="$WORK/esp.img"
truncate -s "${ESP_MIB}M" "$ESP"
mkfs.vfat -F 32 -n OCHNA-ESP "$ESP" >/dev/null
mmd -i "$ESP" ::/EFI ::/EFI/BOOT ::/loader ::/loader/entries ::/ochna
mcopy -i "$ESP" "$WORK/systemd-bootx64.efi" ::/EFI/BOOT/BOOTX64.EFI
mcopy -i "$ESP" "$WORK/vmlinuz" ::/ochna/vmlinuz
mcopy -i "$ESP" "$WORK/initrd.img" ::/ochna/initrd.img
printf 'default ochna.conf\ntimeout 3\n' > "$WORK/loader.conf"
printf 'title OchnaOS\nlinux /ochna/vmlinuz\ninitrd /ochna/initrd.img\noptions root=LABEL=ochna-root rw console=tty0 console=ttyS0,115200\n' > "$WORK/ochna.conf"
mcopy -i "$ESP" "$WORK/loader.conf" ::/loader/loader.conf
mcopy -i "$ESP" "$WORK/ochna.conf" ::/loader/entries/ochna.conf

# OCHNA-B1: root partition filled from the tar, ownership kept
truncate -s "$ROOT_SIZE" "$WORK/root.img"
mkfs.ext4 -q -L ochna-root -d "$WORK/rootfs.tar" "$WORK/root.img"

# OCHNA-B1: GPT disk: ESP then x86-64 root
ROOT_BYTES="$(stat -c %s "$WORK/root.img")"
DISK="$WORK/disk.raw"
truncate -s $(( (1 + ESP_MIB + 1) * 1024 * 1024 + ROOT_BYTES )) "$DISK"
printf 'label: gpt\nstart=1MiB, size=%sMiB, type=U, name="esp"\nstart=%sMiB, size=%s, type=4f68bce3-e8cd-4db1-96e7-fbcaf984b709, name="root"\n' \
    "$ESP_MIB" "$(( 1 + ESP_MIB ))" "$(( ROOT_BYTES / 512 ))" | sfdisk -q "$DISK"
dd if="$ESP" of="$DISK" bs=1M seek=1 conv=notrunc status=none
dd if="$WORK/root.img" of="$DISK" bs=1M seek=$(( 1 + ESP_MIB )) conv=notrunc status=none
qemu-img convert -O qcow2 "$DISK" "$OUT/ochna-base.qcow2"

END="$(date +%s)"
{
    echo "kernel=$KREL"
    echo "build_seconds=$(( END - START ))"
    echo "rootfs_tar_bytes=$(stat -c %s "$WORK/rootfs.tar")"
    echo "qcow2_bytes=$(stat -c %s "$OUT/ochna-base.qcow2")"
    echo "packages_installed=$(tar -xOf "$WORK/rootfs.tar" ./var/lib/dpkg/status | grep -c '^Package: ')"
} > "$OUT/ochna-base.txt"
log "done"
cat "$OUT/ochna-base.txt"
