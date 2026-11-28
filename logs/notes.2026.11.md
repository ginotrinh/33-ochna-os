# Ghi chú 2026-11

## 2026-11-27 · hướng đi của dự án · `docs/SPEC.md`

- Anh chốt dựng lại OchnaOS từ kernel theo hướng C, thay cho ISO dựng trên nền Pop!_OS (`32-ochna-os`, vòng 1 tới 3). Lý do: dò lỗi trong lớp desktop của Pop (nút cửa sổ app GTK, Orca tự bật) tốn nhiều công; anh muốn tự kiểm soát.
- Các hướng bị loại: Linux From Scratch (không có trình quản lý gói, vá bảo mật tay), Gentoo (build gói lớn nhiều giờ trên P50), NixOS (cách làm khác hẳn).
- Desktop mới do anh tự thiết kế; phần đã làm ở `32-ochna-os` vòng 3 mang sang khi phù hợp.
- CI chỉ build; kiểm trong máy ảo làm ở máy anh để có lỗi thì vá trước khi cài. P50 chỉ cài khi anh chạy lệnh cập nhật. Lịch CI mỗi tuần.

## 2026-11-27 · 3 câu hỏi giai đoạn 1 · `docs/SPEC.md`

- Nguồn kernel: kernel.org LTS với cấu hình khởi đầu lấy từ Ubuntu 26.04. Lý do em đề xuất: đúng nghĩa tự build kernel, còn cấu hình Ubuntu giúp phần cứng chạy ngay. Phương án bị loại: dùng mã kernel của Ubuntu.
- Phát hành: GitHub Releases ở giai đoạn 1, kho `apt` có ký ở giai đoạn 4. Lý do: giai đoạn 1 chưa cần ký kho bằng GPG.
- Tuần không có bản vá mới: bỏ build, ghi file trạng thái. Lý do: repo công khai 60 ngày không hoạt động thì GitHub tự tắt lịch chạy.
- Anh duyệt giai đoạn 1 cùng ngày, kèm yêu cầu rút gọn SPEC.

## 2026-11-27 · giới hạn GitHub Actions · CI

Đọc trên docs.github.com, 2026-11-27:
- Repo công khai: runner chuẩn "free and unlimited"; Linux 4 CPU, 16 GB RAM, 14 GB SSD.
- Repo riêng tư (gói Free): 12 USD mỗi tháng (khoảng 2000 phút Linux, em tự chia, tài liệu không ghi số phút); Linux 2 CPU, 8 GB RAM, 14 GB SSD; 500 MB lưu artifact.
- Mỗi job tối đa 6 giờ; lịch chạy ngắn nhất 5 phút; repo công khai 60 ngày không hoạt động thì lịch chạy tự tắt.
- ISO (khoảng 30 GiB chỗ build ở vòng 2, ước tính) không vừa 14 GB SSD: ISO build ở máy anh.

## 2026-11-27 · tra dự án mã nguồn mở (luật 29 của gaos) · CI

Tra bằng `gh search repos` (`bindeb-pkg`, `kernel build actions deb`, `custom kernel ubuntu workflow`) và đọc workflow:
- `damentz/liquorix-package` (356 sao, GPL-2.0): `build-test.yml` chỉ chạy tay ("Kernel builds take too long for every push, Jenkins builds the releases"); bước đầu dọn đĩa (`mathio/gha-cleanup`); build theo ma trận bản Debian và Ubuntu; ký gói GPG. Ý mượn: dọn đĩa trước khi build, ma trận theo bản Ubuntu, ký gói.
- `EmbeddedAndroid/kbuild-deb` (1 sao): Action đóng gói bằng `make bindeb-pkg`; quá ít người dùng để dựa vào.
- `pop-os/linux`, `zen-kernel/zen-kernel`: không có `.github/workflows` công khai.
- Kết luận: chưa thấy dự án lớn build kernel mỗi tuần hoàn toàn trên runner miễn phí của GitHub; thời gian build trên máy 4 CPU phải đo (tiêu chí 4).

## 2026-11-27 · luật viết file của repo · `CLAUDE.md`

- Anh đặt luật: file trong repo chỉ chứa nội dung hiện hành, câu ngắn, không diễn giải, không lý do; diễn giải và lý do ghi vào `logs/`. Đã rút gọn `CLAUDE.md`, `docs/SPEC.md`, `HANDOFF.md`, `.gitignore`, `kernel/README.md`; phần diễn giải chuyển vào file này.
- License: repo công khai chưa có license nên người khác chỉ xem được; chọn khi biết repo chứa gì (kernel GPL-2.0; WhiteSur, apple_cursor GPL-3.0 nếu mang sang).

