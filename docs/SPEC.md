# SPEC OchnaOS

Duyệt: giai đoạn 1, 2026-11-27.

## Kiến trúc

| Lớp | Cách làm | Giai đoạn |
|---|---|---|
| Kernel | kernel.org LTS, đóng gói `.deb` | 1 |
| Nền | Ubuntu 26.04 tối giản bằng `debootstrap`, cập nhật qua `apt` | 2 |
| Desktop | anh tự thiết kế | 3 |
| Đóng gói | ISO hoặc image, trình cài, kho `apt` có ký | 4 |

## Giai đoạn 1: kernel và CI

**Cái gì:**
1. `kernel/`: bản kernel đang theo, cấu hình (khởi đầu từ Ubuntu 26.04, chỉnh cho P50), bản vá, script build một lệnh dùng chung cho máy anh và CI.
2. Workflow GitHub Actions chạy mỗi tuần và chạy tay: có bản vá LTS mới thì build kernel, build thử driver NVIDIA nhánh 580, phát hành lên GitHub Releases; không có thì cập nhật file trạng thái.
3. CI chỉ build; kiểm trong máy ảo làm ở máy anh.

**Done when:**
- [ ] 1. Một lệnh build ra `linux-image` và `linux-headers` OchnaOS từ bản kernel ghi trong repo, ở máy anh và trên CI.
- [x] 2. Máy ảo Ubuntu 26.04 cài gói đó khởi động được; `uname -r` ra bản OchnaOS; mạng và ổ đĩa chạy. — bằng chứng: `kernel/vm-test.sh` 2026-11-27, 4 PASS (`uname -r` 6.18.65-ochna, https kernel.org, ghi đọc 256 MiB, `CONFIG_RUST=y`), exit 0.
- [ ] 3. Driver NVIDIA nhánh 580 build được với kernel đó trên CI; build hỏng thì không phát hành.
- [ ] 4. Workflow chạy mỗi tuần và chạy tay, mỗi lần dưới 6 giờ, log ghi bản kernel và kết quả; tuần không có bản vá mới thì cập nhật file trạng thái (bản kernel đã kiểm, ngày kiểm).
- [ ] 5. Gói đạt được phát hành lên GitHub Releases, tên release có bản kernel, kèm file checksum.
- [ ] 6. `git ls-files` không có file bản quyền riêng, bí mật, file build ra.

**Ngoài phạm vi:** nền, desktop, ISO, cài lên P50, ký Secure Boot.

## Các giai đoạn sau (phác thảo)

- **2, nền:** `debootstrap` Ubuntu 26.04 tối giản, danh sách gói trong repo, cài kernel OchnaOS.
- **3, desktop:** anh thiết kế; mang sang từ `32-ochna-os` phần phù hợp.
- **4, đóng gói:** ISO hoặc image, trình cài, kho `apt` có ký, lệnh cập nhật.
