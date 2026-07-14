# Nhiệm vụ của Nguyễn Hồng Tấn Tài (P5)

Chào Tài, đây là hướng dẫn công việc của bạn:

**Nhánh làm việc (Branch):**
Hãy chắc chắn bạn đang ở nhánh của mình trước khi viết code:
`git checkout feature/p5-tai-enet-neural`

**Nhiệm vụ chính:** Elastic Net, Neural Features & Đánh giá Holdout

**Bạn cần chỉnh sửa các file sau:**
1. Code R: `R_models/04_enet.R`, `R_models/04_neural.R`, `R_models/04_holdout.R`
2. Báo cáo LaTeX: `LaTeX_report/sections/00_abstract.tex`, `LaTeX_report/sections/04_elastic_net.tex`, `LaTeX_report/sections/05_report_quality.tex`

**Mục tiêu (Phase 4 & 5):**
- Phase 4: Code mô hình Elastic Net (Tìm alpha tốt nhất) và tạo các biến đổi Random Neural Features (sử dụng seed `240401`).
- Viết báo cáo giải thích Elastic Net và Mạng Neural. Hoàn thành "Literature Source Map".
- Phase 5: Khi các bạn khác hoàn thành mọi thứ, bạn sẽ chạy `04_holdout.R`. **Đây là file DUY NHẤT được phép sử dụng `y_test`**.
- Đánh giá tất cả các mô hình trên tập holdout.
- Viết Tóm tắt (Abstract) và Đánh giá tổng thể của dự án (Report Quality).
