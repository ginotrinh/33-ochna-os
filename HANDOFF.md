# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ✅ **XONG 2026-11-27 (Lucina):** build không BTF 1:25:35, `kernel/vm-test.sh` 4 PASS (`c6a928a`) ~~**Build thử kernel ở máy anh, boot trong máy ảo Ubuntu 26.04**~~
2. ⏳ **Đo build có BTF rồi anh chốt giữ BTF** — `build/build-btf.log` (thời gian, `peak build/ KiB`); chạy lại `kernel/vm-test.sh`, kiểm hết lỗi `bpf-restrict-fs`; so với lần không BTF (6.7 GB, 1:25:35).
3. ⏳ **Push rồi chạy workflow `kernel` bằng tay một lần** — chỉ push khi bước 2 đã chốt và VM chạy ổn và chạy ổn trong VM; đo thời gian, đĩa, kết quả NVIDIA (tiêu chí 3 tới 5).

## Tồn đọng (backlog)

### Mọi máy

1. ✅ **XONG 2026-11-27 (Lucina):** `LICENSE` GPL-2.0 ~~**Chọn license cho repo**~~

## Snapshot

- 2026-11-27: repo công khai đã push khung (`CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`).
- 2026-11-27: có `docs/PLAN.md`, `kernel/build.sh`, `kernel/config/`, `kernel/series`, `kernel/status`, `.github/workflows/kernel.yml`; chưa build lần nào.
