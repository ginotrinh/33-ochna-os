# SPEC OchnaOS (dựng lại từ kernel)

Trạng thái: **giai đoạn 1 chờ anh duyệt.** Các giai đoạn sau chỉ phác thảo.

## Bối cảnh

Anh chốt 2026-11-27 dựng lại OchnaOS từ kernel theo hướng C, thay cho ISO dựng trên nền Pop!_OS (`32-ochna-os`, vòng 1 tới 3). Lý do: dò lỗi trong lớp desktop của Pop (nút cửa sổ app GTK, Orca tự bật) tốn nhiều công, anh muốn tự kiểm soát. Các hướng đã cân nhắc và bị loại: Linux From Scratch (không có trình quản lý gói, vá bảo mật tay), Gentoo (build gói lớn nhiều giờ trên P50), NixOS (cách làm khác hẳn).

Hướng C gồm bốn lớp:

| Lớp | Cách làm | Giai đoạn |
|---|---|---|
| Kernel | tự build từ nhánh LTS, đóng gói `.deb` | 1 |
| Nền userspace | Ubuntu 26.04 tối giản bằng `debootstrap`, cập nhật qua `apt` | 2 |
| Desktop | anh tự thiết kế mới | 3 |
| Đóng gói | ISO hoặc image, trình cài, kênh cập nhật | 4 |

## Giai đoạn 1: kernel và CI

**Cái gì:**
1. Thư mục `kernel/` chứa mọi thứ để build kernel OchnaOS thành gói `.deb`: chọn bản kernel, cấu hình (bắt đầu từ cấu hình kernel của Ubuntu 26.04, rồi chỉnh cho phần cứng P50), bản vá nếu có, và một script build chạy bằng một lệnh, giống nhau ở máy anh và trên CI.
2. Một workflow GitHub Actions chạy mỗi tuần theo lịch (và chạy tay khi cần): kiểm bản vá mới của nhánh LTS, build kernel, build thử driver NVIDIA nhánh 580 với kernel vừa build, rồi phát hành gói đạt yêu cầu.
3. CI chỉ build. Kiểm trong máy ảo làm ở máy anh; P50 chỉ cài khi anh chạy lệnh cập nhật.

**Vì sao:** kernel là lớp anh muốn tự kiểm soát trước tiên, và là lớp cập nhật thường xuyên nhất (bản vá bảo mật); làm CI cho nó trước thì các giai đoạn sau có sẵn nhịp build và phát hành.

**Done when:**
- [ ] 1. Một lệnh (`kernel/build.sh` hoặc tương đương) build ra gói `linux-image` và `linux-headers` của OchnaOS từ một bản kernel ghi rõ trong repo, chạy được cả ở máy anh lẫn trên CI.
- [ ] 2. Cài gói đó vào một máy ảo Ubuntu 26.04: máy khởi động được, `uname -r` ra bản OchnaOS, mạng và ổ đĩa hoạt động.
- [ ] 3. Driver NVIDIA nhánh 580 build được với kernel đó (trên CI, bằng DKMS hoặc cách tương đương); build hỏng thì bản kernel đó không được phát hành.
- [ ] 4. Workflow chạy theo lịch mỗi tuần và chạy tay được; mỗi lần chạy xong dưới 6 giờ (giới hạn một job của GitHub), log ghi rõ bản kernel và kết quả. Tuần không có bản vá mới thì không build, nhưng vẫn cập nhật một file trạng thái trong repo (bản kernel đã kiểm, ngày kiểm).
- [ ] 5. Gói đạt yêu cầu được phát hành lên GitHub Releases của repo, tên release có bản kernel, kèm file checksum.
- [ ] 6. Repo công khai không chứa file có bản quyền riêng, bí mật, hay file build ra (`git ls-files` đối chiếu `.gitignore` và luật trong `CLAUDE.md`).

