# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ⏳ **Build thử kernel ở máy anh** — cài gói build (`bison flex libssl-dev libelf-dev`), chạy `kernel/build.sh`, rồi thử boot trong máy ảo Ubuntu 26.04 (tiêu chí 1, 2).
2. ⏳ **Push rồi chạy workflow `kernel` bằng tay một lần** — chỉ push khi bước 1 boot được và chạy ổn trong VM; đo thời gian, đĩa, kết quả NVIDIA (tiêu chí 3 tới 5).

## Tồn đọng (backlog)

### Mọi máy

1. ✅ **XONG 2026-11-27 (Lucina):** `LICENSE` GPL-2.0 ~~**Chọn license cho repo**~~

## Snapshot

- 2026-11-27: repo công khai đã push khung (`CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`).
- 2026-11-27: có `docs/PLAN.md`, `kernel/build.sh`, `kernel/config/`, `kernel/series`, `kernel/status`, `.github/workflows/kernel.yml`; chưa build lần nào.
