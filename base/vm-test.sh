#!/usr/bin/env bash
# OCHNA-B2: boot out/ochna-base.qcow2 in a UEFI VM and check SPEC stage 2 criteria 2 to 5.
# Usage: base/vm-test.sh          (KEEP=1 leaves the VM running; SKIP_NVIDIA=1 skips criterion 5)
# Needs: qemu-system-x86_64, OVMF (/usr/share/OVMF/OVMF_CODE_4M.fd), ssh, /dev/kvm, ~/.ssh/id_ed25519.pub
# Test access: root SSH key passed as systemd credential ssh.authorized_keys.root, not stored in the image.
# Exit: 0 all checks pass | 1 a check failed | 2 setup problem
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
IMAGE="$ROOT/out/ochna-base.qcow2"
INFO="$ROOT/out/ochna-base.txt"
VM_DIR="${VM_DIR:-$HOME/vms/ochna33}"
DISK="$VM_DIR/base-test.qcow2"
VARS="$VM_DIR/base-OVMF_VARS.fd"
SERIAL="$VM_DIR/base-serial.log"
PORT="${PORT:-2234}"
KEY="$HOME/.ssh/id_ed25519"
OVMF_CODE=/usr/share/OVMF/OVMF_CODE_4M.fd
OVMF_VARS=/usr/share/OVMF/OVMF_VARS_4M.fd
SSH=(ssh -q -i "$KEY" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 root@127.0.0.1)

die() { echo "base/vm-test: $1" >&2; exit "${2:-1}"; }
log() { echo "base/vm-test: $*"; }

[ -f "$IMAGE" ] && [ -f "$INFO" ] || die "run base/build.sh first" 2
[ -r /dev/kvm ] && [ -w /dev/kvm ] || die "no access to /dev/kvm" 2
[ -f "$OVMF_CODE" ] && [ -f "$OVMF_VARS" ] || die "OVMF not found" 2
[ -f "$KEY.pub" ] || die "missing $KEY.pub" 2
KREL="$(sed -n 's/^kernel=//p' "$INFO")"
mkdir -p "$VM_DIR"

# OCHNA-B2: fresh overlay disk and UEFI variables each run
rm -f "$DISK" "$VARS" "$SERIAL" "$VM_DIR/base-qemu.pid"
qemu-img create -q -f qcow2 -F qcow2 -b "$IMAGE" "$DISK"
cp "$OVMF_VARS" "$VARS"
qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 4 -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$VARS" \
    -drive file="$DISK",if=virtio \
    -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:"$PORT"-:22 \
    -smbios type=11,value="io.systemd.credential:ssh.authorized_keys.root=$(cat "$KEY.pub")" \
    -display none -serial file:"$SERIAL" \
    -daemonize -pidfile "$VM_DIR/base-qemu.pid"
stop_vm() { [ -f "$VM_DIR/base-qemu.pid" ] && kill "$(cat "$VM_DIR/base-qemu.pid")" 2>/dev/null || true; }
[ "${KEEP:-0}" = 1 ] || trap stop_vm EXIT

up=0
for _ in $(seq 1 90); do
    if "${SSH[@]}" true 2>/dev/null; then up=1; break; fi
    sleep 4
done
[ "$up" = 1 ] || die "ssh not up after 360 s, see $SERIAL"

fail=0
check() {
    if "${SSH[@]}" "$2" >/dev/null 2>&1; then log "PASS $1"; else log "FAIL $1"; fail=1; fi
}
# OCHNA-B2: criterion 2
check "uname -r is $KREL" "[ \"\$(uname -r)\" = '$KREL' ]"
check "booted by systemd-boot (LoaderInfo EFI variable)" "ls /sys/firmware/efi/efivars/LoaderInfo-*"
if grep -q 'login:' "$SERIAL"; then log "PASS serial console login prompt"; else log "FAIL serial console login prompt"; fail=1; fi
# OCHNA-B2: criterion 3
check "NetworkManager connected" "[ \"\$(nmcli -t -f STATE general)\" = connected ]"
check "network (https kernel.org)" "curl -fsI --max-time 20 https://www.kernel.org"
check "disk write and read 256 MiB" "dd if=/dev/urandom of=/root/t bs=1M count=256 status=none && sync && sha256sum /root/t && rm /root/t"
# OCHNA-B2: criterion 4
check "apt update and upgrade" "DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq"
check "no Ubuntu kernel installed" "! dpkg-query -W -f '\${Package}\n' 'linux-image-*' | grep -v -- '-ochna\$'"
check "Ubuntu kernel cannot be installed" "! apt-get -s install linux-generic"
# OCHNA-B2: criterion 5
if [ "${SKIP_NVIDIA:-0}" != 1 ]; then
    check "nvidia-dkms-580 builds for $KREL" "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends nvidia-dkms-580 && dkms status | grep -q 'nvidia.*$KREL.*installed'"
fi
log "dmesg err/crit lines: $("${SSH[@]}" 'dmesg --level=err,crit,alert,emerg | wc -l')"
"${SSH[@]}" 'dmesg --level=err,crit,alert,emerg' | head -n 20 || true
[ "$fail" = 0 ] && log "all checks passed" || log "some checks failed"
exit "$fail"