## 2026-11-27 · comment trong mã · `CLAUDE.md` luật 10

- Luật 1 (không nêu lý do) đụng khuôn comment 4 dòng ticket, BUG, FIX, WHY trong luật chung của anh. Anh chọn: comment trong mã chỉ giữ ticket ID và mô tả ngắn; BUG, FIX, WHY ghi ở file này kèm ticket ID, để tra ngược từ mã sang lý do.

## 2026-11-27 · license · `LICENSE`

- Anh chọn GPL-2.0 cho cả repo. Không license nào chặn được việc xem hay clone repo công khai (điều khoản GitHub cho phép xem và fork); license chỉ quyết người khác được dùng lại thế nào. GPL-2.0 khớp với kernel, phần chiếm nhiều nhất của repo.

## 2026-11-27 · OCHNA-K1 · `kernel/build.sh`, `kernel/config/`

- Nhánh kernel: 6.18 longterm, bản mới nhất là 6.18.65 (kernel.org `releases.json`, đọc 2026-11-27). Ubuntu 26.04 chạy 7.0; 6.18 cũ hơn một nhánh lớn nhưng được vá dài hạn. Muốn theo nhánh mới hơn thì sửa `kernel/series`.
- Cấu hình khởi đầu: `/boot/config-7.0.0-43-generic` của máy anh. Ghép sang 6.18 bằng `merge_config.sh` rồi `make olddefconfig`: khoá không có trong 6.18 bị bỏ, khoá mới lấy mặc định.
- `SYSTEM_TRUSTED_KEYS`, `SYSTEM_REVOCATION_KEYS` để rỗng: cấu hình Ubuntu trỏ tới `debian/canonical-certs.pem`, file chỉ có trong mã kernel của Ubuntu, build mã kernel.org sẽ lỗi.
- Tắt `DEBUG_INFO`, BTF: giảm dung lượng build và gói, vừa ổ 14 GB của runner (ước tính, chưa đo). Hệ quả: công cụ eBPF cần BTF (bpftrace với kiểu dữ liệu kernel) không chạy được.
- Ký module giữ bật, khoá ký sinh mới mỗi lần build (`certs/signing_key.pem`, không vào git). `MODULE_SIG_FORCE` tắt, nên module DKMS không ký (NVIDIA) vẫn nạp được, kernel đánh dấu tainted.
- Kiểm tarball bằng `sha256sums.asc` của kernel.org; chưa kiểm chữ ký GPG của file đó.

## 2026-11-27 · OCHNA-K2 · `.github/workflows/kernel.yml`

- Build trong container `ubuntu:26.04` để trình biên dịch khớp với nền Ubuntu 26.04; runner chỉ có `ubuntu-24.04`.
- Dọn đĩa runner bằng `rm` trực tiếp thay cho action ngoài (ý từ `damentz/liquorix-package`).
- NVIDIA: P50 dùng Quadro M1000M (Maxwell), driver mở `-open` cần Turing trở lên, nên test `nvidia-dkms-580` bản đóng. Bước cài `|| true` vì postinst gọi DKMS cho kernel của runner và lỗi; `dkms build` ngay sau đó mới là phép thử.
- Tuần không có bản mới: job `check` ghi ngày vào `kernel/status` rồi commit, để repo có hoạt động (GitHub tắt lịch sau 60 ngày không hoạt động).
- Chưa chạy thật: thời gian build trên runner 4 CPU, dung lượng đĩa, việc `nvidia-dkms-580` có trong kho mặc định của image `ubuntu:26.04`.
- Sửa sau review: `build.sh` kiểm thêm `DEBUG_INFO_NONE=y` và BTF tắt sau `olddefconfig` (cấu hình lệch thì dừng sớm, không để CI build kèm debug info rồi hết đĩa); bước ghi ngày bỏ qua khi không đổi gì (chạy lại cùng ngày không lỗi); hai bước push rebase trước (job release push sau vài giờ, main có thể đã có commit mới); thêm `libdw-dev`, `gawk` theo `Build-Depends-Arch` của `scripts/package/mkdebian` bản 6.18.65.
- Đã chạy ở máy anh: tải và kiểm sha256 6.18.65 đạt; `merge_config.sh` ra `DEBUG_INFO_NONE=y`, BTF tắt. Chưa chạy `olddefconfig` và build vì máy thiếu `bison flex libssl-dev libelf-dev libdw-dev dwarves gawk debhelper`.

