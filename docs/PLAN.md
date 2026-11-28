# PLAN giai đoạn 1

Dựa trên: `docs/SPEC.md`, duyệt giai đoạn 1, 2026-11-27.

1. `LICENSE`: GPL-2.0.
2. `kernel/series`: nhánh LTS đang theo (`6.18`).
3. `kernel/config/ubuntu-26.04.config`: cấu hình khởi đầu (Ubuntu 26.04, kernel `7.0.0-43-generic`).
4. `kernel/config/ochna.fragment`: các khoá OchnaOS ghi đè lên cấu hình khởi đầu.
5. `kernel/build.sh [bản|auto]`: tải mã kernel.org, kiểm sha256, ghép cấu hình, `make bindeb-pkg`, ra gói ở `out/`.
6. Build thử ở máy anh (tiêu chí 1), cài vào máy ảo Ubuntu 26.04 (tiêu chí 2).
7. `.github/workflows/kernel.yml`: chạy mỗi tuần và chạy tay; `check` so bản mới nhất với `kernel/status`; có bản mới thì `build`, `nvidia`, `release`; không có thì cập nhật `kernel/status`.
8. Chạy workflow bằng tay một lần, đo thời gian (tiêu chí 3 tới 5).
9. Kiểm `git ls-files` (tiêu chí 6), đối chiếu SPEC.

# PLAN giai đoạn 2

Dựa trên: `docs/SPEC.md`, duyệt giai đoạn 2, 2026-11-28.

1. Cài `mmdebstrap` ở máy anh (một lần, cần `sudo`); Ubuntu có sẵn profile AppArmor `/etc/apparmor.d/mmdebstrap` cho chế độ `unshare`.
2. `base/packages.txt`: danh sách gói.
3. `base/rootfs/`: file cấu hình chép vào image (chặn kernel Ubuntu bằng `apt` pin, tạo khoá host `ssh` lúc boot, hostname).
4. `base/build.sh`: tải kernel từ GitHub Releases (hoặc `out/`), kiểm `SHA256SUMS`, `mmdebstrap --mode=unshare` ra tar, `mkfs.ext4 -d` từ tar, ESP `mkfs.vfat` + `mcopy` (`systemd-bootx64.efi`, kernel, initrd, mục loader), ghép GPT bằng `sfdisk` + `dd`, ra `out/ochna-base.qcow2` (tiêu chí 1).
5. `base/vm-test.sh`: boot bằng OVMF, khoá `ssh` thử truyền qua credential systemd (`ssh.authorized_keys.root`, SMBIOS), kiểm tiêu chí 2 tới 5.
6. Kiểm repo và image không có khoá hay mật khẩu (tiêu chí 6), đối chiếu SPEC.
