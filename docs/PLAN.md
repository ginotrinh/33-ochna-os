# PLAN giai đoạn 1

Dựa trên: `docs/SPEC.md`, duyệt giai đoạn 1, 2026-11-27.

1. `LICENSE`: GPL-2.0.
2. `kernel/series`: nhánh LTS đang theo (`6.18`).
3. `kernel/config/ubuntu-26.04.config`: cấu hình khởi đầu (Ubuntu 26.04, kernel `7.0.0-43-generic`).
4. `kernel/config/ochna.fragment`: các khoá OchnaOS ghi đè lên cấu hình khởi đầu.
5. `kernel/build.sh [bản|auto]`: tải mã kernel.org, kiểm sha256, ghép cấu hình, `make bindeb-pkg`, ra gói ở `out/`.
6. Build thử ở máy anh (tiêu chí 1), cài vào máy ảo Ubuntu 26.04 (tiêu chí 2).
7. `.github/workflows/kernel.yml`: chạy mỗi tuần và chạy tay; `check` so bản mới nhất với `kernel/status`; có bản mới thì `build`, `nvidia`, `release`; không có thì cập nhật `kernel/status`.
8. Chạy workflow bằng tay một lần, đo thời gian (tiêu chí 3 tới 5).
9. Kiểm `git ls-files` (tiêu chí 6), đối chiếu SPEC.
