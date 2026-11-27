# HANDOFF — 33-ochna-os

## NEXT ACTION

1. ⏳ **Anh duyệt SPEC giai đoạn 1 (kernel và CI)** — `docs/SPEC.md`, kèm 3 câu hỏi cần chốt trước khi duyệt: nguồn kernel (kernel.org LTS hay mã của Ubuntu), chỗ phát hành gói (GitHub Releases hay kho `apt`), và việc của CI ở tuần không có bản vá mới. Duyệt xong thì em lập plan rồi làm `kernel/` và workflow.

## Tồn đọng (backlog)

### Mọi máy

1. ⏳ **Chọn license cho repo** — repo công khai chưa có license nên người khác chỉ xem được; chọn khi biết repo chứa gì (kernel GPL-2.0; WhiteSur, apple_cursor GPL-3.0 nếu mang sang).
2. ⏳ **Push khung đầu tiên lên GitHub** — chờ anh bảo (luật 2 trong `CLAUDE.md`).

## Snapshot

- 2026-11-27: repo `github.com/ginotrinh/33-ochna-os` (công khai) do anh tạo, clone về `~/Desktop/projects/33-ochna-os`. Đã dựng khung local: `CLAUDE.md`, `HANDOFF.md`, `.gitignore`, `docs/SPEC.md`, `kernel/README.md`, `logs/`. Chưa push (luật 2 trong `CLAUDE.md`).
- Quyết định nền (anh chốt 2026-11-27, ghi ở `32-ochna-os/HANDOFF.md` mục 0): hướng C, desktop mới tự thiết kế, phần vòng 3 mang sang khi hợp, CI chỉ build và chạy mỗi tuần, P50 chỉ cài khi anh chạy lệnh cập nhật.
