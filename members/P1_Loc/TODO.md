# Nhiệm vụ của Nguyễn Đình Thiên Lộc (P1)

Chào Lộc, đây là hướng dẫn công việc của bạn:

**Nhánh làm việc (Branch):**
Hãy chắc chắn bạn đang ở nhánh của mình trước khi viết code:
`git checkout feature/p1-loc-data-eda`

## Final figure-quality pass (project status: approximately 90%)

The analysis is correct, but the figures are not submission quality yet. Work
in the R source files that generate them; do not edit exported PDFs manually.

- [ ] Open `R_models/01_data_prep_eda.R` and improve all P1 figures:
  `fig_p1_correlation.pdf`, `fig_p1_dist.pdf`, `fig_p1_boxplots.pdf`, and
  `fig_p1_pairwise.pdf`.
- [ ] Make variable labels, axis text, legends, margins, and panel spacing
  readable at the size used in the report.
- [ ] Use the shared colour-blind-friendly palette and consistent typography.
- [ ] If shared plotting defaults are needed, implement them carefully in
  `R_models/setup.R` so the other members can reuse them.
- [ ] Re-run `R_models/01_data_prep_eda.R`, inspect every generated PDF, and
  preserve the existing filenames and statistical results.

**Nhiệm vụ chính:** Tiền xử lý dữ liệu & Khám phá dữ liệu (EDA)

**Bạn cần chỉnh sửa các file sau:**
1. Code R: `R_models/setup.R` và `R_models/01_data_prep_eda.R`
2. Báo cáo LaTeX: `report/sections/00_authorship.tex` và `report/sections/01_prediction_design.tex`

**Mục tiêu (Phase 1):**
- Đọc file `data/fat.csv`.
- Chia dữ liệu train/test (80/20) với seed = `240201`.
- Chuẩn hóa dữ liệu với tập train.
- Xuất file dữ liệu dùng chung: `output/shared_data.RData`.
- Tạo các biểu đồ EDA (Correlation, Boxplots, v.v.).
- Viết phần giới thiệu thiết kế dữ liệu trong file LaTeX.