## 2026-11-27 · OCHNA-K3 · `kernel/config/ochna.fragment`, `kernel/build.sh`

- Anh chốt: driver và giao diện mới viết bằng Rust. Lõi kernel vẫn là C (cần gcc); Rust chỉ dùng cho module, gọi sang C qua lớp abstractions và bindgen.
- Giữ `CONFIG_RUST=y` và cài toolchain (`rustc` 1.93.1, `rust-src`, `bindgen` 0.72.1, `libclang-dev`, kho Ubuntu 26.04), vì thiếu `rustc` thì `olddefconfig` âm thầm tắt Rust; `build.sh` dừng nếu `CONFIG_RUST=y` không còn.
- Driver Rust có sẵn trong 6.18.65: `nova-core`, `nova` (NVIDIA có GSP, Turing trở lên, em suy luận chưa kiểm), `tyr` (Arm Mali), binder Android, `rnull`, PHY, firmware loader. Phần cứng P50 (Intel HD 530, Quadro M1000M Maxwell, iwlwifi, NVMe) đều dùng driver C.
- Module Rust ngoài cây kernel phải build bằng đúng bản `rustc` đã build kernel; máy anh và CI cùng lấy `rustc` từ kho Ubuntu 26.04.

## 2026-11-27 · ưu tiên Rust · `CLAUDE.md` luật 11

- Anh chốt: ưu tiên Rust cho mã mới, chỉ sang C khi Rust không làm được (vd lõi kernel, driver chưa có abstractions Rust).
- Anh chốt: chưa push; push khi kernel boot được và chạy ổn trong VM, vì push là bật lịch CI và đăng Release công khai.
- Build lần 1 dừng ở bước kiểm: `olddefconfig` tắt `CONFIG_RUST`. Nguyên nhân (`init/Kconfig` 6.18.65): `RUST` cần `!MODVERSIONS || GENDWARFKSYMS`, mà `GENDWARFKSYMS` cần `DEBUG_INFO`, đã tắt để tiết kiệm đĩa. Chọn tắt `MODVERSIONS` (kiểm phiên bản ký hiệu khi nạp module): module DKMS luôn build bằng headers của chính kernel này nên rủi ro thấp; phương án bị loại: bật lại debug info (build và gói lớn hơn, đĩa runner 14 GB), bỏ Rust (trái luật 11).

## 2026-11-27 · OCHNA-K4 · `kernel/vm-test.sh`

- Anh chốt: giai đoạn 1 thử kernel trên image cloud Ubuntu 26.04 (bàn thử, không phải nền OchnaOS). Lý do: chỉ kernel thay đổi, boot lỗi thì khoanh ngay vào kernel. Giai đoạn 2 đổi sang rootfs `debootstrap` của mình.

## 2026-11-27 · OCHNA-K5 · `kernel/build.sh`

- Build lần 2 ở máy anh: 1:25:35 với 8 luồng, RAM tối đa 1.8 GB, thư mục `build/` 6.7 GB; gói image 111 MB, headers 10 MB.
- Gói ghi maintainer là user và tên máy build (`scripts/package/mkdebian` dòng 137 tới 145), `uname -v` ghi user và host. Đặt tên trung tính để Release công khai không mang tên máy; `.invalid` là tên miền dành riêng, không gửi thư được.

## 2026-11-27 · kết quả `kernel/vm-test.sh` · `docs/SPEC.md` tiêu chí 2

- 4 PASS, 46 module nạp, 8 dòng dmesg mức err: 6 dòng `I/O error, dev fd0` (QEMU giả lập ổ mềm không có đĩa, không liên quan kernel) và 2 dòng `systemd: bpf-restrict-fs: Failed to load BPF object: No such process`.
- `bpf-restrict-fs` là chương trình BPF LSM của systemd thực thi `RestrictFileSystems=`. Em suy luận (chưa kiểm) lỗi do tắt BTF: libbpf cần `/sys/kernel/btf/vmlinux`, không có thì trả `ESRCH`. Hệ quả: dịch vụ khai `RestrictFileSystems=` chạy không có lớp chặn đó. Tiêu chí 1 mới đạt nửa ở máy anh (`build.sh` exit 0, 1:25:35), còn CI.

## 2026-11-28 · OCHNA-K6 · đo build có BTF

