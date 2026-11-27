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
