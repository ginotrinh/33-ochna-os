#!/usr/bin/env bash
# OCHNA-K4: boot out/*.deb in an Ubuntu 26.04 cloud-image VM and check it.
# Usage: kernel/vm-test.sh            (KEEP=1 leaves the VM running)
# Needs: qemu-system-x86_64, qemu-img, genisoimage, ssh, /dev/kvm, ~/.ssh/id_ed25519.pub
# Base image: $VM_DIR/ubuntu-26.04-server-cloudimg-amd64.img
# Exit: 0 all checks pass | 1 a check failed | 2 setup problem
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
OUT="$ROOT/out"
VM_DIR="${VM_DIR:-$HOME/vms/ochna33}"
BASE="$VM_DIR/ubuntu-26.04-server-cloudimg-amd64.img"
DISK="$VM_DIR/test.qcow2"
SEED="$VM_DIR/seed.iso"
PORT="${PORT:-2233}"
KEY="$HOME/.ssh/id_ed25519"
SSH=(ssh -q -i "$KEY" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 ubuntu@127.0.0.1)

die() { echo "vm-test: $1" >&2; exit "${2:-1}"; }
log() { echo "vm-test: $*"; }

[ -f "$BASE" ] || die "missing base image $BASE" 2
[ -r /dev/kvm ] && [ -w /dev/kvm ] || die "no access to /dev/kvm" 2
[ -f "$KEY.pub" ] || die "missing $KEY.pub" 2
IMAGE="$(ls "$OUT"/linux-image-*-ochna_*.deb 2>/dev/null | head -n1)"
HEADERS="$(ls "$OUT"/linux-headers-*-ochna_*.deb 2>/dev/null | head -n1)"
[ -n "$IMAGE" ] && [ -n "$HEADERS" ] || die "no packages in $OUT, run kernel/build.sh first" 2
KREL="$(basename "$IMAGE" | sed -n 's/^linux-image-\(.*-ochna\)_.*/\1/p')"
log "kernel $KREL"

# OCHNA-K4: fresh overlay disk and cloud-init seed each run
rm -f "$DISK" "$SEED" "$VM_DIR/qemu.pid"
qemu-img create -q -f qcow2 -F qcow2 -b "$BASE" "$DISK" 16G
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
printf 'instance-id: ochna-test\nlocal-hostname: ochna-test\n' > "$TMP/meta-data"
{
    echo "#cloud-config"
    echo "users:"
    echo "  - name: ubuntu"
    echo "    sudo: ALL=(ALL) NOPASSWD:ALL"
    echo "    shell: /bin/bash"
    echo "    ssh_authorized_keys:"
    echo "      - $(cat "$KEY.pub")"
} > "$TMP/user-data"
genisoimage -quiet -output "$SEED" -volid cidata -joliet -rock "$TMP/user-data" "$TMP/meta-data"

start_vm() {
    qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 4 \
        -drive file="$DISK",if=virtio -drive file="$SEED",if=virtio,media=cdrom \
        -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:"$PORT"-:22 \
        -display none -serial file:"$VM_DIR/serial.log" \
        -daemonize -pidfile "$VM_DIR/qemu.pid"
}
wait_ssh() {
    for _ in $(seq 1 90); do
        "${SSH[@]}" true 2>/dev/null && return 0
        sleep 4
    done
    die "ssh not up after 360 s, see $VM_DIR/serial.log"
}
stop_vm() {
    [ -f "$VM_DIR/qemu.pid" ] && kill "$(cat "$VM_DIR/qemu.pid")" 2>/dev/null || true
}
[ "${KEEP:-0}" = 1 ] || trap 'stop_vm; rm -rf "$TMP"' EXIT

# OCHNA-K4: first boot on the stock kernel, install packages, make ochna the default entry
start_vm
wait_ssh
log "stock kernel $("${SSH[@]}" uname -r)"
"${SSH[@]}" cloud-init status --wait >/dev/null || true
scp -q -i "$KEY" -P "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$IMAGE" "$HEADERS" ubuntu@127.0.0.1:/tmp/
"${SSH[@]}" "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq /tmp/linux-*.deb >/dev/null"
"${SSH[@]}" "echo 'GRUB_DEFAULT=\"Advanced options for Ubuntu>Ubuntu, with Linux $KREL\"' | sudo tee /etc/default/grub.d/99-ochna.cfg >/dev/null && sudo update-grub 2>/dev/null"
"${SSH[@]}" "sudo systemctl reboot" || true
sleep 10
wait_ssh

# OCHNA-K4: checks
fail=0
check() {
    if "${SSH[@]}" "$2" >/dev/null 2>&1; then log "PASS $1"; else log "FAIL $1"; fail=1; fi
}
log "running kernel $("${SSH[@]}" uname -r)"
check "uname -r is $KREL" "[ \"\$(uname -r)\" = '$KREL' ]"
check "network (https kernel.org)" "curl -fsI --max-time 20 https://www.kernel.org"
check "disk write and read 256 MiB" "dd if=/dev/urandom of=/tmp/t bs=1M count=256 status=none && sync && sha256sum /tmp/t >/dev/null && rm /tmp/t"
check "rust enabled" "grep -qx 'CONFIG_RUST=y' /boot/config-$KREL"
log "modules loaded: $("${SSH[@]}" 'lsmod | tail -n +2 | wc -l')"
log "dmesg err/crit lines: $("${SSH[@]}" 'sudo dmesg --level=err,crit,alert,emerg | wc -l')"
"${SSH[@]}" 'sudo dmesg --level=err,crit,alert,emerg' | head -n 20 || true
[ "$fail" = 0 ] && log "all checks passed" || log "some checks failed"
exit "$fail"