- Build có BTF (DWARF5, BTF, BTF module, bỏ gói dbg): 1:49:07 (không BTF 1:25:35, +27%), RAM tối đa 1.9 GB, đỉnh `build/` 32.8 GB (không BTF 6.7 GB); gói image 125 MB (111), headers 11 MB (10).
- 32 GB gồm: `.o` 17 GB, `.ko` 9.4 GB, `debian/` 0.7 GB, `vmlinux` 0.45 GB; gần hết là DWARF trong file object.
- `kernel/vm-test.sh`: 4 PASS; hết 2 dòng `bpf-restrict-fs`, còn 6 dòng `fd0`. Đã kiểm: lỗi `bpf-restrict-fs` do thiếu BTF.
- 32.8 GB không vừa 14 GB SSD tài liệu GitHub ghi cho runner chuẩn.

## 2026-11-28 · OCHNA-K7 · đo build có BTF và nén zstd

- 1:46:13 (BTF không nén 1:49:07); đỉnh `build/` 22.97 GiB (BTF không nén 31.3 GiB, không BTF 6.7 GiB, cùng đơn vị GiB); gói image 125 MB, headers 11 MB, không đổi.
- Cây build: `.o` 10.9 GiB (17), `.ko` 6.0 GiB (9.4), `vmlinux` 233 MB (449). Nén chỉ giảm khoảng 27%.
- `vmlinux` có `.BTF` và `.BTF_ids` (pahole đọc được DWARF nén). `kernel/vm-test.sh`: 4 PASS, không còn `bpf-restrict-fs`.
- Vẫn quá 14 GB SSD tài liệu GitHub ghi; chưa đo dung lượng trống thật của runner.

## 2026-11-28 · OCHNA-K8 · `.github/workflows/kernel.yml`

- Anh chọn: push, tạm tắt lịch tuần, chạy tay một lần để đo đĩa thật của runner (bản build BTF + zstd cần 23 GiB ở máy anh, tài liệu GitHub ghi 14 GB). Job build in `df` trước, sau dọn đĩa, và đỉnh dùng đĩa lấy mẫu mỗi 60 giây, kể cả khi build hỏng. Lần chạy tay vẫn đăng Release nếu build và NVIDIA đạt.

## 2026-11-28 · OCHNA-K9 · lần chạy CI đầu `46056804098`

- Runner `ubuntu-24.04`: `/` 145 GB, trống 85 GB, sau dọn đĩa 110 GB; build dùng đỉnh 60234 MiB trên `/` (từ khoảng 35 GB, tức khoảng 24 GB cho build). Con số 14 GB trong tài liệu GitHub không phải dung lượng trống thật. Build 1:35:37 (máy anh 1:46:13).
- Job `nvidia` hỏng: `dkms build` exit 2, log CI không in `make.log`. Cùng gói `nvidia-dkms-580` 580.178.04 build đạt trong máy ảo chạy kernel `-ochna` (rc 0), nên lỗi nằm ở môi trường container, chưa biết thiếu gì. Sửa: in 80 dòng cuối `make.log` khi hỏng, chạy lại.

## 2026-11-28 · OCHNA-K10 · `kernel/build.sh`

- Run `46069444033`: build 2:00:04, `nvidia` hỏng vì `objtool` trong gói headers báo `libelf.so.1: cannot open shared object file`. Gói `linux-headers` do `bindeb-pkg` sinh không khai `Depends` (`scripts/package/mkdebian` 6.18.65), mà `objtool`, `sign-file` và vài công cụ khác liên kết động tới `libelf.so.1`, `libcrypto.so.3`, `libz.so.1`, `libgcc_s.so.1`, `libc.so.6` (đọc bằng `readelf -d`). Máy ảo cloud image có sẵn các thư viện đó nên build đạt; container tối giản và nền `debootstrap` tối giản thì không.
- Sửa: `build.sh` thêm `Depends: libc6, libelf1t64, libssl3t64, zlib1g, libgcc-s1` vào gói headers trước khi build (sửa `mkdebian` trong cây mã đã giải nén, có kiểm chỗ neo). Phương án bị loại: cài `libelf1t64` riêng trong bước test CI (che lỗi, nền tối giản vẫn dính).

## 2026-11-28 · run `46082094150`

- Cả 4 job đạt: build 1:25:47, đỉnh `/` 56947 MiB; nvidia build ra `nvidia.ko`; Release `v6.18.65-ochna` có 3 file; bot commit `kernel/status` (`e38a638`). Thời gian build trên runner dao động 1:25 tới 2:00 qua 3 lần chạy.

## 2026-11-28 · OCHNA-K12 · lịch tuần

