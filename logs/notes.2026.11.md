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
