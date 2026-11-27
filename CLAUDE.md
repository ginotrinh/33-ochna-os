# 33-ochna-os — Claude Code Rules

## Project Identity

- **Name:** OchnaOS, bản dựng lại từ kernel (hướng C, anh chốt 2026-11-27).
- **Purpose:** hệ điều hành riêng cho ThinkPad P50 của anh: kernel tự build (nhánh LTS), nền Ubuntu 26.04 tối giản dựng bằng `debootstrap` (gói nền vẫn cập nhật qua `apt`), desktop mới do anh tự thiết kế. Kernel và các gói liên quan được CI trên GitHub build mỗi tuần.
- **Repo:** `github.com/ginotrinh/33-ochna-os`, **công khai**. Mọi thứ commit ở đây ai cũng đọc được.
- **Tiền thân:** `32-ochna-os` (ISO dựng trên Pop!_OS, vòng 1 tới 3). Phần đã làm ở đó (icon, con trỏ, zsh, menu logo, bộ kiểm) mang sang khi thích hợp; mang thì ghi nguồn gốc file.
- **Ngôn ngữ:** tiếng Việt cho trao đổi và tài liệu; comment trong mã và commit message bằng tiếng Anh.

## Luật riêng

1. **Không đưa vào git:** file có bản quyền riêng hoặc không có giấy phép tự do (font riêng trong `fonts/private/`, gói FortiClient), bí mật (`.env`, khoá, token), và mọi thứ build ra (cây kernel, `.deb`, ISO, ổ đĩa ảo). `.gitignore` đã chặn các loại này; trước mỗi commit đọc lại `git status`.
2. **Commit local thoải mái, push khi anh bảo.** Repo công khai, push là đăng ra ngoài. Mỗi lần push chỉ gồm commit anh đã biết.
3. **Commit message:** `<TICKET-ID> (<mức>): mô tả ngắn` rồi gạch đầu dòng; không kèm dòng ghi tác giả là agent. Ticket của project này dùng tiền tố `OCHNA-K` (vd `OCHNA-K1`).
4. **Comment khi sửa mã:** khối 4 dòng bằng tiếng Anh ngay trên đoạn mã: ticket ID, BUG hoặc vì sao cần, FIX, WHY.
5. **Cổng SPEC:** việc có đầu ra cần duyệt (giai đoạn, tính năng) thì viết SPEC ở `docs/SPEC.md`, anh duyệt (dòng `Duyệt: ...` trong file) rồi mới lập plan và làm. Tiêu chí "Done when" viết dạng ô đánh dấu, chỉ đánh dấu đạt khi có bằng chứng chạy được ghi ngay cạnh.
6. **CI chỉ build, không tự cài lên P50.** Bản build đạt được đưa lên kho gói; P50 chỉ cài khi anh chạy lệnh cập nhật. Kiểm trong máy ảo làm ở máy của anh, để có lỗi thì vá trước khi cài.
7. **Lệnh dài chạy bằng `sudo` thì ghi log bằng `script -q -e -c "<lệnh>" <log>`, không dùng `| tee`:** `sudo` trên Ubuntu 26.04 chạy lệnh trong pty riêng, đầu ra vào ống thì `apt-get` bị hệ thống tạm dừng (wiki gaos `pop-os-iso-build-nvidia-driver-and-maxwell-gpu`).
8. **HANDOFF:** `HANDOFF.md` ở gốc repo theo khuôn chung của gaos (NEXT ACTION, Tồn đọng, Snapshot); xong mục nào đóng mục đó ngay.

## Tham khảo

- SPEC và kế hoạch: `docs/SPEC.md`.
- Bài học đã gặp khi dựng ISO trên nền Pop: `32-ochna-os/HANDOFF.md`, `32-ochna-os/p50/SPEC.md`, và trang wiki gaos `cosmic-greeter-and-system-defaults-pop-26-04`.