- Anh duyệt bật lại lịch sau lần chạy tay đạt (`46082094150`). Lần chạy theo lịch đầu tiên: thứ Hai 2026-11-30 02:00 UTC; 6.18.65 đã có trong `kernel/status` nên nếu chưa có bản vá mới thì chỉ ghi ngày kiểm.

## 2026-11-28 · SPEC giai đoạn 2 (chờ duyệt) · `docs/SPEC.md`

- Anh chốt theo đề xuất: `mmdebstrap` 1.5.7 (không cần root, nhanh hơn `debootstrap`, sau này chạy được trên CI), `systemd-boot` 259.9 (gọn, ít cấu hình; GRUB bị loại vì nền tối giản), NetworkManager (desktop và Wi-Fi P50 ở giai đoạn 3 cần), chỉ console.
- Tiêu chí 4 (không có kernel Ubuntu): `apt` có thể kéo `linux-image-generic` qua gói meta; nền phải chặn để kernel OchnaOS không bị thay.
- Tiêu chí 5 (NVIDIA): gói headers giai đoạn 1 đã khai `Depends` (`OCHNA-K10`), image tối giản là phép thử thật cho việc đó.
- Dựng image trên CI để sang giai đoạn 4, cùng đợt đóng gói.

## 2026-11-28 · PLAN giai đoạn 2 · `docs/PLAN.md`

- Không root: `mmdebstrap --mode=unshare` (máy có `apparmor_restrict_unprivileged_userns=1`, Ubuntu cho phép riêng `/usr/bin/mmdebstrap` qua profile); `mke2fs` 1.47.2 nhận tar ở `-d` nên giữ đúng chủ sở hữu file mà không cần giải nén bằng root; ESP dựng bằng `mtools`.
- Không cài gói `systemd-boot` (postinst gọi `bootctl install`, cần ESP thật lúc dựng); chỉ lấy `systemd-boot-efi` và tự viết mục loader. Hệ quả: kernel mới cài bằng `apt` chưa tự vào ESP; việc đó để lệnh cập nhật ở giai đoạn 4.
- Không nướng khoá vào image: xoá khoá host `ssh` sau khi dựng, tạo lại lúc boot; tài khoản thử dùng credential systemd `ssh.authorized_keys.root` (`/usr/lib/tmpfiles.d/provision.conf`) truyền lúc chạy máy ảo. Đăng nhập console kiểm bằng dấu nhắc `login:` trên cổng serial và đăng nhập `ssh` bằng khoá thử.
- Firmware: Ubuntu 26.04 tách `linux-firmware` thành gói nhỏ; lấy `linux-firmware-intel-wireless` (Wi-Fi) và `linux-firmware-intel-graphics` (HD 530).

## 2026-11-28 · OCHNA-B3 · `.github/workflows/base.yml`, `docs/SPEC.md`

- Anh ở xa, máy không có `mmdebstrap` và không có `sudo` không cần mật khẩu, Tailscale đăng xuất. Anh chọn: dựng image trên GitHub Actions (container `ubuntu:26.04` chạy `--privileged`, `mmdebstrap` chế độ `root`), tải artifact về máy anh và chạy `base/vm-test.sh` (chỉ cần QEMU, KVM). SPEC đổi: thêm mục 4 "Cái gì", bỏ "dựng image trên CI" khỏi ngoài phạm vi; anh duyệt cùng ngày. Tiêu chí 1 (dựng không cần `sudo` ở máy anh) vẫn chờ anh cài `mmdebstrap`.
- Phương án bị loại: chạy `mmdebstrap` giải nén từ `.deb` ở chế độ `fakechroot` (profile AppArmor chỉ cho đường dẫn `/usr/bin/mmdebstrap` dùng user namespace; `fakechroot` hay hỏng ở maintainer script).

## 2026-11-28 · OCHNA-B4 · `base/build.sh`

