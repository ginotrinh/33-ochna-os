# SPEC OchnaOS

Duyệt: giai đoạn 1, 2026-11-27; giai đoạn 2, 2026-11-28 (sửa: thêm dựng image trên CI, cùng ngày).

## Kiến trúc

| Lớp | Cách làm | Giai đoạn |
|---|---|---|
| Kernel | kernel.org LTS, đóng gói `.deb` | 1 |
| Nền | Ubuntu 26.04 tối giản bằng `mmdebstrap`, cập nhật qua `apt` | 2 |
| Desktop | anh tự thiết kế | 3 |
| Đóng gói | ISO hoặc image, trình cài, kho `apt` có ký | 4 |

## Giai đoạn 1: kernel và CI

**Cái gì:**
1. `kernel/`: bản kernel đang theo, cấu hình (khởi đầu từ Ubuntu 26.04, chỉnh cho P50), bản vá, script build một lệnh dùng chung cho máy anh và CI.
2. Workflow GitHub Actions chạy mỗi tuần và chạy tay: có bản vá LTS mới thì build kernel, build thử driver NVIDIA nhánh 580, phát hành lên GitHub Releases; không có thì cập nhật file trạng thái.
3. CI chỉ build; kiểm trong máy ảo làm ở máy anh.

**Done when:**
- [x] 1. Một lệnh build ra `linux-image` và `linux-headers` OchnaOS từ bản kernel ghi trong repo, ở máy anh và trên CI. — bằng chứng: máy anh `kernel/build.sh` exit 0 (2026-11-28, 1:46:13); CI run `46082094150` job build đạt (1:25:47).
- [x] 2. Máy ảo Ubuntu 26.04 cài gói đó khởi động được; `uname -r` ra bản OchnaOS; mạng và ổ đĩa chạy. — bằng chứng: `kernel/vm-test.sh` 2026-11-27, 4 PASS (`uname -r` 6.18.65-ochna, https kernel.org, ghi đọc 256 MiB, `CONFIG_RUST=y`), exit 0.
- [x] 3. Driver NVIDIA nhánh 580 build được với kernel đó trên CI; build hỏng thì không phát hành. — bằng chứng: run `46082094150` job nvidia đạt (`nvidia.ko` build với `6.18.65-ochna`); run `46069444033` nvidia hỏng thì job release bị bỏ qua.
- [ ] 4. Workflow chạy mỗi tuần và chạy tay, mỗi lần dưới 6 giờ, log ghi bản kernel và kết quả; tuần không có bản vá mới thì cập nhật file trạng thái (bản kernel đã kiểm, ngày kiểm).
- [x] 5. Gói đạt được phát hành lên GitHub Releases, tên release có bản kernel, kèm file checksum. — bằng chứng: Release `v6.18.65-ochna` (2026-11-28) có `linux-image`, `linux-headers`, `SHA256SUMS`.
- [x] 6. `git ls-files` không có file bản quyền riêng, bí mật, file build ra. — bằng chứng: `git ls-files` 17 file, 396 KB, không file build, bí mật hay bản quyền riêng (2026-11-28).

**Ngoài phạm vi:** nền, desktop, ISO, cài lên P50, ký Secure Boot.

## Giai đoạn 2: nền

**Cái gì:**
1. `base/`: danh sách gói, cấu hình hệ thống, script dựng một lệnh ra image đĩa UEFI từ kho Ubuntu 26.04 bằng `mmdebstrap`, không cần `sudo`.
2. Image gồm: kernel OchnaOS từ GitHub Releases, `systemd-boot`, systemd, `apt`, NetworkManager, `openssh-server`, `sudo`, firmware Wi-Fi Intel, microcode Intel. Chỉ console.
3. Script thử: boot image trong máy ảo UEFI ở máy anh, kiểm các tiêu chí dưới.
4. Workflow chạy tay `base` trên GitHub Actions dựng image và tải lên artifact, để thử khi máy anh chưa có `mmdebstrap`.

**Done when:**
- [ ] 1. Một lệnh ở máy anh dựng ra image đĩa từ danh sách gói trong repo, không cần `sudo`; ghi thời gian dựng và kích thước image.
- [ ] 2. Máy ảo UEFI boot image qua `systemd-boot` vào kernel OchnaOS; `uname -r` ra bản OchnaOS; đăng nhập console được.
- [ ] 3. NetworkManager có địa chỉ và ra internet; `ssh` vào được; ổ đĩa ghi đọc được.
- [ ] 4. `apt update` và `apt upgrade` chạy được; image không có gói kernel của Ubuntu, `apt upgrade` không cài kernel Ubuntu.
- [ ] 5. `nvidia-dkms-580` cài được trong image và build module cho kernel OchnaOS.
- [ ] 6. Repo và image không có mật khẩu hay khoá viết cứng; tài khoản và khoá dùng để thử tạo lúc chạy script thử.

**Ngoài phạm vi:** desktop, trình cài, cài lên P50, ISO live, ký Secure Boot, kho `apt` có ký, phát hành image.

## Các giai đoạn sau (phác thảo)

- **3, desktop:** anh thiết kế; mang sang từ `32-ochna-os` phần phù hợp.
- **4, đóng gói:** ISO hoặc image, trình cài, kho `apt` có ký, lệnh cập nhật.
