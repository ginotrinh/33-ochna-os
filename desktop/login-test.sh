#!/usr/bin/env bash
# OCHNA-D6: boot the desktop image with display, create a test user over SSH, log in through the greeter, save screenshots.
# Usage: desktop/login-test.sh   (needs out/ochna-base.qcow2 built with the desktop, OVMF, KVM, python3-pil)
# Output: build/greeter-user.png, build/desktop-first.png, session and process list on stdout
set -uo pipefail
R=/home/gino/Desktop/projects/33-ochna-os
V=$HOME/vms/ochna33
KEY=$HOME/.ssh/id_ed25519
PW="ochna-test-$(date +%s)"
mon() { printf '%s\n' "$@" | python3 -c "
import socket, sys, time
s = socket.socket(socket.AF_UNIX); s.connect(sys.argv[1]); time.sleep(0.3)
for line in sys.stdin.read().splitlines():
    s.sendall((line + '\n').encode()); time.sleep(0.15)
time.sleep(1); s.close()" "$V/shot.sock"; }
shot() { mon "screendump $V/$1.ppm"; sleep 2; python3 -c "
from PIL import Image; import sys; Image.open(sys.argv[1]).save(sys.argv[2])" "$V/$1.ppm" "$R/build/$1.png"; echo "saved build/$1.png"; }
SSH=(ssh -q -i "$KEY" -p 2235 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 root@127.0.0.1)

rm -f "$V/shot.qcow2" "$V/shot-vars.fd" "$V/shot.sock" "$V/shot.pid"
qemu-img create -q -f qcow2 -F qcow2 -b "$R/out/ochna-base.qcow2" "$V/shot.qcow2"
cp /usr/share/OVMF/OVMF_VARS_4M.fd "$V/shot-vars.fd"
qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 4 -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
    -drive if=pflash,format=raw,file="$V/shot-vars.fd" \
    -drive file="$V/shot.qcow2",if=virtio \
    -device virtio-vga -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2235-:22 \
    -smbios type=11,value="io.systemd.credential:ssh.authorized_keys.root=$(cat "$KEY.pub")" \
    -display none -monitor unix:"$V/shot.sock",server,nowait \
    -daemonize -pidfile "$V/shot.pid"
for _ in $(seq 1 60); do "${SSH[@]}" true 2>/dev/null && break; sleep 3; done
echo "pam_env locale errors this boot: $("${SSH[@]}" 'journalctl -b | grep -c "Unable to open env file: /etc/default/locale"')"
"${SSH[@]}" "useradd -m -s /bin/bash -G sudo,video,audio,render ochna && echo 'ochna:$PW' | chpasswd && systemctl restart cosmic-greeter"
sleep 25
shot greeter-user
# type the password: one sendkey per character, then Enter
keys="$(python3 -c "
import sys
m = {'-': 'minus'}
print('\n'.join('sendkey ' + m.get(c, c) for c in sys.argv[1]))" "$PW")"
mon "$keys" "sendkey ret"
sleep 40
shot desktop-first
"${SSH[@]}" 'loginctl list-sessions --no-legend; pgrep -a cosmic | awk "{print \$2}" | sort -u | xargs' 2>&1
kill "$(cat "$V/shot.pid")"
