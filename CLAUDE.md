# 33-ochna-os

## Dự án

- OchnaOS cho ThinkPad P50: kernel tự build (kernel.org LTS), nền Ubuntu 26.04 tối giản (`debootstrap`, `apt`), desktop tự thiết kế.
- Repo công khai: `github.com/ginotrinh/33-ochna-os`.
- Tiền thân: `32-ochna-os`.
- Trao đổi, tài liệu: tiếng Việt. Comment trong mã, commit message: tiếng Anh.

## Luật

1. File trong repo chỉ chứa nội dung hiện hành, câu ngắn, không diễn giải, không nêu lý do.
2. Diễn giải, lý do, lịch sử, kết quả tra cứu: ghi vào `logs/notes.<YYYY.MM>.md`, mỗi mục gồm ngày, file liên quan, nội dung.
3. Không đưa vào git: file có bản quyền riêng, file không có giấy phép tự do, bí mật, file build ra.
4. Commit local tự do; push khi anh bảo.
5. Commit message: `<TICKET-ID> (<mức>): <mô tả>` và gạch đầu dòng; không ghi agent là tác giả; tiền tố ticket `OCHNA-K` (kernel), `OCHNA-B` (nền), `OCHNA-D` (desktop), `OCHNA-U` (cập nhật).
6. SPEC ở `docs/SPEC.md`; làm khi có dòng `Duyệt:`; tiêu chí Done when dạng ô đánh dấu, đạt kèm bằng chứng.
7. CI chỉ build; P50 cài khi anh chạy lệnh cập nhật.
8. Lệnh `sudo` dài: ghi log bằng `script -q -e -c "<lệnh>" <log>`, không dùng `| tee`.
9. `HANDOFF.md` theo khuôn HANDOFF của gaos.
10. Comment trong mã: ticket ID và mô tả ngắn, tiếng Anh. BUG, FIX, WHY ghi vào `logs/notes.<YYYY.MM>.md` kèm ticket ID.
11. Mã mới (driver, desktop, công cụ): viết bằng Rust; chỉ dùng C khi Rust không làm được, ghi lý do vào `logs/notes`.
