# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ✅ **XONG 2026-11-27 (Lucina):** build không BTF 1:25:35, `kernel/vm-test.sh` 4 PASS (`c6a928a`) ~~**Build thử kernel ở máy anh, boot trong máy ảo Ubuntu 26.04**~~
2. ✅ **XONG 2026-11-28 (Lucina):** anh chọn giữ BTF và nén zstd; build 1:46:13, đỉnh 23.0 GiB, VM test 4 PASS, hết `bpf-restrict-fs` (`b52c8ed`) ~~**Đo build có BTF rồi anh chốt giữ BTF**~~
3. ✅ **XONG 2026-11-28 (Lucina):** run `46082094150` đạt cả 4 job, Release `v6.18.65-ochna`; 2 run trước hỏng NVIDIA vì gói headers thiếu `Depends` (sửa `OCHNA-K10`) ~~**Đọc kết quả lần chạy tay đầu tiên của workflow `kernel`**~~
4. ⏳ **Kiểm lần chạy theo lịch đầu tiên (thứ Hai 2026-11-30, 02:00 UTC tức 09:00 giờ VN)** — lịch đã bật (`OCHNA-K12`); tiêu chí 4 chỉ đạt khi có một lần chạy theo lịch (tuần có bản mới thì build, không có thì ghi `kernel/status`).

## Tồn đọng (backlog)

### Mọi máy

1. ✅ **XONG 2026-11-27 (Lucina):** `LICENSE` GPL-2.0 ~~**Chọn license cho repo**~~

## Snapshot

- 2026-11-27: repo công khai đã push khung (`CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`).
- 2026-11-27: có `docs/PLAN.md`, `kernel/build.sh`, `kernel/config/`, `kernel/series`, `kernel/status`, `.github/workflows/kernel.yml`; chưa build lần nào.
