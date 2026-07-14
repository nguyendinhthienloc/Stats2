# Nhiệm vụ của Trần Lê Anh Tuấn (P2)

Chào Tuấn, đây là hướng dẫn công việc của bạn:

**Nhánh làm việc (Branch):**
Hãy chắc chắn bạn đang ở nhánh của mình trước khi viết code:
`git checkout feature/p2-tuan-ols-ridge`

**Nhiệm vụ chính:** Mô hình OLS & Ridge Regression

**Bạn cần chỉnh sửa các file sau:**
1. Code R: `R_models/02_ols.R` và `R_models/02_ridge.R`
2. Báo cáo LaTeX: `LaTeX_report/sections/02_ols_ridge_lasso.tex` (Phần 2.1 và 2.2)

**Mục tiêu (Phase 2):**
- Đợi Lộc (P1) chạy xong để lấy file `output/shared_data.RData`.
- Code mô hình baseline OLS và tính residual.
- Code mô hình Ridge, dùng Cross Validation (với `foldid` chuẩn từ Lộc) để tìm lambda tốt nhất.
- Vẽ đồ thị CV và đồ thị hệ số shrinkage cho Ridge.
- Viết báo cáo giải thích kết quả cho 2 mô hình này.
