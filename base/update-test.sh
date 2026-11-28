#!/usr/bin/env bash
# OCHNA-U4: test kernel updates on the ESP (SPEC 4a criteria 1 to 3) in the base image VM.
# Usage: KEEP=1 SKIP_NVIDIA=1 base/vm-test.sh && base/update-test.sh <new-version>
#   The image must run an older OchnaOS kernel; <new-version> must have a GitHub Release (e.g. 6.18.65).
# Exit: 0 all checks pass | 1 a check failed | 2 setup problem
set -euo pipefail

NEW="${1:?usage: base/update-test.sh <new-version>}"
NEW_KREL="$NEW-ochna"
REPO="ginotrinh/33-ochna-os"
PORT="${PORT:-2234}"
VM_DIR="${VM_DIR:-$HOME/vms/ochna33}"
KEY="$HOME/.ssh/id_ed25519"
SSH=(ssh -q -i "$KEY" -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 root@127.0.0.1)

log() { echo "base/update-test: $*"; }
die() { log "$1"; exit "${2:-1}"; }
run() { "${SSH[@]}" "$@"; }
wait_down_up() {
    sleep 15
    for _ in $(seq 1 90); do run true 2>/dev/null && return 0; sleep 4; done
    die "ssh not back after reboot"
}

fail=0
check() { if run "$2" >/dev/null 2>&1; then log "PASS $1"; else log "FAIL $1"; fail=1; fi; }

run true 2>/dev/null || die "VM not reachable on port $PORT; start it with KEEP=1 base/vm-test.sh" 2
OLD_KREL="$(run uname -r)"
log "running $OLD_KREL, installing $NEW_KREL"
[ "$OLD_KREL" != "$NEW_KREL" ] || die "VM already runs $NEW_KREL" 2

# OCHNA-U4: install the new kernel from its Release with apt
run "set -e; cd /tmp; base=https://github.com/$REPO/releases/download/v$NEW_KREL
    curl -fsSL -o SHA256SUMS \$base/SHA256SUMS
    for f in \$(awk '{sub(/^\\.\\//, \"\", \$2); print \$2}' SHA256SUMS); do curl -fsSL -o \$f \$base/\$f; done
    sha256sum -c SHA256SUMS
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ./linux-image-${NEW_KREL}_*.deb ./linux-headers-${NEW_KREL}_*.deb" >/dev/null
check "ESP has entries for $OLD_KREL and $NEW_KREL" "[ -f /boot/efi/loader/entries/ochna-$OLD_KREL.conf ] && [ -f /boot/efi/loader/entries/ochna-$NEW_KREL.conf ]"
check "default entry is $NEW_KREL" "grep -qx 'default ochna-$NEW_KREL.conf' /boot/efi/loader/loader.conf"

# OCHNA-U4: criterion 1, reboot into the new kernel
run "systemctl reboot" || true
wait_down_up
check "booted $NEW_KREL after update" "[ \"\$(uname -r)\" = '$NEW_KREL' ]"

# OCHNA-U4: criterion 2, the old kernel still boots when chosen
run "systemctl reboot --boot-loader-entry=ochna-$OLD_KREL.conf" || true
wait_down_up
check "old kernel $OLD_KREL boots when chosen" "[ \"\$(uname -r)\" = '$OLD_KREL' ]"
run "systemctl reboot" || true
wait_down_up
check "default boot returns to $NEW_KREL" "[ \"\$(uname -r)\" = '$NEW_KREL' ]"

# OCHNA-U4: criterion 3, removing a kernel removes its entry and files
run "DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq linux-image-$OLD_KREL linux-headers-$OLD_KREL" >/dev/null
check "entry and files of $OLD_KREL removed" "[ ! -e /boot/efi/loader/entries/ochna-$OLD_KREL.conf ] && [ ! -e /boot/efi/ochna/$OLD_KREL ]"
log "ESP use: $(run "df -m --output=used,size /boot/efi | tail -n1")  per kernel MiB: $(run "du -sm /boot/efi/ochna/$NEW_KREL | cut -f1")"
[ "$fail" = 0 ] && log "all checks passed" || log "some checks failed"
exit "$fail"
