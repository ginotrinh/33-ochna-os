# SPEC OchnaOS

Duyệt: giai đoạn 1, 2026-11-27; giai đoạn 2, 2026-11-28 (sửa: thêm dựng image trên CI, cùng ngày); giai đoạn 3 vòng 1 và 4a, 2026-11-28 (sửa: bỏ xem trước cửa sổ của dock).

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
- [x] 1. Một lệnh ở máy anh dựng ra image đĩa từ danh sách gói trong repo, không cần `sudo`; ghi thời gian dựng và kích thước image. — bằng chứng: `base/build.sh` ở máy anh, user thường, không `sudo` (2026-11-28, `mmdebstrap` 1.5.7 chế độ `unshare`): exit 0, 1:51.85, qcow2 1.33 GB, 205 gói.
- [x] 2. Máy ảo UEFI boot image qua `systemd-boot` vào kernel OchnaOS; `uname -r` ra bản OchnaOS; đăng nhập console được. — bằng chứng: `base/vm-test.sh` 2026-11-28, image từ run `46117066579`: `uname -r` 6.18.65-ochna, biến EFI `LoaderInfo` có (systemd-boot), serial hiện `ochna login:`, đăng nhập `ssh` root bằng khoá thử.
- [x] 3. NetworkManager có địa chỉ và ra internet; `ssh` vào được; ổ đĩa ghi đọc được. — bằng chứng: cùng lần thử: `nmcli` báo `connected`, https kernel.org đạt, ghi đọc 256 MiB đạt.
- [x] 4. `apt update` và `apt upgrade` chạy được; image không có gói kernel của Ubuntu, `apt upgrade` không cài kernel Ubuntu. — bằng chứng: cùng lần thử: `apt-get update` và `upgrade` đạt; chỉ có `linux-image-6.18.65-ochna`; `apt-get -s install linux-generic` bị từ chối.
- [x] 5. `nvidia-dkms-580` cài được trong image và build module cho kernel OchnaOS. — bằng chứng: cùng lần thử: `nvidia-dkms-580` cài và `dkms status` báo installed cho 6.18.65-ochna.
- [x] 6. Repo và image không có mật khẩu hay khoá viết cứng; tài khoản và khoá dùng để thử tạo lúc chạy script thử. — bằng chứng: `base/build.sh` kiểm tar không có `ssh_host_*`, `authorized_keys`, root khoá mật khẩu (run `46117066579` đạt); `git grep` khoá hay mật khẩu trong repo: không có (2026-11-28).

**Ngoài phạm vi:** desktop, trình cài, cài lên P50, ISO live, ký Secure Boot, kho `apt` có ký, phát hành image.

## Giai đoạn 3, vòng 1: desktop ochna-aero

**Cái gì:**
1. Desktop dựa trên COSMIC, tên hiển thị với người dùng là `ochna-aero` (màn đăng nhập, phiên, Settings, About); tên gói và mã nguồn upstream giữ nguyên.
2. Theme mặc định sáng theo token của `0-gaos/apps/assets/gino-style.css`: nền xanh có vệt màu, kính mờ, bóng giọt nước, viền sáng, màu nhấn, bo góc, chữ Roboto Condensed và Lora.
3. Nút cửa sổ bên trái, tròn, màu theo ochna-aero, cho cả app COSMIC lẫn app GTK.
4. Dock ở dưới kiểu macOS; màu và hành vi kiểu Windows 7: đèn sáng dưới app đang chạy.
5. Kính mờ sau panel, dock và cửa sổ (bản vá blur của cosmic-comp, tự đóng gói).
6. Module theme: một thư mục cho mỗi theme gồm màu, icon, wallpaper, con trỏ; đặt bộ icon hay wallpaper vào thư mục quy ước thì Settings liệt kê để chọn. Bộ icon mặc định kiểu Windows, giấy phép tự do.

**Done when:**
- [ ] 1. Image nền cộng desktop boot trong máy ảo vào màn đăng nhập ochna-aero, đăng nhập vào desktop; không chỗ nào người dùng thấy chữ COSMIC.
- [ ] 2. Theme mặc định khớp token gino-style (bảng đối chiếu màu, bo góc, font kèm ảnh chụp); anh duyệt bằng mắt.
- [ ] 3. Nút cửa sổ bên trái, tròn, đúng màu ở một app COSMIC và một app GTK.
- [ ] 4. Dock ở dưới, có đèn sáng dưới app đang chạy.
- [ ] 5. Kính mờ hiện sau panel, dock và ít nhất một cửa sổ.
- [ ] 6. Chép một bộ icon và một wallpaper mới vào thư mục quy ước thì chúng hiện trong danh sách chọn, chọn xong áp ngay; tài liệu ngắn trong repo chỉ chỗ đặt.
- [ ] 7. Mọi file icon, wallpaper, font trong repo hay image có giấy phép tự do, ghi nguồn.

**Ngoài phạm vi:** thanh menu toàn cục, hiệu ứng động riêng, trình cài, cài lên P50.

## Giai đoạn 4a: kernel vào ESP khi cập nhật

**Cái gì:**
1. Cài gói `linux-image-*-ochna` bằng `apt` thì kernel và initrd tự chép vào ESP, có mục `systemd-boot` riêng, bản mới là mặc định.
2. Giữ bản cũ để chọn ở menu boot khi bản mới hỏng; gỡ gói thì mục và file trên ESP được xoá.

**Done when:**
- [x] 1. Trong máy ảo chạy image nền: cài một bản kernel OchnaOS khác bằng `apt`, khởi động lại thì vào bản mới. — bằng chứng: `base/update-test.sh 6.18.65` 2026-11-28 trên image chạy 6.18.64 (base run `46135786570`, kernel thử run `46128860981`): `apt` cài 6.18.65, ESP có 2 mục, mặc định 6.18.65, khởi động lại vào 6.18.65.
- [x] 2. Menu boot còn bản cũ, chọn bản cũ thì boot được. — bằng chứng: cùng lần thử: `systemctl reboot --boot-loader-entry=ochna-6.18.64-ochna.conf` vào 6.18.64; khởi động lại thường về 6.18.65.
- [x] 3. Gỡ gói một bản thì mục boot và file của bản đó trên ESP mất; ESP không đầy sau 3 lần cập nhật liên tiếp. — bằng chứng: cùng lần thử: gỡ gói 6.18.64 thì mục và thư mục của nó trên ESP mất; ESP 78 MiB / 511 MiB với một bản, mỗi bản 78 MiB, `esp-sync` giữ tối đa 3 bản (234 MiB).
- [x] 4. Image nền dựng mới vẫn qua `base/vm-test.sh`. — bằng chứng: base run `46136850053` (ESP theo layout mới) + `base/vm-test.sh`: 10 PASS, dmesg 0 lỗi.

**Ngoài phạm vi:** kho `apt` có ký (4b), lệnh `ochna-update`, Secure Boot.

## Các giai đoạn sau (phác thảo)

- **4, đóng gói:** ISO hoặc image, trình cài, kho `apt` có ký, lệnh cập nhật.
