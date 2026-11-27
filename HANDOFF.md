# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ✅ **XONG 2026-11-27 (Lucina):** build không BTF 1:25:35, `kernel/vm-test.sh` 4 PASS (`c6a928a`) ~~**Build thử kernel ở máy anh, boot trong máy ảo Ubuntu 26.04**~~
2. ✅ **XONG 2026-11-28 (Lucina):** anh chọn giữ BTF và nén zstd; build 1:46:13, đỉnh 23.0 GiB, VM test 4 PASS, hết `bpf-restrict-fs` (`b52c8ed`) ~~**Đo build có BTF rồi anh chốt giữ BTF**~~
3. ⏳ **Đọc kết quả lần chạy tay đầu tiên của workflow `kernel`** — đã push `0f54a15`, run `46056804098`; lịch tuần đang tắt; đọc đỉnh đĩa (`peak root used MiB`), thời gian, NVIDIA, Release; đạt thì bật lại `schedule` (tiêu chí 1, 3 tới 5); hỏng vì đĩa thì cân nhắc `localmodconfig` hoặc bỏ BTF trên CI.

## Tồn đọng (backlog)

### Mọi máy

1. ✅ **XONG 2026-11-27 (Lucina):** `LICENSE` GPL-2.0 ~~**Chọn license cho repo**~~

## Snapshot

- 2026-11-27: repo công khai đã push khung (`CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`).
- 2026-11-27: có `docs/PLAN.md`, `kernel/build.sh`, `kernel/config/`, `kernel/series`, `kernel/status`, `.github/workflows/kernel.yml`; chưa build lần nào.