**Ngoài phạm vi giai đoạn 1:** nền userspace, desktop, ISO, cài lên P50, ký Secure Boot cho kernel (ghi lại để quyết ở giai đoạn sau).

**Đã chốt (anh, 2026-11-27):**
1. Nguồn kernel: nhánh LTS của kernel.org, cấu hình khởi đầu lấy từ kernel của Ubuntu 26.04 rồi chỉnh cho P50.
2. Chỗ phát hành gói: GitHub Releases của repo này ở giai đoạn 1; kho `apt` có ký để giai đoạn 4.
3. Tuần không có bản vá kernel mới: CI bỏ qua build nhưng ghi một dấu vết (file trạng thái trong repo) để repo công khai không bị GitHub tắt lịch chạy sau 60 ngày không hoạt động.

## Đã tra trước khi thiết kế (luật 29 của gaos)

Tra 2026-11-27 bằng `gh search repos` (các từ khoá `bindeb-pkg`, `kernel build actions deb`, `custom kernel ubuntu workflow`) và đọc workflow của các dự án sau:
- `damentz/liquorix-package` (356 sao, GPL-2.0, cập nhật 2026-11-23): build kernel Liquorix cho Debian và Ubuntu; workflow `build-test.yml` chỉ chạy tay ("Kernel builds take too long for every push, Jenkins builds the releases"), bước đầu dọn bớt đĩa của máy chạy (`mathio/gha-cleanup`, bỏ trình duyệt cài sẵn), build theo ma trận từng bản Debian và Ubuntu, ký gói bằng GPG. Ý mượn: dọn đĩa trước khi build (máy chạy chỉ có 14 GB SSD), ma trận theo bản Ubuntu, ký gói.
- `EmbeddedAndroid/kbuild-deb` (1 sao): một GitHub Action đóng gói kernel bằng `make bindeb-pkg`. Quá ít người dùng để dựa vào; chỉ ghi nhận cách dùng `bindeb-pkg`.
- `pop-os/linux`, `zen-kernel/zen-kernel`: không có workflow GitHub Actions công khai trong `.github/workflows` (API trả 404), nên không so được cách CI.
Kết quả: chưa thấy dự án lớn nào build kernel mỗi tuần hoàn toàn trên máy chạy miễn phí của GitHub; Liquorix dùng Jenkins riêng cho bản phát hành. Thời gian build trên máy 4 CPU của GitHub là điểm phải đo ở tiêu chí 4.

## Giới hạn của GitHub Actions (docs.github.com, đọc 2026-11-27)

- Repo công khai: runner chuẩn "free and unlimited"; máy Linux 4 CPU, 16 GB RAM, 14 GB SSD.
- Mỗi job tối đa 6 giờ; lịch chạy ngắn nhất mỗi 5 phút; repo công khai 60 ngày không hoạt động thì lịch chạy tự tắt.

## Các giai đoạn sau (phác thảo, chưa duyệt)

- **Giai đoạn 2, nền:** `debootstrap` Ubuntu 26.04 tối giản, danh sách gói ghi trong repo, cài kernel OchnaOS.
- **Giai đoạn 3, desktop:** anh thiết kế; mang sang từ `32-ochna-os` các phần hợp (bộ icon, con trỏ, zsh, ý tưởng menu logo).
- **Giai đoạn 4, đóng gói:** ISO hoặc image (so công cụ build ISO hiện có với `mkosi` trước khi chọn), trình cài, kho `apt` có ký, lệnh cập nhật kiểu `ochna-update`.

## Thay đổi SPEC (changelog)

- 2026-11-27: tạo SPEC, giai đoạn 1 chờ duyệt.
- 2026-11-27: anh chốt 3 câu hỏi (kernel.org LTS với cấu hình khởi đầu của Ubuntu; GitHub Releases ở giai đoạn 1; tuần không có bản vá thì bỏ build nhưng ghi dấu vết); tiêu chí 4 và 5 viết rõ theo đó. Giai đoạn 1 vẫn chờ anh duyệt.