- Run `46110726244` hỏng sau 23 giây: `api.github.com` trả 403 cho runner (gọi không token; em đoán do giới hạn lượt gọi dùng chung theo IP runner, chưa kiểm). Sửa: lấy bản kernel từ `kernel/status`, tải thẳng `SHA256SUMS` và các file nó liệt kê từ `releases/download/v<bản>-ochna/`; không cần API, bản tải luôn khớp bản CI đã phát hành. Đã thử đoạn tải ở máy anh: 2 file khớp sha256.
- Run `46110857840`: rootfs dựng xong trong 54.5 giây (`mmdebstrap` root mode), 3 bước kiểm khoá và mật khẩu đạt; `mkfs.ext4 -d <tar>` hỏng "you need libarchive to be able to process tarballs": `mke2fs` nạp `libarchive` lúc chạy (dlopen), gói `e2fsprogs` không kéo nó theo. Sửa: thêm `libarchive13t64` vào workflow, ghi vào dòng Needs của `build.sh`.
- Run `46111043181`: `mkfs.ext4 -d` hỏng "Pathname can't be converted from UTF-8 to current locale" (container chạy locale POSIX, rootfs có tên file UTF-8). Sửa: `build.sh` đặt `LC_ALL=C.UTF-8` (glibc luôn có sẵn locale này), áp cho mọi máy chạy script.
- Run `46111220122` đạt: dựng 79 giây, rootfs tar 1.2 GB, qcow2 1.33 GB, 205 gói. Máy ảo boot qua OVMF và `systemd-boot` vào `6.18.65-ochna`, NetworkManager chạy, khoá host ssh tạo ở lần boot đầu, serial hiện `ochna login:`; nhưng `ssh.socket` không được bật (chỉ có `sshd-unix-local.socket`), nên test không vào được. Sửa: bật `ssh.socket` trong hook `systemctl enable`.
- Run `46113114796`: `ssh.socket` bị systemd bỏ để phá vòng thứ tự `ssh.socket` → `ochna-ssh-hostkeys.service` → `basic.target` → `sockets.target` → `ssh.socket` (unit của em có `Before=ssh.socket` và phụ thuộc mặc định `After=basic.target`). Sửa: chỉ `Before=ssh.service`; socket nhận kết nối, sshd chạy khi có kết nối, lúc đó khoá đã tạo. Credential `ssh.authorized_keys.root` đã được systemd nhận (serial log).
- Run `46114942983`: ssh nhận TCP nhưng không có banner. `debugfs` trên image (không root): `ssh.socket` đã bật, Ubuntu có sẵn `sshd-keygen.service`; `/usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf` của Ubuntu đặt `unmanaged-devices=*,except:type:wifi,...` (Ubuntu giao Ethernet cho netplan), `/etc/netplan` rỗng, nên máy ảo không có địa chỉ. Sửa: file cùng tên ở `/etc/NetworkManager/conf.d/` với `unmanaged-devices=none` (file ở `/etc` che file ở `/usr/lib`).
- Run `46117066579` (dựng 71 giây, qcow2 1.33 GB, 205 gói) + `base/vm-test.sh`: 10 PASS, dmesg 0 dòng lỗi. Tiêu chí 2 tới 6 đạt; tiêu chí 1 còn chờ dựng không `sudo` ở máy anh. Chuỗi lỗi đã sửa trên đường: API 403, thiếu `libarchive`, locale, `ssh.socket` chưa bật, vòng thứ tự với `ssh.socket`, NetworkManager không quản lý Ethernet.

## 2026-11-28 · hướng giai đoạn 3, 4 · `HANDOFF.md`

- Anh muốn desktop kiểu Windows 7 glass liquid theo `gino-style.css` (token Aero: nền xanh có vệt màu, kính `blur(22px) saturate(185%)`, bóng giọt nước, viền sáng, nút kính, bo 26/20px, Roboto Condensed + Lora, sáng và tối).
- Blur cần compositor: cosmic-comp mới có bản nháp `ext-background-effect-v1` (PR 2179, tháng 3/2026, chưa thấy merge); niri 26.04 đã có blur qua cùng giao thức; GNOME 51 Mutter và Plasma 6.7 cũng có (tra web 2026-11-28, nguồn tin thứ cấp).
- Đường cập nhật kernel: kernel.org là nguồn phụ thuộc duy nhất của kernel; CI, Release, cài gói, DKMS do mình giữ; còn thiếu chép vào ESP (4a) và kho `apt` (4b, anh để sau 4a).

## 2026-11-28 · SPEC giai đoạn 3 vòng 1 và 4a (chờ duyệt văn bản)

