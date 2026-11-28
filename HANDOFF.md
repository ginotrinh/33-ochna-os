# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ✅ **XONG 2026-11-27 (Lucina):** build không BTF 1:25:35, `kernel/vm-test.sh` 4 PASS (`c6a928a`) ~~**Build thử kernel ở máy anh, boot trong máy ảo Ubuntu 26.04**~~
2. ✅ **XONG 2026-11-28 (Lucina):** anh chọn giữ BTF và nén zstd; build 1:46:13, đỉnh 23.0 GiB, VM test 4 PASS, hết `bpf-restrict-fs` (`b52c8ed`) ~~**Đo build có BTF rồi anh chốt giữ BTF**~~
3. ✅ **XONG 2026-11-28 (Lucina):** run `46082094150` đạt cả 4 job, Release `v6.18.65-ochna`; 2 run trước hỏng NVIDIA vì gói headers thiếu `Depends` (sửa `OCHNA-K10`) ~~**Đọc kết quả lần chạy tay đầu tiên của workflow `kernel`**~~
4. ⏳ **Kiểm lần chạy theo lịch đầu tiên (thứ Hai 2026-11-30, 02:00 UTC tức 09:00 giờ VN)** — lịch đã bật (`OCHNA-K12`); tiêu chí 4 chỉ đạt khi có một lần chạy theo lịch (tuần có bản mới thì build, không có thì ghi `kernel/status`).
5. ✅ **XONG 2026-11-28 (Lucina):** anh duyệt SPEC giai đoạn 2, sửa cùng ngày thêm dựng image trên CI ~~**Anh duyệt SPEC giai đoạn 2 (nền)**~~
6. ✅ **XONG 2026-11-28 (Lucina):** run `46117066579`, `base/vm-test.sh` 10 PASS, dmesg 0 lỗi; tiêu chí 2 tới 6 đạt ~~**Dựng image nền trên CI rồi thử trong VM ở máy anh**~~
7. ✅ **XONG 2026-11-28 (Lucina):** `base/build.sh` không `sudo` ở máy anh exit 0, 1:51.85; SPEC giai đoạn 2 đạt 6/6 ~~**Kiểm tiêu chí 1 giai đoạn 2 ở máy anh**~~
8. ✅ **XONG 2026-11-28 (Lucina):** 4a đạt 4/4 (`base/update-test.sh` 6 PASS, `base/vm-test.sh` 10 PASS) ~~**Làm 4a (kernel vào ESP)**~~
9. ⏳ **Làm giai đoạn 3 vòng 1, desktop ochna-aero** — SPEC duyệt 2026-11-28; thư mục `desktop/` có `LICENSE` GPL-3.0 riêng (anh duyệt); bắt đầu bằng build COSMIC từ mã `github.com/pop-os` trên CI.
   - 2026-11-28: `desktop/` 22 thành phần ghim `epoch-1.11.0`, cả 22 build đạt trên CI (sau 3 lỗi cơ học: repo `pop-os/launcher`, build-dep `cosmic-randr`, biến `SOURCE_DATE_EPOCH` và `SOURCE_GIT_HASH`); run đủ bộ `46146485629`. Bước sau: workflow `base` nhận `desktop_run` để cài các gói desktop vào image, boot thử tới màn đăng nhập, rồi theme ochna-aero.

## Tồn đọng (backlog)

### Mọi máy

1. ✅ **XONG 2026-11-27 (Lucina):** `LICENSE` GPL-2.0 ~~**Chọn license cho repo**~~

## Snapshot

- 2026-11-27: repo công khai đã push khung (`CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`).
- 2026-11-27: có `docs/PLAN.md`, `kernel/build.sh`, `kernel/config/`, `kernel/series`, `kernel/status`, `.github/workflows/kernel.yml`; chưa build lần nào.