- Anh chốt: COSMIC nhưng tên hiển thị `ochna-aero`; nút cửa sổ bên trái, tròn, màu ochna-aero; dock kiểu macOS, màu và hành vi Windows 7; icon kiểu Windows, đổi được; mặc định sáng như gino-style; theme dạng module, đặt icon hay wallpaper đúng chỗ thì hiện danh sách chọn. Duyệt hướng 4a.
- Em hiểu "hành vi Windows 7" của dock là đèn sáng app đang chạy và xem trước cửa sổ khi rê chuột; anh sửa nếu khác.
- Đổi tên chỉ ở chữ người dùng thấy; đổi tên crate và gói upstream sẽ tách khỏi bản vá của System76, mỗi lần cập nhật phải gộp tay.
- Rủi ro đã biết: nút bên trái cho app GTK là chỗ vòng 3 (`32-ochna-os`) chưa giải được (`cosmic-settings-daemon` ghi `button-layout` mỗi lần đăng nhập, bản vá đã soạn chưa build). Kính mờ phụ thuộc bản nháp `ext-background-effect-v1` của cosmic-comp.
- 4a cần bản kernel thứ hai để thử: chạy tay workflow `kernel` với `version` là bản 6.18.y khác.
- Anh duyệt SPEC giai đoạn 3 vòng 1 và 4a, bỏ phần xem trước cửa sổ của dock.
- Gói System76: image nền hiện không có gói nào của System76 (toàn kho Ubuntu cộng kernel OchnaOS). Desktop sẽ dựa trên mã COSMIC ở `github.com/pop-os` (cosmic-comp, cosmic-panel, cosmic-settings, cosmic-greeter, cosmic-session, libcosmic và các app), Ubuntu 26.04 không có trong kho; mình tự build từ mã nguồn như vòng 3 đã build 8 gói. Phụ thuộc còn lại: mã nguồn và nhịp phát hành của System76, không phụ thuộc kho `apt` của họ.
- Giấy phép: phần lớn mã COSMIC là GPL-3.0; bản vá cho mã đó phải theo GPL-3.0, khác GPL-2.0 của repo; cần anh chốt cách ghi license cho thư mục desktop.

## 2026-11-28 · OCHNA-U2 tới U4 · giai đoạn 4a

- `esp-sync` đồng bộ theo trạng thái (không theo sự kiện): đọc kernel đang có trong `/boot`, giữ 3 bản mới nhất trên ESP, mặc định bản số cao nhất (`sort -V`). Chọn cách này để ba hook (cài, gỡ, dựng lại initrd) cùng gọi một lệnh, chạy lại bao nhiêu lần cũng ra cùng kết quả. Bỏ qua khi `/boot/efi` chưa mount (lúc dựng image trong chroot).
- Thử: kernel 6.18.64 build trên CI với `publish=false` (không Release, không đổi `kernel/status`), image dựng bằng kernel đó (`kernel_run`), rồi cập nhật lên 6.18.65 qua `apt`. 6 PASS. Mỗi bản chiếm 78 MiB trên ESP 512 MiB khi chưa cài NVIDIA; initrd có thể lớn hơn khi có thêm module, chưa đo.
- Anh duyệt: thư mục `desktop/` dùng `LICENSE` GPL-3.0 riêng (bản vá cho mã COSMIC GPL-3.0).

## 2026-11-28 · OCHNA-D1 · `desktop/`

- `desktop/LICENSE` GPL-3.0 (anh duyệt): bản vá cho mã COSMIC theo giấy phép của mã đó.
- 22 thành phần COSMIC ghim theo commit submodule của `pop-os/cosmic-epoch` tag `epoch-1.11.0` (Release mới nhất, 2026-10-20; tag `epoch-1.12.0` có nhưng chưa thành Release). Bỏ: store, player, viewer, initial-setup, osk, monitor, edit, sound-theme, simple-wrapper (chưa cần cho vòng 1).
- Build: mỗi thành phần một job CI song song trong `ubuntu:26.04`, `apt-get build-dep` theo `debian/control`, `just vendor` nếu có, `dpkg-buildpackage -b`. Lấy mã ở GitHub theo commit, không dùng kho `apt` của Pop.
- Run `46142244069`: 19/22 đạt lần đầu. Hỏng: `pop-launcher` (repo thật là `pop-os/launcher`, theo `.gitmodules` của cosmic-epoch), `cosmic-osd` (build-dep `cosmic-randr` là thành phần mình tự build, kho Ubuntu không có), `xdg-desktop-portal-cosmic` (`just vendor` đòi `SOURCE_DATE_EPOCH`). Sửa: cột repo trong `components.txt`; `build-deps.txt` cho phụ thuộc giữa các thành phần, build trước trong cùng job rồi cài; `SOURCE_DATE_EPOCH` lấy thời điểm commit.
- Run `46144578124`: `pop-launcher`, `cosmic-osd` đạt; `xdg-desktop-portal-cosmic` còn đòi `SOURCE_GIT_HASH` (justfile chạy `sh -u`). Sửa: đặt bằng commit đã ghim.
- Cả 22 thành phần build đạt (3 run sửa lỗi). Run đủ bộ 46146485629 để có một bộ gói đồng bộ cho image.
- Tiêu chí 1 giai đoạn 2 đạt: `base/build.sh` ở máy anh không `sudo`, `mmdebstrap` chế độ `unshare` qua profile AppArmor của Ubuntu, 1:51.85 (CI 71 tới 112 giây). Dựng trong worktree riêng để không đè `out/` của chuỗi image desktop đang chạy; chưa chạy `vm-test` trên bản dựng cục bộ (máy ảo của chuỗi desktop đang dùng cổng 2234).
- Run base `46148115860` (desktop run `46146485629`): cài gói desktop hỏng vì `cosmic-settings-daemon` Depends `adw-gtk3`, gói Pop không có trong kho Ubuntu 26.04 (các dòng `qalc`, `libgbm1`... là hệ quả kéo theo, Ubuntu có đủ). Sửa: thêm `pop-os/adw-gtk3` (LGPL-2.1, có `debian/`) vào `components.txt`, ghim commit `master` 2026-11-28 vì không nằm trong submodule của cosmic-epoch. Giai đoạn theme sẽ thay bằng GTK theme ochna-aero.
- Base run `46150374437`: thiếu tiếp `pop-sound-theme`. Quét một lượt Depends của 25 gói đã build so với kho Ubuntu 26.04 (`tmp` script, `apt-cache` trên máy anh): chỉ thiếu `cosmic-osk`, `pop-fonts`, `pop-sound-theme`. Sửa: thêm `cosmic-osk` (submodule epoch); bản vá `debian/control` bỏ `pop-fonts` ở `cosmic-session` (ochna-aero dùng font riêng) và thay `pop-sound-theme` bằng `sound-theme-freedesktop` ở `cosmic-settings-daemon` (`pop-sound-theme` không có `debian/` ở `pop-os/cosmic-sound-theme`).

## 2026-11-28 · cách theo upstream COSMIC

- Anh chốt: fork mềm, theo upstream theo nhịp của mình (đổi commit ghim trong `desktop/components.txt` khi có Release `epoch` mới, CI build, sửa bản vá không áp được, thử trong máy ảo rồi mới dùng). Tên hiển thị ochna-aero, tên gói và crate giữ `cosmic-*` để bản vá áp thẳng.
- Tuỳ biến chia 3 lớp, ưu tiên lớp thấp: (1) cấu hình mặc định (màu, bo góc, font, sáng tối, vị trí và cỡ panel, dock, danh sách applet) ghi thành file, không vá mã; (2) applet hay app riêng là gói riêng của mình; (3) bản vá mã cho thứ cấu hình không làm được (nút tròn bên trái, kính mờ, đèn sáng dock). Lớp 3 càng ít thì mỗi lần theo upstream càng rẻ.
- Base run `46152767613` (desktop run `46151070225`) đạt: 448 gói, qcow2 2.5 GB, dựng 215 giây, `vm-test` 9 PASS, dmesg 0. `cosmic-greeter.service` hỏng: `greetd` báo "PAM error reading PAM configuration file" vì `/etc/pam.d/greetd` có `@include login` mà gói `login` chưa cài (biến thể `apt` của `mmdebstrap` không kéo nó); `pam_gnome_keyring.so` thiếu dù `/etc/pam.d/cosmic-greeter` gọi; thiếu `/etc/default/locale`. Đọc bằng `debugfs` trên image (`stat` của debugfs luôn thoát 0, phải grep "File not found"). Sửa: `login` vào nền, `desktop/packages.txt` (gói Ubuntu riêng cho desktop: `libpam-gnome-keyring`, `gnome-keyring`), file locale.
- Base run có desktop (sau `OCHNA-D5`): `cosmic-greeter.service` active, chạy `cosmic-comp`, `cosmic-greeter`, `cosmic-osk`; chụp màn hình qua QEMU monitor (`-device virtio-vga`, `screendump`) ra màn đăng nhập COSMIC mặc định, tối, chưa có user nên chỉ có ô mật khẩu. Còn: `pam_env` vẫn báo thiếu `/etc/default/locale` dù đã thêm vào `rootfs/` (chưa rõ vì sao, cần kiểm); greeter báo "Failed to create watcher for com.system76.CosmicTheme.*" vì chưa có cấu hình mặc định, sẽ có khi làm theme.
